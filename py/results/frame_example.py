# %%

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import yag_model as ym
from py.core import MOLAR_MASSES, solve

# %%
def build_cfg(mp: ym.ModelParameters):
    disc = ym.Discretization(1.0, 1.0, 40, 40)
    ic = ym.build_checkerboard_initial_condition(disc, 5.0, 3.0)
    ts = ym.FixedTimeStep(0.0001)
    br = ym.FixedStepBrake(100000)
    cpt = ym.StrideCaptureTrigger(100)
    cp = ym.InMemoryFrameCapture(1000, disc)
    return [ disc, mp, ts, br, cpt, cp, ic ]

# %%

mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    [60.0, 30.0, 15.0]
)

disc, _, _, _, _, cpt, ic = solve(mp, build_cfg)

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

for row in range(n_materials):
    for col, frame in enumerate(frames):

        ax = axes[row, col]

        img = cpt.c_history[row, frame]

        im = ax.imshow(
            img,
            cmap="viridis",
            vmin=vmin,
            vmax=vmax,
            origin="lower",
        )

        ax.set_xticks([])
        ax.set_yticks([])

        # Time labels on top row
        if row == 0:
            t = int(cpt.t_history[frame])
            t = cpt.t_history[frame]
            ms = t * 1000

            ax.set_title(f"{ms:.1f} ms")
            # h = t // 3600
            # m = (t % 3600) // 60
            # s = t % 60

            # ax.set_title(f"{h}:{m:02d}:{s:02d}")

        # Material labels on first column
        if col == 0:
            ax.set_ylabel(
                rf"$c_{{{row+1}}}$",
                rotation=0,
                labelpad=25,
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

fig.suptitle("Medžiagų molinės koncentracijos pasiskirstymas erdvėje reakcijos eigoje", y=1.02)

plt.savefig('../doc/assets/diagrams/frame_example.png', dpi=300)
plt.show()
# %%
