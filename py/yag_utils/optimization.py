# Parameter fitting against experimental mass fractions (1400C, 6 hours)

import numpy as np
import yag_model as yag
from yag_model import CaptureConfig, IResult, ModelParameters, SolutionState, SolverConfig

from .constants import P_TRUE
from .initial_conditions import checkerboard
from .mass import total_mass
from .scaling import Scales, to_dimensionless

DEFAULT_SCALES = Scales(L0=1e-6, C0=3.91e4, D_ref=1e-7)


def optimization_config(
        scales: Scales = DEFAULT_SCALES,
        capture: CaptureConfig | None = None) -> tuple[SolverConfig, SolutionState]:
    """Dimensionless config and initial condition of the 6 hour experiment.

    By default only the per-species mass of the last frame is captured.
    """
    L0, T0, C0 = scales.L0, scales.T0, scales.C0

    # Dimensionless discretization of a 1 um x 1 um domain
    disc = yag.discretization(mesh_resolution=(40, 40), physical_size=(1e-6 / L0, 1e-6 / L0))

    # Dimensionless concentration is preferred for numerical stability,
    # account for this by scaling reaction coefficients. Resulting mass
    # parts would be scaled by the same constant so when optimizing
    # parameters this doesn't matter much.
    ic = checkerboard(disc, 3.91e4 / C0, 3 / 5 * 3.91e4 / C0)

    if capture is None:
        capture = yag.capture_config(
            reducer=yag.reducers.total_mass(),
            trigger=yag.last_frame_trigger(),
            sink=yag.in_memory_sink(capacity=1),
        )

    config = yag.solver_config(
        discretization=disc,
        # We know the rough order of parameters so we can hardcode the timestep
        # because the simulation remains stable if this is used. Alternatively
        # time step could be chosen as a ratio dx^2 / D which would ensure comfortable
        # ADI solver cache constants and avoid numerical instabilities.
        step=yag.fixed_step(dt=1.0 / T0),
        # Concrete experiment time we're optimizing for is 6 hours
        brake=yag.fixed_time_brake(final_time=6 * 60 * 60 / T0),
        capture=capture,
    )

    return config, ic


def predicted_mass_percent(result: IResult, ic: SolutionState) -> np.ndarray:
    """Mass percentage of each species in the last frame of a total_mass result."""
    assert result.metadata.reducer == "total_mass" and result.channels == yag.ALL

    masses = result.read(len(result) - 1, len(result)).values[0]
    return 100 * masses / total_mass(ic, result.metadata.discretization)


def loss(p_pred: np.ndarray) -> float:
    return float(np.mean((p_pred - P_TRUE) ** 2))


def evaluate(params: ModelParameters, scales: Scales = DEFAULT_SCALES) -> np.ndarray:
    """Solve the experiment with physical parameters, return predicted mass percentages."""
    config, ic = optimization_config(scales)
    result = yag.solve(config, ic, to_dimensionless(params, scales))
    return predicted_mass_percent(result, ic)
