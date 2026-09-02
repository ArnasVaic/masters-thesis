# Collection of initial conditions

import numpy as np
from yag_model import Discretization, SolutionState

def rand_sq_ic(d: Discretization, n: int, m: int, c1_0: np.float64, c2_0: np.float64):
    return random_rect_ic(d, (n, n), )

def random_rect_ic(
        d: Discretization, 
        subdivision: tuple[int, int],
        rect_cnt: int,
        c1_0: np.float64, 
        c2_0: np.float64) -> SolutionState:

    H, W = d.mesh_res_y, d.mesh_res_x

    assert(d.mesh_res_x % subdivision[0] == 0)
    rect_w = d.mesh_res_x / subdivision[0]

    assert(d.mesh_res_y % subdivision[1] == 0)
    rect_h = d.mesh_res_y / subdivision[1]

    c1 = np.zeros((H, W), dtype=float)
    occupied = np.zeros((H, W), dtype=bool)

    rng = np.random.default_rng()

    for _ in range(rect_cnt):
        while True:
            start_x = rng.integers(0, W - rect_w + 1)
            start_y = rng.integers(0, H - rect_h + 1)

            region = occupied[
                start_y:start_y + rect_h,
                start_x:start_x + rect_w
            ]

            # Only place it if it doesn't overlap anything
            if not region.any():
                occupied[
                    start_y:start_y + rect_h,
                    start_x:start_x + rect_w
                ] = True

                c1[
                    start_y:start_y + rect_h,
                    start_x:start_x + rect_w
                ] = c1_0

                break

    c2 = (~occupied) * c2_0

    c3, c4, c5 = np.zeros_like(c1), np.zeros_like(c1), np.zeros_like(c1)
    return to_solution_state(d, [c1, c2, c3, c4, c5])

def to_solution_state(d: Discretization, c: list[np.ndarray]) -> SolutionState:
    s = SolutionState(d.mesh_res_y, d.mesh_res_x)
    for i in range(5):
        s[i] = c[i]
    return s