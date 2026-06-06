# %%
import numpy as np
import yag_model as ym
from core import solve, MOLAR_MASSES, build_optimization_config, config_info, Scales
import matplotlib.pyplot as plt

def build_config(mp: ym.ModelParameters, scales):
    disc, mp_nd, ts, br, _, _, ic = build_optimization_config(mp, scales)

    # ts = ym.FixedTimeStep(0.00001)
    # br = ym.TimeBrake(1.0)

    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.InMemoryFrameCapture(300, disc)
    return [disc, mp_nd, ts, br, cpt, cp, ic]

# %% Solver config

scales = Scales(L0=1e-6, C0 = 3.91e4, D_ref=1e-7)
# logD = [
#     -18.705183683895132,
#     -17.98902755136912,
#     -18.99733614615828
#     ,-17.91290362917506,
#     -17.214973064752815
# ]

# logK = [
#     -6.125272554342815,-7.900833099916853,-7.856737838978788
# ]

mp = ym.ModelParameters(
    [ 1e-15 ] * 5,
    [ 1e-8 ] * 3
)

cfg = build_config(mp, scales)
config_info(cfg, scales)

# %% Solve
ym.solve(*cfg)

# %%

disc, mp_nd, ts, br, cpt, cp, ic = cfg

m0 = \
    MOLAR_MASSES[0] * ym.quantity(ic[0], disc) + \
    MOLAR_MASSES[1] * ym.quantity(ic[1], disc)

ELEMENT_NAME_STRINGS = [
    '$Al_2O_3$','$Y_2O_3$','$YAM$','$YAP$','$YAG$'
]

m_sum = np.zeros((cp.size))
for i in range(5):
    qi = np.array([ ym.quantity(cp.c_history[i, f, :, :], disc) for f in range(cp.size) ])
    m = qi * MOLAR_MASSES[i]
    m_sum += m
    plt.plot(cp.t_history[:cp.size], 100 * m / m0, label=ELEMENT_NAME_STRINGS[i])

plt.plot(cp.t_history[:cp.size], 100 * m_sum / m0, label='$\\Sigma$')
plt.xlabel('Reakcijos laikas (s)')
plt.ylabel('Medžiagų masės dalys (%)')
plt.legend()
plt.tight_layout()

# %%

frame = 100
assert frame < cp.size
species = 4
plt.title(f"$c_{1+species}(t={cp.t_history[frame]})$")

print(f"min = {np.min(cp.c_history)}, max = {np.max(cp.c_history)}")
mx = np.max(cp.c_history)

plt.imshow(cp.c_history[species, frame, :, :], vmin=0.0, vmax=mx)
#plt.imshow(cp.c_history[species, frame, :, :])

plt.colorbar()
# %%
