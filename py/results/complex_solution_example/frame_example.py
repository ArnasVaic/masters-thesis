# %% 

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import yag_model as ym
from yag_utils.paths import diagrams_dir


def diamond_mask(disc, a, b):
    y, x = np.indices(disc.shape)
    u, v = x % disc.nx, y % disc.ny
    return np.where(np.abs(u - disc.nx/2) < np.abs(v - disc.ny/2), a, b)

def form_diag_ic(disc) -> ym.SolutionState:
    s = ym.SolutionState(disc)
    A = [5.0, 0.0]
    B = [0.0, 3.0]
    for mat in range(2):
        s[mat] = diamond_mask(disc, A[mat], B[mat])
    return s

# %%
disc = ym.discretization(mesh_resolution=(100, 100), physical_size=(1.0, 1.0))
# ic = ym.checkerboard_initial_condition(disc, 5.0, 3.0)
ic = form_diag_ic(disc)
for i in range(5):
    ic[i] = np.rot90(ic[i])

config = ym.solver_config(
    discretization=disc,
    step=ym.fixed_step(dt=0.0001),
    brake=ym.fixed_step_brake(last_step=100000),
    capture=ym.capture_config(
        trigger=ym.stride_trigger(every=100),
        sink=ym.in_memory_sink(capacity=1000),
    ),
)

# %%

mp = ym.model_params(
    D=[1e-2, 1e-2, 1e-2, 1e-2, 1e-2],
    k=[60.0, 0, 0]
)

c, t = ym.solve(config, ic, mp).all()

# %%

plt.style.use("ggplot")

mpl.rcParams.update({
    "font.family": "Libertinus Serif",
    "figure.dpi": 150,
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.titlesize": 13,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "grid.alpha": 0.3,
})

# --------------------------------------------------
# Select frames to display
# --------------------------------------------------

n_frames = c.shape[0]
n_materials = c.shape[1]

n_cols = 4  # number of time snapshots
frames = np.unique(
    np.geomspace(1, n_frames, n_cols).astype(int) - 1
)

# Global color scale
vmin = np.min(c)
vmax = np.max(c)

fig, axes = plt.subplots(
    n_materials,
    len(frames),
    figsize=(2.0 * len(frames), 2.0 * n_materials),
    constrained_layout=True,
)

fig, axes = plt.subplots(
    len(frames),          # rows = time snapshots
    n_materials,          # cols = materials
    figsize=(2.5 * n_materials, 2.2 * len(frames)),
    constrained_layout=True,
)

for row, frame in enumerate(frames):
    for col in range(n_materials):

        ax = axes[row, col]

        img = c[frame, col]

        im = ax.imshow(
            img,
            cmap="viridis",
            vmin=vmin,
            vmax=vmax,
            origin="lower",
        )

        ax.set_xticks([])
        ax.set_yticks([])

        # Material labels on top
        if row == 0:
            ax.set_title(rf"$c_{{{col+1}}}$")

        # Time labels on first column
        if col == 0:
            ms = t[frame] * 1000
            ax.set_ylabel(
                f"{ms:.1f} ms",
                rotation=0,
                labelpad=30,
                va="center",
            )

# Shared colorbar
cbar = fig.colorbar(
    im,
    ax=axes,
    shrink=0.8,
    location="right",
)
cbar.set_label("Molinė koncentracija ($mol/ \\mu m^3$)")

# fig.suptitle("Medžiagų molinės koncentracijos pasiskirstymas erdvėje reakcijos eigoje", y=1.02)

plt.savefig(diagrams_dir() / 'frame_example_transposed.png', dpi=300)
plt.show()
 # %%
