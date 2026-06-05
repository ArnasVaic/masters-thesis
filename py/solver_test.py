# %%
import numpy as np
import yag_model as ym
from core import solve, MOLAR_MASSES, build_optimization_config
import matplotlib.pyplot as plt

def build_config(mp: ym.ModelParameters):
    disc, mp_nd, ts, br, _, _, ic = build_optimization_config(mp)
    cpt = ym.StrideCaptureTrigger(10)
    cp = ym.InMemoryFrameCapture(500, disc)
    return [disc, mp_nd, ts, br, cpt, cp, ic]
# %%

logD = [
    -5.951425472226097,
    -6.381854122397745,
    -6.796653711570672,
    -6.378758235770181,
    -5.190091649510689
]

logK = [
    10.990986955550355,
    10.483942406247088,
    9.04041247830719
]

mp = ym.ModelParameters(
    [ 10**d for d in logD ],
    [ 10**k for k in logK ]
)

disc, _, _, _, _, cpt, ic = solve(mp, build_config)

# %%

m0 = \
    MOLAR_MASSES[0] * ym.quantity(ic[0], disc) + \
    MOLAR_MASSES[1] * ym.quantity(ic[1], disc)

ELEMENT_NAME_STRINGS = [
    '$Al_2O_3$','$Y_2O_3$','$YAM$','$YAP$','$YAG$'
]

m_sum = np.zeros((cpt.size))
for i in range(5):
    qi = np.array([ ym.quantity(cpt.c_history[i, f, :, :], disc) for f in range(cpt.size) ])
    m = qi * MOLAR_MASSES[i]
    m_sum += m
    plt.plot(cpt.t_history[:cpt.size], 100 * m / m0, label=ELEMENT_NAME_STRINGS[i])

plt.plot(cpt.t_history[:cpt.size], 100 * m_sum / m0, label='$\\Sigma$')
plt.xlabel('Reakcijos laikas (s)')
plt.ylabel('Medžiagų masės dalys (%)')
plt.legend()
plt.tight_layout()

# %%

frame = 360
assert frame < cpt.size
species = 0
plt.title(f"$c_{1+species}(t={cpt.t_history[frame]})$")

print(f"min = {np.min(cpt.c_history)}, max = {np.max(cpt.c_history)}")
mx = np.max(cpt.c_history)

plt.imshow(cpt.c_history[species, frame, :, :], vmin=0.0, vmax=mx)
#plt.imshow(cpt.c_history[species, frame, :, :])

plt.colorbar()
# %%
