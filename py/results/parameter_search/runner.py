# Shared runner of the parameter search
#
# A case is one solve of an initial condition type (an arrangement of size x size particles,
# see yag_utils.particles) for a seed, with the given run parameters. The setup is the
# physical one of the clamped step example: fitted D and k, solved in dimensionless units
# of DEFAULT_SCALES. By default the reaction ends once the reagent mass drops to 10% of the
# initial one.
#
# Mass deviations are in percentage points of the mass percentages of the five species,
# against a reference solve of the same case with a fixed 1 s step (r = 1 in the clamped
# step example).
#
# Imported by the other scripts of this folder, which run with it as working directory.

import dataclasses
import hashlib
import time
from dataclasses import dataclass
from typing import Sequence

import numpy as np
import yag_model as yag
from tqdm.auto import tqdm
from yag_utils import particles, physical
from yag_utils.batch import WORKERS, csv_appender, load_rows, run_batch
from yag_utils.constants import AL2O3_CONCENTRATION, FITTED_LOG_D, FITTED_LOG_K, P_TRUE
from yag_utils.optimization import DEFAULT_SCALES
from yag_utils.paths import repo_root
from yag_utils.scaling import physical_result

SCALES = DEFAULT_SCALES
# Reagent concentrations, Y2O3 starts at 3/5 of Al2O3 so both reagents react fully
C1 = SCALES.dimensionless_concentration(AL2O3_CONCENTRATION)
C2 = SCALES.dimensionless_concentration(3 / 5 * AL2O3_CONCENTRATION)
# Time of the experiment the parameters are fitted to
EXPERIMENT_TIME = 6 * 60 * 60  # s

DATA_DIR = repo_root() / "py" / "results" / "parameter_search" / "data"
# One row per finished case, see FIELDS
RUNS_PATH = DATA_DIR / "runs.csv"
# Mass percentage histories of the reference solves, one .npz per case
REFERENCE_DIR = DATA_DIR / "reference"
# Frames of a reference kept on disk, log-spaced in steps since early steps change fastest
REFERENCE_FRAMES = 5000


@dataclass(frozen=True)
class RunParams:
    """Everything a solve depends on besides the initial condition, in SI units."""

    # log10 of D (m^2/s) and k (m^3/(mol s))
    log_D: tuple[float, ...] = FITTED_LOG_D
    log_k: tuple[float, ...] = FITTED_LOG_K
    # Clamped geometric step, r = 1.001 stayed within 1% of the fixed step at about 6x less time
    dt_0: float = 1.0  # s
    r: float = 1.001
    upper_bound: float = 60.0  # s
    every: int = 1
    # Reagent mass fraction at which the reaction ends
    threshold: float = 0.1
    # Stop at this time (s) instead of at the threshold, when set
    final_time: float | None = None

    def __post_init__(self):
        # Same values give the same CSV key, however they were passed (ints, lists, numpy)
        for name in ("dt_0", "r", "upper_bound", "threshold"):
            object.__setattr__(self, name, float(getattr(self, name)))
        object.__setattr__(self, "log_D", tuple(float(d) for d in self.log_D))
        object.__setattr__(self, "log_k", tuple(float(k) for k in self.log_k))
        object.__setattr__(self, "every", int(self.every))
        if self.final_time is not None:
            object.__setattr__(self, "final_time", float(self.final_time))
        assert len(self.log_D) == 5 and len(self.log_k) == 3

    def reference(self) -> "RunParams":
        """The same run with a fixed 1 s step."""
        return dataclasses.replace(self, dt_0=1.0, r=1.0, upper_bound=1.0, every=1)

    @property
    def is_reference(self) -> bool:
        return self == self.reference()

    def row(self) -> dict:
        return {
            **{f"logD{i + 1}": d for i, d in enumerate(self.log_D)},
            **{f"logk{i + 1}": k for i, k in enumerate(self.log_k)},
            "dt_0": self.dt_0,
            "r": self.r,
            "upper_bound": self.upper_bound,
            "every": self.every,
            "threshold": self.threshold,
            "final_time": self.final_time,
        }

    @classmethod
    def from_row(cls, row: dict[str, str]) -> "RunParams":
        return cls(
            log_D=[float(row[f"logD{i + 1}"]) for i in range(5)],
            log_k=[float(row[f"logk{i + 1}"]) for i in range(3)],
            dt_0=float(row["dt_0"]),
            r=float(row["r"]),
            upper_bound=float(row["upper_bound"]),
            every=int(row["every"]),
            threshold=float(row["threshold"]),
            final_time=float(row["final_time"]) if row["final_time"] else None,
        )


PARAM_FIELDS = list(RunParams().row())
# A case is identified by these, so the IC and the run can be reproduced exactly from a row
KEY_FIELDS = ["ic", "seed", "size", *PARAM_FIELDS]
SPECIES = range(1, 6)
RESULT_FIELDS = [
    # "ok", or "blew_up" when the solution is not finite (the other results are then empty)
    "status",
    "steps",
    # Physical time of the last step (s), the reaction end time unless final_time is set
    "end_time",
    # Wall clock time of the solve (s), noisy when other solves share the machine
    "solve_time",
    # Mass percentages of the species at the end and at the experiment time (6 h)
    *[f"p_end{i}" for i in SPECIES],
    *[f"p_6h{i}" for i in SPECIES],
    # Fitting loss, MSE of the 6 h mass percentages against P_TRUE
    "loss_6h",
    # Against the reference solve: its end time, the end time difference (%) and the largest
    # mass percentage difference (percentage points) at the end, at 6 h and over the whole run
    "ref_end_time",
    "dev_end_time_pct",
    "dev_end_pp",
    "dev_6h_pp",
    "dev_max_pp",
]
FIELDS = KEY_FIELDS + RESULT_FIELDS


def case_key(ic: str, seed: int, size: int, params: RunParams) -> tuple[str, ...]:
    """Key of a case as its row holds it, csv writes None as an empty string."""
    row = {"ic": ic, "seed": seed, "size": size, **params.row()}
    return tuple("" if row[f] is None else str(row[f]) for f in KEY_FIELDS)


def row_key(row: dict[str, str]) -> tuple[str, ...]:
    return tuple(row[f] for f in KEY_FIELDS)


def initial_condition(ic: str, seed: int, size: int) -> yag.SolutionState:
    if not particles.PARTICLE_ICS[ic].seeded and seed != 0:
        # The same arrangement under different seeds would only duplicate cases
        raise ValueError(f"Initial condition '{ic}' is not seeded, use seed 0")
    return particles.initial_condition(ic, size, seed, C1, C2)


def solve(ic: str, seed: int, size: int, params: RunParams) -> tuple[np.ndarray, np.ndarray, float]:
    """Mass percentages (N, 5) and physical times (N,) of every step, and the solve's wall time (s)."""
    if params.final_time is not None:
        brake = physical.fixed_time_brake(SCALES, final_time=params.final_time)
    else:
        brake = yag.reagent_mass_threshold_brake(threshold=params.threshold)

    config = yag.solver_config(
        discretization=particles.discretization(size),
        step=physical.clamped_geometric_step(
            SCALES, dt_0=params.dt_0, r=params.r, upper_bound=params.upper_bound, every=params.every
        ),
        brake=brake,
        # Masses on every step give the step count and the deviation over the whole run, the
        # total mass reducer is cheap next to a step
        capture=yag.capture_config(reducer=yag.reducers.total_mass(), trigger=yag.stride_trigger(every=1)),
    )
    model_params = physical.model_params(
        SCALES, D=[10**d for d in params.log_D], k=[10**k for k in params.log_k]
    )
    ic_state = initial_condition(ic, seed, size)

    start = time.perf_counter()
    result = yag.solve(config, ic_state, model_params)
    seconds = time.perf_counter() - start

    m, t = physical_result(result, SCALES)
    return 100 * m / m.sum(axis=1, keepdims=True), t, seconds


def at_time(t: np.ndarray, p: np.ndarray, time_: float) -> np.ndarray:
    """Mass percentages at a physical time, NaN past the last step."""
    if time_ > t[-1]:
        return np.full(p.shape[1], np.nan)
    return np.array([np.interp(time_, t, p[:, i]) for i in range(p.shape[1])])


def reference_path(ic: str, seed: int, size: int, params: RunParams):
    digest = hashlib.sha1(repr(case_key(ic, seed, size, params.reference())).encode()).hexdigest()[:12]
    return REFERENCE_DIR / f"{ic}_size{size}_seed{seed}_{digest}.npz"


def save_reference(path, t: np.ndarray, p: np.ndarray) -> None:
    frames = np.unique(np.concatenate([[0], np.geomspace(1, len(t) - 1, REFERENCE_FRAMES).round().astype(int)]))
    path.parent.mkdir(parents=True, exist_ok=True)
    # Written aside and renamed, so a reader never sees half a file
    partial = path.with_suffix(".partial.npz")
    np.savez_compressed(partial, t=t[frames], p=p[frames])
    partial.rename(path)


def load_reference(path) -> tuple[np.ndarray, np.ndarray]:
    with np.load(path) as f:
        return f["t"], f["p"]


def run_case(ic: str, seed: int, size: int, params: RunParams = RunParams(), deviation: bool = True) -> dict:
    """Solves a case, returns its CSV row (see FIELDS).

    With deviation the case is compared to its reference solve, which is loaded from
    REFERENCE_DIR or solved first. A reference case saves its own history there.
    """
    p, t, seconds = solve(ic, seed, size, params)
    row = {"ic": ic, "seed": seed, "size": size, **params.row(), "solve_time": seconds}

    if not np.isfinite(p).all():
        return row | {"status": "blew_up", "steps": len(t) - 1}

    path = reference_path(ic, seed, size, params)
    if params.is_reference:
        save_reference(path, t, p)

    p_6h = at_time(t, p, EXPERIMENT_TIME)
    row |= {
        "status": "ok",
        "steps": len(t) - 1,
        "end_time": t[-1],
        **{f"p_end{i}": v for i, v in zip(SPECIES, p[-1])},
        **{f"p_6h{i}": v for i, v in zip(SPECIES, p_6h)},
        "loss_6h": np.mean((p_6h - P_TRUE) ** 2),
    }
    if not deviation:
        return row

    if not path.exists():
        run_case(ic, seed, size, params.reference(), deviation=False)
    t_ref, p_ref = load_reference(path)

    # Steps of this run within the reference, compared with the reference interpolated to them
    overlap = t <= t_ref[-1]
    p_ref_on_t = np.stack([np.interp(t[overlap], t_ref, p_ref[:, i]) for i in range(5)], axis=1)
    return row | {
        "ref_end_time": t_ref[-1],
        "dev_end_time_pct": 100 * (t[-1] - t_ref[-1]) / t_ref[-1],
        "dev_end_pp": np.abs(p[-1] - p_ref[-1]).max(),
        "dev_6h_pp": np.abs(p_6h - at_time(t_ref, p_ref, EXPERIMENT_TIME)).max(),
        "dev_max_pp": np.abs(p[overlap] - p_ref_on_t).max(),
    }


def load_runs(path=RUNS_PATH) -> list[dict[str, str]]:
    return load_rows(path)


def run_cases(
        cases: Sequence[tuple[str, int, int, RunParams]],
        path=RUNS_PATH,
        workers: int = WORKERS) -> None:
    """Runs the (ic, seed, size, params) cases not yet in the CSV at path, one row per finished case.

    The reference solves the cases need run first, so no two cases solve the same reference.
    """
    done = {row_key(row) for row in load_rows(path)}
    todo = list(dict.fromkeys(c for c in cases if case_key(*c) not in done))

    # References of the remaining cases, solved (and recorded) first
    references = list(dict.fromkeys(
        (ic, seed, size, params.reference())
        for ic, seed, size, params in todo
        if params.is_reference or not reference_path(ic, seed, size, params).exists()
    ))
    rest = [c for c in todo if c not in references]

    with csv_appender(path, FIELDS) as append, tqdm(total=len(references) + len(rest), desc="cases") as bar:
        def record(case, row):
            # A reference may be solved again only for its history, its row is then kept as is
            if case_key(*case) not in done:
                done.add(case_key(*case))
                append(row)
            bar.update()

        if references:
            bar.set_postfix_str(f"{len(references)} references first")
        run_batch(run_case, references, record, workers)
        bar.set_postfix_str("")
        run_batch(run_case, rest, record, workers)
