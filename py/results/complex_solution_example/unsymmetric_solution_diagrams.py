# %%

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import yag_model as ym
from yag_utils.paths import diagrams_dir
import yag_utils.initial_conditions as ics
import yag_utils.stoichiometry as stoich
from yag_utils.channels import ALL, AL2O3, Y2O3, YAG, channel_indices


def solve(stoichiometry, channels):
    """Density fields of the selected channels, same setup for every stoichiometry."""
    config = ym.solver_config(
        discretization=ym.discretization(
            mesh_resolution=(100, 100),
            physical_size=(1.0, 1.0)
        ),
        step=ym.fixed_step(dt=1e-3),
        brake=ym.fixed_step_brake(last_step=100_000),
        capture=ym.capture_config(
            channels=channels,
            reducer=ym.reducers.density_field(),
            trigger=ym.stride_trigger(every=100),
            sink=ym.in_memory_sink(capacity=1000),
        ),
        stoichiometry=stoichiometry,
    )

    mp = ym.model_params(
        D=[1e-2, 1e-2, 1e-2, 1e-2, 1e-2],
        k=[1.0, 1.0, 1.0]
    )

    ic = ics.checkerboard(config.discretization, 5.0, 3.0)
    return ym.solve(config, ic, mp).all()


# Full pathway through YAM and YAP, all species
rho_default, t_default = solve(stoich.default, ALL)

# Direct 5 Al2O3 + 3 Y2O3 -> 2 YAG, YAM and YAP stay empty so they are not captured
simplified_channels = AL2O3 | Y2O3 | YAG
rho_simplified, t_simplified = solve(stoich.simplified, simplified_channels)

# %%

plt.style.use("ggplot")

mpl.rcParams.update({
    "font.family": "Libertinus Serif",
    "figure.dpi": 150,
    "font.size": 16,
    "axes.labelsize": 20,
    "axes.titlesize": 20,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "grid.alpha": 0.3,
    # Render math in the document font instead of DejaVu Sans
    "mathtext.fontset": "custom",
    "mathtext.rm": "Libertinus Serif",
    "mathtext.it": "Libertinus Serif",
    "mathtext.bf": "Libertinus Serif",
})

# Shared style for the column (channel) and row (time) labels
label_style = dict(fontsize=20, color="black")

# --------------------------------------------------
# Select frames to display
# --------------------------------------------------

# frames = np.unique(
#     np.geomspace(1, n_frames, n_cols).astype(int) - 1
# )
frames = [1, 4, 25, 50]


def plot_frames(rho, channels, frames, filename):
    """Grid of density fields: rows are time snapshots, columns are channels."""
    # Species number of each captured channel, for the column labels
    species = [i + 1 for i in channel_indices(channels)]
    n_materials = len(species)

    # Per-channel color scale, shared across time snapshots
    vmin = rho.min(axis=(0, 2, 3))
    vmax = rho.max(axis=(0, 2, 3))

    fig, axes = plt.subplots(
        len(frames),          # rows = time snapshots
        n_materials,          # cols = materials
        figsize=(2.5 * n_materials, 2.2 * len(frames)),
        constrained_layout=True,
    )

    for row, frame in enumerate(frames):
        for col in range(n_materials):

            ax = axes[row, col]

            img = rho[frame, col]

            im = ax.imshow(
                img,
                cmap="viridis",
                vmin=vmin[col],
                vmax=vmax[col],
                origin="lower",
            )

            ax.set_xticks([])
            ax.set_yticks([])

            # Material labels on top
            if row == 0:
                ax.set_title(rf"$\rho_{{{species[col]}}}$", **label_style)

            # Time labels on first column, from t_1 since the initial frame is not shown
            if col == 0:
                ax.set_ylabel(
                    f"$t_{row + 1}$",
                    **label_style,
                    rotation=0,
                    labelpad=30,
                    va="center",
                )

            # Per-channel colorbar below each column
            if row == len(frames) - 1:
                cbar = fig.colorbar(
                    im,
                    ax=axes[:, col],
                    location="bottom",
                    shrink=0.9,
                )
                # Only the range endpoints, aligned inwards so they stay under the bar
                cbar.set_ticks(
                    [vmin[col], vmax[col]],
                    labels=[
                        # Treat values negligible relative to the range as zero
                        "0" if abs(v) < 1e-3 * vmax[col] else f"{v:.3g}"
                        for v in (vmin[col], vmax[col])
                    ],
                )
                cbar.ax.tick_params(labelsize=label_style["fontsize"] - 4, labelcolor="black")
                lo, hi = cbar.ax.get_xticklabels()
                lo.set_horizontalalignment("left")
                hi.set_horizontalalignment("right")

    # fig.supxlabel("Tankis ($g/ \\mu m^3$)")

    # fig.suptitle("Medžiagų molinės koncentracijos pasiskirstymas erdvėje reakcijos eigoje", y=1.02)

    plt.savefig(diagrams_dir() / filename, dpi=300)
    plt.show()


plot_frames(rho_default, ALL, frames, 'complex_reaction_dynamics_example.png')
plot_frames(rho_simplified, simplified_channels, frames, 'simplified_reaction_dynamics_example.png')
 # %%
