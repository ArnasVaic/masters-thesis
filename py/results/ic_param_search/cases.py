# Initial conditions of the parameter search, all 16 x 16 particles of 1 um (16 x 16 um)
#
# Random squares and Perlin noise: the n = 16 trials whose reaction end time is closest to the
# first quartile, the median and the third quartile of their distribution, as printed by
# results/reaction_end_time_based_on_size/quartile_examples.py. The trial numbers are hardcoded
# so the search does not need the end time data. Checkerboard: the ideal initial condition of
# the larger spaces chapter for n = 16. It is offset by half a particle, so its outer particles
# are cut in half, and being periodic it gives the same result as the 1 um checkerboard of
# yag_utils.optimization.
#
# The arrangements are rebuilt from the same seeds as in random_squares_end_time.py, only the
# concentrations are the physical ones (Al2O3 and by default 3/5 of it, dimensionless 1 and 0.6).
#
# IC_PARAM_SEARCH_RATIO sets the Y2O3 / Al2O3 molar ratio of the mixture, through the Y2O3
# concentration (the arrangement, and so the area of each reagent, stays the same):
#   stoichiometric   5:3, both reagents react fully (default)
#   experiment       the ratio the experimental mass percentages P_TRUE imply (about 5:2.79)
#   a:b              any other, e.g. 5:2.9
# Every ratio other than 5:3 keeps its studies apart, in data-<ratio>/ next to data/.

import os
from pathlib import Path
from typing import Callable, NamedTuple

import numpy as np
import optuna
from optuna.storages import JournalStorage
from optuna.storages.journal import JournalFileBackend
from optuna.trial import TrialState
import yag_model as yag
from yag_model import Discretization, ModelParameters, SolutionState
from yag_utils import initial_conditions as ics
from yag_utils import particles, physical
from yag_utils.constants import AL2O3_CONCENTRATION, P_TRUE
from yag_utils.mass import field_masses, total_mass
from yag_utils.optimization import DEFAULT_SCALES, experiment_config
from yag_utils.scaling import to_dimensionless
from yag_utils.paths import repo_root
from yag_utils.stoichiometry import y2o3_per_al2o3

SIZE = 16
PARTICLE_SIZE = 1e-6  # m
# Same mesh as the end time study. 10 is about 6 times faster and gives the same random squares
# and checkerboard, Perlin boundaries are only drawn coarser.
DEFAULT_CELLS_PER_PARTICLE = 20



def _ratio(value: str) -> tuple[str, float]:
    """Name (used in the data directory) and Y2O3 / Al2O3 molar ratio of IC_PARAM_SEARCH_RATIO."""
    match value.strip().lower():
        case "stoichiometric" | "5:3":
            return "stoichiometric", 3 / 5
        case "experiment":
            return "experiment", y2o3_per_al2o3(P_TRUE)
        case other:
            try:
                al2o3, y2o3 = (float(x) for x in other.split(":"))
            except ValueError:
                raise SystemExit(
                    f"IC_PARAM_SEARCH_RATIO={value!r}: give stoichiometric, experiment or Al2O3:Y2O3 like 5:2.9"
                ) from None
            if al2o3 <= 0 or y2o3 <= 0:
                raise SystemExit(f"IC_PARAM_SEARCH_RATIO={value!r}: both parts must be positive")
            return f"{al2o3:g}-{y2o3:g}", y2o3 / al2o3


RATIO_NAME, Y2O3_PER_AL2O3 = _ratio(os.environ.get("IC_PARAM_SEARCH_RATIO", "stoichiometric"))

SCALES = DEFAULT_SCALES
C1 = SCALES.dimensionless_concentration(AL2O3_CONCENTRATION)
C2 = SCALES.dimensionless_concentration(Y2O3_PER_AL2O3 * AL2O3_CONCENTRATION)

# Search space, log10 of D in m^2/s and of k in m^3/(mol s). Wide on purpose, the limits come
# from where the solver or the data stop telling anything apart (checked on the 20 cell mesh):
#   D below 1e-20: nothing reacts in 6 h. Above about 1e-14 the result no longer depends on D
#     (the domain mixes faster than it reacts), so beyond 1e-12 there is only more flat loss and
#     ever larger diffusion numbers for the solver.
#   k below 1e-12: nothing reacts. With all k at 1e-7 about 96% is YAG after 6 h (the experiment
#     has 12%) and the solver is still sound for every D. From 10^-6.5 the explicit reaction term
#     can overshoot with dt = 1 s, depending on D and the arrangement: the solution blows up or
#     ends with negative concentrations. solve() reports the lowest concentration and such trials
#     fail, so the sampler learns to stay away. Fits close to the upper k limit need a smaller dt.
# The earlier fit (FITTED_LOG_D/K) lies inside. A fitted value at a limit (collect_params.py
# flags those) means that limit should move.
LOG_D_RANGE = (-20.0, -12.0)
LOG_K_RANGE = (-12.0, -6.0)
# Fitted values closer than this to a limit are flagged
EDGE_MARGIN = 0.1


def at_edge(key: str, value: float) -> bool:
    """Whether a fitted logD*/logk* value lies within EDGE_MARGIN of its search limit."""
    lo, hi = LOG_D_RANGE if key.startswith("logD") else LOG_K_RANGE
    return value - lo < EDGE_MARGIN or hi - value < EDGE_MARGIN

# Everything the search writes, one directory per case, data/ for 5:3 and data-<ratio>/ for any
# other ratio. IC_PARAM_SEARCH_DATA moves it elsewhere, e.g. to a scratch file system of the
# cluster or a throwaway directory for a test run (then it is up to you to keep ratios apart).
_DEFAULT_DATA_DIR = repo_root() / "py" / "results" / "ic_param_search" / (
    "data" if RATIO_NAME == "stoichiometric" else f"data-{RATIO_NAME}"
)
DATA_DIR = Path(os.environ.get("IC_PARAM_SEARCH_DATA", _DEFAULT_DATA_DIR))


class Case(NamedTuple):
    ic: str  # Builder name: random_rectangles, perlin or checkerboard
    trial: int | None  # Seed of the end time study, None for deterministic arrangements
    quantile: str | None  # Which end time quantile the trial represents
    build: Callable[[Discretization], SolutionState]


def _seeded(ic: str, trial: int) -> Callable[[Discretization], SolutionState]:
    def build(disc: Discretization) -> SolutionState:
        # The same seed as the trial in random_squares_end_time.py
        rng = np.random.default_rng([SIZE, trial])
        return particles.PARTICLE_ICS[ic].build(disc, SIZE, C1, C2, rng)

    return build


def _checkerboard(disc: Discretization) -> SolutionState:
    # Blocks of half a particle mirrored into 1 um particles, with the outer ones cut in half:
    # the n = 16 case of the ideal initial condition figure (15 whole particles and two halves
    # per side, offset by half a particle from the random squares grid)
    return ics.mirrored_checkerboard(disc, C1, C2, (2 * SIZE, 2 * SIZE))


CASES: dict[str, Case] = {
    "checkerboard": Case("checkerboard", None, None, _checkerboard),
    "random_squares_q1": Case("random_rectangles", 814, "q1", _seeded("random_rectangles", 814)),
    "random_squares_median": Case("random_rectangles", 287, "median", _seeded("random_rectangles", 287)),
    "random_squares_q3": Case("random_rectangles", 383, "q3", _seeded("random_rectangles", 383)),
    "perlin_q1": Case("perlin", 2, "q1", _seeded("perlin", 2)),
    "perlin_median": Case("perlin", 12, "median", _seeded("perlin", 12)),
    "perlin_q3": Case("perlin", 18, "q3", _seeded("perlin", 18)),
}


# A solution dipping below this (dimensionless, c1 = 1) is not a solution: too large k (and D)
# make the explicit reaction term overshoot, which can end with finite but negative concentrations
NEGATIVE_TOLERANCE = -1e-6


def solve(params: ModelParameters, disc: Discretization, ic: SolutionState) -> tuple[np.ndarray, float]:
    """Mass percentages of the species after the 6 hour experiment from ic, with physical
    parameters, and the lowest concentration anywhere in that last frame."""
    capture = yag.capture_config(
        reducer=yag.reducers.concentration_field(),
        trigger=yag.last_frame_trigger(),
        sink=yag.in_memory_sink(capacity=1),
    )
    # A config (and its sink) per solve, they must not be shared between concurrent solves
    result = yag.solve(experiment_config(disc, SCALES, capture), ic, to_dimensionless(params, SCALES))
    fields, _ = result.all()
    p_pred = 100 * field_masses(fields, disc)[0] / total_mass(ic, disc)
    return p_pred, float(np.min(fields))


def discretization(cells_per_particle: int = DEFAULT_CELLS_PER_PARTICLE) -> Discretization:
    """Dimensionless mesh of SIZE x SIZE particles."""
    n = cells_per_particle * SIZE
    return physical.discretization(
        SCALES, physical_size=(SIZE * PARTICLE_SIZE, SIZE * PARTICLE_SIZE), mesh_resolution=(n, n)
    )


def case_dir(name: str) -> Path:
    return DATA_DIR / name


def journal_path(name: str) -> Path:
    """Optuna journal of the case. *.log is git-ignored, keep it on the cluster for the dashboard."""
    return case_dir(name) / "optuna-journal.log"


def best_params_path(name: str) -> Path:
    return case_dir(name) / "best_params.csv"


# Columns of best_params.csv and of the merged fitted_params.csv
SUMMARY_FIELDS = (
    ["case", "ic", "seed_trial", "quantile", "y2o3_per_al2o3", "cells_per_particle", "n_complete", "n_fail", "best_trial", "loss"]
    + [f"logD{i}" for i in range(1, 6)]
    + [f"logk{i}" for i in range(1, 4)]
    + [f"p{i}" for i in range(1, 6)]
    + ["mean_solve_s", "at_edge"]
)


def storage(name: str) -> JournalStorage:
    journal_path(name).parent.mkdir(parents=True, exist_ok=True)
    return JournalStorage(JournalFileBackend(str(journal_path(name))))


def summary_row(name: str, study: optuna.Study) -> dict | None:
    """Best trial of the case's study as a row of SUMMARY_FIELDS, None before any finished trial."""
    trials = study.get_trials(deepcopy=False)
    complete = [t for t in trials if t.state == TrialState.COMPLETE]
    if not complete:
        return None

    best = min(complete, key=lambda t: t.value)
    case = CASES[name]
    row = {
        "case": name,
        "ic": case.ic,
        "seed_trial": "" if case.trial is None else case.trial,
        "quantile": case.quantile or "",
        # Studies from before the ratio was configurable did not store it, they all ran 5:3
        "y2o3_per_al2o3": study.user_attrs.get("y2o3_per_al2o3", 3 / 5),
        "cells_per_particle": study.user_attrs.get("cells_per_particle", ""),
        "n_complete": len(complete),
        "n_fail": sum(t.state == TrialState.FAIL for t in trials),
        "best_trial": best.number,
        "loss": best.value,
        "mean_solve_s": float(np.mean([t.user_attrs.get("solve_s", np.nan) for t in complete])),
    }
    row.update({key: best.params[key] for key in SUMMARY_FIELDS if key in best.params})
    row.update({f"p{i}": p for i, p in enumerate(best.user_attrs["p_pred"], 1)})
    # Parameters within EDGE_MARGIN of a search limit, e.g. "logD3 logk1", empty if none
    row["at_edge"] = " ".join(k for k, v in best.params.items() if at_edge(k, v))
    return row
