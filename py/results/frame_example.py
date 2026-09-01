# %% 
# Pirmiausia paleisti main.py, kad 
# cwd būtų py, o ne py/results, kitaip
# neveiks from core import ...

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import yag_model as ym
from core import MOLAR_MASSES, Scales, solve


def diamond_mask(disc, a, b):
    y, x = np.indices((disc.mesh_res_y, disc.mesh_res_x))
    u, v = x % disc.mesh_res_x, y % disc.mesh_res_y
    return np.where(np.abs(u - disc.mesh_res_x/2) < np.abs(v - disc.mesh_res_y/2), a, b)

def form_diag_ic(disc) -> ym.SolutionState:
    s = ym.SolutionState(disc.mesh_res_y, disc.mesh_res_x)
    A = [5.0, 0.0]
    B = [0.0, 3.0]
    for mat in range(2):
        s[mat] = diamond_mask(disc, A[mat], B[mat])
    return s

# %%
def build_cfg(mp: ym.ModelParameters, _: Scales):
    disc = ym.Discretization(1.0, 1.0, 100, 100)
    # ic = ym.build_checkerboard_initial_condition(disc, 5.0, 3.0)
    ic = form_diag_ic(disc)
    for i in range(5):
        ic[i] = np.rot90(ic[i])

    ts = ym.FixedTimeStep(0.0001)
    br = ym.FixedStepBrake(100000)
    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.InMemoryFrameCapture(1000, disc)
    return [ disc, mp, ts, br, cpt, cp, ic ]

# %%

mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [60.0, 0, 0]
)

scales = Scales(L0=1.0, C0=1.0, D_ref=1.0)
disc, _, _, _, _, cpt, ic = solve(mp, build_cfg, scales)

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

n_materials = cpt.c_history.shape[0]
n_frames = cpt.c_history.shape[1]

n_cols = 4  # number of time snapshots
frames = np.unique(
    np.geomspace(1, n_frames, n_cols).astype(int) - 1
)

# Global color scale
vmin = np.min(cpt.c_history)
vmax = np.max(cpt.c_history)

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

        img = cpt.c_history[col, frame]

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
            ms = cpt.t_history[frame] * 1000
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

plt.savefig('../doc/assets/diagrams/frame_example_transposed.png', dpi=300)
plt.show()
 # %%
