# %%

import time
import numpy as np
import yag_model as ym
import matplotlib.pyplot as plt

# %%

MOLAR_MASSES = [ 102.0, 225.8, 553.58, 163.89, 593.62 ]

def build_cfg(mp: ym.ModelParameters):
    disc = ym.Discretization(1.0, 1.0, 40, 40)
    ic = ym.build_checkerboard_initial_condition(disc, 5.0, 3.0)
    # q0 = ym.reagent_quantity(ic, disc)
    # ts = ym.ClampedGeometricReagentQuantityThresholdStep(1000, 0.0001, 2.0, 0.01, 0.0001, 0.03, q0, disc)
    ts = ym.FixedTimeStep(0.0001)
    # Fitting to 6hrs so need to continue further
    # br = ym.TimeBrake(60 * 60 / 10)
    br = ym.FixedStepBrake(100000)
    #cpt = ym.LastFrameCaptureTrigger(br)
    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.QuantityCapture(1000, disc)
    # cp = ym.InMemoryFrameCapture(1000, disc)
    return [ disc, mp, ts, br, cpt, cp, ic ]

def solve(mp, build_cfg):
    cfg = build_cfg(mp)
    ym.solve(*cfg)
    return cfg

# %%

mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [10.0, 5.0, 2.0]
)

_, _, _, _, _, cpt, _ = solve(mp, build_cfg)

# %%

m_sum = np.zeros_like(cpt.q_history[0])
for i in range(5):
    m = cpt.q_history[i] * MOLAR_MASSES[i]
    m_sum += m
    plt.plot(cpt.t_history, m, label =f'$c_{i+1}$')

plt.plot(cpt.t_history, m_sum, label='sum')
plt.legend()

# %%

# material = 0
# frame = 999

# img = cpt.c_history[material, frame, :, :]

# assert np.min(img) >= 0

# plt.imshow(img, label =f'$c_{material+1}$')

# t = cpt.t_history[frame]
# total_seconds = int(t)
# hours = total_seconds // 3600
# minutes = (total_seconds % 3600) // 60
# seconds = total_seconds % 60

# formatted = f"{hours}:{minutes:02d}:{seconds:02d}"

# plt.title(formatted)
# plt.colorbar()
