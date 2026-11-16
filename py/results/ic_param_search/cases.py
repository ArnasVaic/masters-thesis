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
# concentrations are the physical ones (Al2O3 and 3/5 of it, dimensionless 1 and 0.6).

import os
from pathlib import Path
from typing import Callable, NamedTuple

import numpy as np
import optuna
from optuna.storages import JournalStorage
from optuna.storages.journal import JournalFileBackend
from optuna.trial import TrialState
from yag_model import Discretization, SolutionState
from yag_utils import initial_conditions as ics
from yag_utils import particles, physical
from yag_utils.constants import AL2O3_CONCENTRATION
from yag_utils.optimization import DEFAULT_SCALES
from yag_utils.paths import repo_root

SIZE = 16
PARTICLE_SIZE = 1e-6  # m
# Same mesh as the end time study. 10 is about 6 times faster and gives the same random squares
# and checkerboard, Perlin boundaries are only drawn coarser.
DEFAULT_CELLS_PER_PARTICLE = 20

SCALES = DEFAULT_SCALES
C1 = SCALES.dimensionless_concentration(AL2O3_CONCENTRATION)
C2 = SCALES.dimensionless_concentration(3 / 5 * AL2O3_CONCENTRATION)

# Search space, log10 of D in m^2/s and of k in m^3/(mol s), as in find_params.py
LOG_D_RANGE = (-16.0, -14.0)
LOG_K_RANGE = (-9.0, -7.0)

# Everything the search writes, one directory per case. IC_PARAM_SEARCH_DATA moves it elsewhere,
# e.g. to a scratch file system of the cluster or a throwaway directory for a test run.
DATA_DIR = Path(os.environ.get("IC_PARAM_SEARCH_DATA", repo_root() / "py" / "results" / "ic_param_search" / "data"))


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
    ["case", "ic", "seed_trial", "quantile", "cells_per_particle", "n_complete", "n_fail", "best_trial", "loss"]
    + [f"logD{i}" for i in range(1, 6)]
    + [f"logk{i}" for i in range(1, 4)]
    + [f"p{i}" for i in range(1, 6)]
    + ["mean_solve_s"]
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
        "cells_per_particle": study.user_attrs.get("cells_per_particle", ""),
        "n_complete": len(complete),
        "n_fail": sum(t.state == TrialState.FAIL for t in trials),
        "best_trial": best.number,
        "loss": best.value,
        "mean_solve_s": float(np.mean([t.user_attrs.get("solve_s", np.nan) for t in complete])),
    }
    row.update({key: best.params[key] for key in SUMMARY_FIELDS if key in best.params})
    row.update({f"p{i}": p for i, p in enumerate(best.user_attrs["p_pred"], 1)})
    return row
