# %%

import numpy as np
import yag_model as ym
from core import solve, MOLAR_MASSES, Scales

import matplotlib.pyplot as plt
import matplotlib as mpl

# %%
def build_cfg(mp: ym.ModelParameters, _: Scales):
    s = np.array([
        [-5, 0, 0],
        [-3, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
        [2, 0, 0]
    ])
    disc = ym.Discretization(1.0, 1.0, 40, 40)
    ic = ym.build_checkerboard_initial_condition(disc, 5.0, 3.0)
    ts = ym.FixedTimeStep(0.0001)
    br = ym.FixedStepBrake(100000)
    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.InMemoryFrameCapture(1000, disc)
    return [ s, disc, mp, ts, br, cpt, cp, ic ]

# %%

mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [10.0, 5.0, 1.0]
)

# %%
scales = Scales(1.0, 1.0, 1.0)
_, disc, _, _, _, _, cpt, ic = solve(mp, build_cfg, scales)
# %%

plt.imshow(cpt[0])