# %%

import numpy as np

import core.constants as constants
from core.core import Scales, solve
from yag_model import Discretization, FixedStepBrake, FixedTimeStep, InMemoryFrameCapture, ModelParameters, StrideCaptureTrigger
from core.initial_conditions import random_squares
import matplotlib.pyplot as plt
# %%

def build_cfg(mp: ModelParameters, _: Scales):
    s = constants.S
    d = Discretization(1.0, 1.0, 160, 160)
    ic = random_squares(d, 8, int(8**2/2), 5.0, 3.0)
    ts = FixedTimeStep(dt=1e-4)
    br = FixedStepBrake(steps=int(1e5))
    cpt = StrideCaptureTrigger(stride=int(1e4))
    cp = InMemoryFrameCapture(capacity=int(1e4), disc=d)
    return [ s, d, mp, ts, br, cpt, cp, ic ]

mp = ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [10.0, 5.0, 1.0]
)

# %%
scales = Scales(1.0, 1.0, 1.0)
_, d, _, _, _, _, cpt, ic = solve(mp, build_cfg, scales)

# %%

frame = 6
plt.imshow(cpt.c_history[2, frame, :, :])