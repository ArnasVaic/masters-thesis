# Collection of initial conditions
#
# All functions place reagent c1 (Al2O3) and c2 (Y2O3) on the mesh,
# products (YAM, YAP, YAG) start at zero.

import numpy as np
import yag_model
from yag_model import Discretization, SolutionState


def checkerboard(disc: Discretization, c1: float, c2: float) -> SolutionState:
    return yag_model.checkerboard_initial_condition(disc, c1, c2)


def random_squares(
        disc: Discretization,
        c1: float,
        c2: float,
        n: int = 4,
        m: int | None = None,
        rng: np.random.Generator | None = None) -> SolutionState:
    """Split the mesh into n x n blocks, fill m random blocks (half by default) with c1, rest with c2."""
    return random_rectangles(disc, c1, c2, (n, n), m, rng)


def random_rectangles(
        disc: Discretization,
        c1: float,
        c2: float,
        subdivision: tuple[int, int],
        rect_cnt: int | None = None,
        rng: np.random.Generator | None = None) -> SolutionState:

    H, W = disc.shape
    nx, ny = subdivision

    assert W % nx == 0
    assert H % ny == 0

    if rect_cnt is None:
        rect_cnt = nx * ny // 2

    rect_w = W // nx
    rect_h = H // ny

    c1_field = np.zeros((H, W), dtype=float)
    occupied = np.zeros((H, W), dtype=bool)

    rng = rng or np.random.default_rng()

    # Pick subdivision blocks without replacement
    blocks = rng.choice(nx * ny, size=rect_cnt, replace=False)

    for block in blocks:
        bx, by = block % nx, block // nx

        x0 = bx * rect_w
        y0 = by * rect_h

        c1_field[y0:y0 + rect_h, x0:x0 + rect_w] = c1
        occupied[y0:y0 + rect_h, x0:x0 + rect_w] = True

    c2_field = (~occupied) * c2

    return to_solution_state(disc, [c1_field, c2_field])


def perlin_based(
        disc: Discretization,
        c1: float,
        c2: float,
        n: int = 4,
        t: float = 0.5,
        rng: np.random.Generator | None = None) -> SolutionState:
    return perlin_based_rectangles(disc, c1, c2, n, n, t, rng)


def perlin_based_rectangles(
        disc: Discretization,
        c1: float,
        c2: float,
        n: int,
        m: int,
        t: float,
        rng: np.random.Generator | None = None) -> SolutionState:
    """Threshold Perlin noise on an n x m lattice so roughly a t fraction of the mesh holds c1."""

    assert 0 <= t <= 1

    noise = perlin_noise(disc.nx, disc.ny, n, m, rng)

    # Threshold such that approximately t fraction is assigned to c1
    threshold = np.quantile(noise, 1 - t)

    mask = noise >= threshold

    return to_solution_state(disc, [
        np.where(mask, c1, 0.0),
        np.where(mask, 0.0, c2),
    ])


def perlin_noise(w: int, h: int, n: int, m: int, rng: np.random.Generator | None = None) -> np.ndarray:
    rng = rng or np.random.default_rng()

    # Random unit gradient vectors at lattice points
    angles = rng.uniform(0, 2 * np.pi, size=(m + 1, n + 1))
    gradients = np.stack((np.cos(angles), np.sin(angles)), axis=-1)

    # Coordinates in lattice space
    y = np.linspace(0, m, h, endpoint=False)
    x = np.linspace(0, n, w, endpoint=False)
    yy, xx = np.meshgrid(y, x, indexing="ij")

    # Cell coordinates
    x0 = xx.astype(int)
    y0 = yy.astype(int)

    # Position inside each cell
    dx = xx - x0
    dy = yy - y0

    # Fade function
    def fade(t):
        return 6 * t**5 - 15 * t**4 + 10 * t**3

    u = fade(dx)
    v = fade(dy)

    # Gradient vectors at the four corners
    g00 = gradients[y0,     x0]
    g10 = gradients[y0,     x0 + 1]
    g01 = gradients[y0 + 1, x0]
    g11 = gradients[y0 + 1, x0 + 1]

    # Dot products with displacement vectors
    d00 = g00[..., 0] * dx       + g00[..., 1] * dy
    d10 = g10[..., 0] * (dx - 1) + g10[..., 1] * dy
    d01 = g01[..., 0] * dx       + g01[..., 1] * (dy - 1)
    d11 = g11[..., 0] * (dx - 1) + g11[..., 1] * (dy - 1)

    # Bilinear interpolation
    nx0 = d00 + u * (d10 - d00)
    nx1 = d01 + u * (d11 - d01)

    return nx0 + v * (nx1 - nx0)


def to_solution_state(disc: Discretization, fields: list[np.ndarray]) -> SolutionState:
    """State with the given leading fields, remaining channels are zero."""
    s = SolutionState(disc)
    for i, field in enumerate(fields):
        s[i] = field
    return s
