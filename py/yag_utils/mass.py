# Masses of species, from states or captured frames

import numpy as np
from yag_model import ALL, MOLAR_MASSES, Discretization, SolutionState, channel_indices, quantity


def mass(state: SolutionState, channel_index: int, disc: Discretization) -> float:
    return MOLAR_MASSES[channel_index] * quantity(state[channel_index], disc)


def total_mass(state: SolutionState, disc: Discretization) -> float:
    """Mass of all species together."""
    return sum(mass(state, i, disc) for i in range(5))


def field_masses(fields: np.ndarray, disc: Discretization, channels: int = ALL) -> np.ndarray:
    """Per-channel masses of concentration field frames (N, C, H, W) -> (N, C).

    Same values the total_mass reducer would have captured.
    """
    molar_masses = MOLAR_MASSES[channel_indices(channels)]
    return fields.sum(axis=(-2, -1)) * disc.dx * disc.dy * molar_masses
