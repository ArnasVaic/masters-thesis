# %%

import numpy as np
import yag_model as ym
import yag_utils as yu

import matplotlib.pyplot as plt
import matplotlib as mpl

# %%
def build_cfg(mp: ym.ModelParameters):
    disc = ym.Discretization(1.0, 1.0, 40, 40)
    ic = ym.build_checkerboard_initial_condition(disc, 5.0, 3.0)
    ts = ym.FixedTimeStep(0.0001)
    br = ym.FixedStepBrake(100000)
    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.QuantityCapture(1000, disc)
    return [ disc, mp, ts, br, cpt, cp, ic ]

# %%
mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [10.0, 5.0, 1.0]
)

disc, _, _, _, _, cpt, ic = yu.solve(mp, build_cfg)

# %%

plt.style.use('ggplot')  # try: 'ggplot', 'bmh', 'fivethirtyeight'

mpl.rcParams.update({
    "font.family": "Libertinus Serif",

    # Figure
    "figure.figsize": (6, 4),
    "figure.dpi": 150,

    # Text
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.titlesize": 13,
    "legend.fontsize": 10,

    # Lines
    "lines.linewidth": 2,

    # Axes
    "axes.spines.top": False,
    "axes.spines.right": False,

    # Grid
    "grid.alpha": 0.3,

    # Legend
    "legend.frameon": False,
})

mpl.rcParams["font.family"] = "Libertinus Serif"

m0 = \
    MOLAR_MASSES[0] * ym.quantity(ic[0], disc) + \
    MOLAR_MASSES[1] * ym.quantity(ic[1], disc)

ELEMENT_NAME_STRINGS = [
    '$Al_2O_3$','$Y_2O_3$','$YAM$','$YAP$','$YAG$'
]

m_sum = np.zeros_like(cpt.q_history[0])
for i in range(5):
    m = cpt.q_history[i] * MOLAR_MASSES[i]
    m_sum += m
    plt.plot(cpt.t_history, 100 * m / m0, label=ELEMENT_NAME_STRINGS[i])

plt.plot(cpt.t_history, 100 * m_sum / m0, label='$\\Sigma$')
plt.xlabel('Reakcijos laikas (s)')
plt.ylabel('Medžiagų masės dalys (%)')
plt.legend()
plt.tight_layout()
plt.savefig('../../doc/assets/diagrams/const-mass.png', dpi=300)

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
