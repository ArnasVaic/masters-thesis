# %%

import numpy as np

from py.core.core import Scales, solve
from yag_model import Discretization, FixedStepBrake, FixedTimeStep, InMemoryFrameCapture, ModelParameters, StrideCaptureTrigger
from py.core.initial_conditions import rand_sq_ic

def build_cfg(mp: ModelParameters, _: Scales):
    s = np.array([
        [-5, 0, 0],
        [-3, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
        [2, 0, 0]
    ])
    disc = Discretization(1.0, 1.0, 160, 160)
    ic = rand_sq_ic(disc, 8, 8**2/2, 5.0, 3.0)
    ts = FixedTimeStep(0.0001)
    br = FixedStepBrake(100000)
    cpt = StrideCaptureTrigger(100)
    cp = InMemoryFrameCapture(1000, disc)
    return [ s, disc, mp, ts, br, cpt, cp, ic ]

mp = ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [10.0, 5.0, 1.0]
)

# %%
scales = Scales(1.0, 1.0, 1.0)
_, disc, _, _, _, _, cpt, ic = solve(mp, build_cfg, scales)