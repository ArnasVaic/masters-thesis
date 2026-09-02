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
    ic = ym.build_checkerboard_initial_condition(disc, 50.0, 30.0)
    ts = ym.FixedTimeStep(0.0001)
    br = ym.FixedStepBrake(100000)
    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.InMemoryFrameCapture(1000, disc)
    return [ s, disc, mp, ts, br, cpt, cp, ic ]

mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [10.0, 5.0, 1.0]
)

# %%
scales = Scales(1.0, 1.0, 1.0)
_, disc, _, _, _, _, cpt, ic = solve(mp, build_cfg, scales)
# %%
# Return indicator of "symmetry" along
# the vertical axis. The maximum difference 
# between mesh cell values at the same x
# but mirror y (along mid point) values
frame = 900
c = cpt.c_history

# Mirror along both spatial axes
cf = c[:, :, ::-1, ::-1]
cdiff = cf - c

fig, axes = plt.subplots(1, 5, figsize=(20, 4))

for material in range(5):
    f = cdiff[material, frame, :, :]

    im = axes[material].imshow(f)
    axes[material].set_title(f"Material {material + 1}")
    axes[material].set_axis_off()

    fig.colorbar(im, ax=axes[material], shrink=0.8)

plt.tight_layout()
plt.show()

print("float64 precision ~15–16 decimal places")
print("local max diff:", np.max(cdiff[:, frame]))
print("global max diff:", np.max(cdiff))
# %%

# plt.imshow(c[4, frame, :, :])    