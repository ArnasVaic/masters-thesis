# %%
import numpy as np
import yag_model as ym
from yag_utils.channels import LABELS
from yag_utils.initial_conditions import checkerboard
from yag_utils.mass import total_mass
from yag_utils.paths import diagrams_dir

import matplotlib.pyplot as plt
import matplotlib as mpl

# %%
disc = ym.discretization(mesh_resolution=(40, 40), physical_size=(1.0, 1.0))
ic = checkerboard(disc, 5.0, 3.0)

config = ym.solver_config(
    discretization=disc,
    step=ym.fixed_step(dt=0.0001),
    brake=ym.fixed_step_brake(last_step=100000),
    capture=ym.capture_config(
        reducer=ym.reducers.total_mass(),
        trigger=ym.stride_trigger(every=100),
        sink=ym.in_memory_sink(capacity=1000),
    ),
)

# %%
mp = ym.model_params(
    D=[1e-2, 1e-2, 1e-2, 1e-2, 1e-2],
    k=[10.0, 5.0, 1.0]
)

m, t = ym.solve(config, ic, mp).all()

# %% Norint sėkmingai paleisti reikia įrašyti Libertinus Serif šriftą.
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

# Initially only reagents are present
m0 = total_mass(ic, disc)

for i in range(5):
    plt.plot(t, 100 * m[:, i] / m0, label=LABELS[i])

plt.plot(t, 100 * m.sum(axis=1) / m0, label='$\\Sigma$')
plt.xlabel('Reakcijos laikas (s)')
plt.ylabel('Medžiagų masės dalys (%)')
plt.legend()
plt.tight_layout()
#plt.savefig(diagrams_dir() / 'const-mass.png', dpi=300)

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
