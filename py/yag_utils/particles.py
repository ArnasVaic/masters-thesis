# Square particle arrangements of the size and parameter search studies
#
# A case of size n is an n x n grid of particles (squares) of 20 x 20 mesh cells each.
# Lengths are dimensionless like D and k: a particle is 0.5 x 0.5, so 0.5 um with
# L0 = 1 um (the length scale of DEFAULT_SCALES). Sizes in metres make D * dt / dx^2 ~ 1e7
# and the solution blows up.

from typing import Callable, NamedTuple

import numpy as np
import yag_model as yag
from yag_model import Discretization, SolutionState

from . import initial_conditions as ics

PARTICLE_CELLS = 20
PARTICLE_SIZE = 0.5


def discretization(size: int) -> Discretization:
    """Mesh of size x size particles."""
    return yag.discretization(
        mesh_resolution=(PARTICLE_CELLS * size, PARTICLE_CELLS * size),
        physical_size=(PARTICLE_SIZE * size, PARTICLE_SIZE * size),
    )


class ParticleIC(NamedTuple):
    # Called as build(discretization, size, c1, c2, rng)
    build: Callable
    # Seeded builders give a different arrangement per seed, the others always the same one
    seeded: bool


# The builders fill about half of the particles with c1, the rest with c2
PARTICLE_ICS = {
    "random_rectangles": ParticleIC(
        lambda disc, size, c1, c2, rng: ics.random_rectangles(disc, c1, c2, (size, size), size**2 // 2, rng=rng),
        seeded=True,
    ),
    # One Perlin lattice cell per particle, so blobs are about one particle across
    "perlin": ParticleIC(
        lambda disc, size, c1, c2, rng: ics.perlin_based(disc, c1, c2, n=size, t=0.5, rng=rng),
        seeded=True,
    ),
    # The perfect arrangement, a 2x2 checkerboard of particles mirrored along x and y
    "checkerboard": ParticleIC(
        lambda disc, size, c1, c2, rng: ics.mirrored_checkerboard(disc, c1, c2, (size, size)),
        seeded=False,
    ),
}


def initial_condition(ic: str, size: int, seed: int, c1: float, c2: float) -> SolutionState:
    """Arrangement `ic` of size x size particles holding concentrations c1 and c2."""
    # Seeded by (size, seed) so a case always gets the same arrangement
    return PARTICLE_ICS[ic].build(discretization(size), size, c1, c2, np.random.default_rng([size, seed]))
