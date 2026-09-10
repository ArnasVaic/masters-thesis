# Collection of initial conditions

import numpy as np
from yag_model import Discretization, SolutionState

def random_squares(d: Discretization, n: int, m: int, c1_0: float, c2_0: float):
    return random_rectangles(d, (n, n), m, c1_0, c2_0)

def random_rectangles(
        d: Discretization, 
        subdivision: tuple[int, int],
        rect_cnt: int,
        c1_0: np.float64, 
        c2_0: np.float64) -> SolutionState:

    H, W = d.mesh_res_y, d.mesh_res_x
    nx, ny = subdivision

    assert W % nx == 0
    assert H % ny == 0

    rect_w = W // nx
    rect_h = H // ny

    c1 = np.zeros((H, W), dtype=float)
    occupied = np.zeros((H, W), dtype=bool)

    rng = np.random.default_rng()

    # Pick subdivision blocks without replacement
    blocks = rng.choice(nx * ny, size=rect_cnt, replace=False)

    for block in blocks:
        bx, by = block % nx, block // nx

        x0 = bx * rect_w
        y0 = by * rect_h

        c1[y0:y0 + rect_h, x0:x0 + rect_w] = c1_0
        occupied[y0:y0 + rect_h, x0:x0 + rect_w] = True

    c2 = (~occupied) * c2_0

    c3 = np.zeros_like(c1)
    c4 = np.zeros_like(c1)
    c5 = np.zeros_like(c1)

    return to_solution_state(d, [c1, c2, c3, c4, c5])

def perlin_based(d: Discretization, n: int, t: float, c1_0: float, c2_0: float) -> SolutionState:
    return perlin_based_rectangles(d, n, n, t, c1_0, c2_0)

def perlin_based_rectangles(d: Discretization, n: int, m: int, t: float, c1_0: float, c2_0: float) -> SolutionState:

    assert 0 <= t <= 1

    noise = perlin_noise(
        d.mesh_res_x,
        d.mesh_res_y,
        n,
        m,
    )

    # Threshold such that approximately t fraction is assigned to c1
    threshold = np.quantile(noise, 1 - t)

    mask = noise >= threshold

    c1 = np.where(mask, c1_0, 0.0)
    c2 = np.where(mask, 0.0, c2_0)

    zeros = np.zeros_like(noise)

    return to_solution_state(
        d,
        [
            c1,
            c2,
            zeros,
            zeros,
            zeros,
        ],
    )


def perlin_noise(w: int, h: int, n: int, m: int) -> np.ndarray:
    # Random unit gradient vectors at lattice points
    angles = np.random.uniform(0, 2 * np.pi, size=(m + 1, n + 1))
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

def to_solution_state(d: Discretization, c: list[np.ndarray]) -> SolutionState:
    s = SolutionState(d.mesh_res_y, d.mesh_res_x)
    for i in range(5):
        s[i] = c[i]
    return s