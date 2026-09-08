# Collection of initial conditions

import numpy as np
from yag_model import Discretization, SolutionState

def rand_sq_ic(d: Discretization, n: int, m: int, c1_0: np.float64, c2_0: np.float64):
    return random_rect_ic(d, (n, n), m, c1_0, c2_0)

def random_rect_ic(
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

def perlin_ic(d: Discretization) -> SolutionState:
    pass

def to_solution_state(d: Discretization, c: list[np.ndarray]) -> SolutionState:
    s = SolutionState(d.mesh_res_y, d.mesh_res_x)
    for i in range(5):
        s[i] = c[i]
    return s