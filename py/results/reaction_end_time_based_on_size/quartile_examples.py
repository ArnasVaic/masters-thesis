# %%
# Typical initial conditions of the largest size: for random squares and for Perlin noise, the
# trials whose end time is closest to the first quartile, the median and the third quartile
#
# Uses the trials of random_squares_end_time.py (run with IC=random_rectangles and IC=perlin).
# The arrangements are rebuilt from their seeds, so nothing is solved here.

import matplotlib.pyplot as plt
import numpy as np
import yag_model as yag
from matplotlib.colors import ListedColormap
from yag_utils import particles
from yag_utils.batch import load_rows
from yag_utils.paths import diagrams_dir, repo_root

SIZE = 16

# Builder from particles.PARTICLE_ICS -> (results file stem, label in the figure)
ICS = {
    "random_rectangles": ("random_squares", "Atsitiktinės dalelės"),
    "perlin": ("perlin", "Perlino triukšmas"),
}

# Quantile (%) -> label in the figure
QUANTILES = {25: "$Q_1$", 50: "Mediana", 75: "$Q_3$"}

# Same setup as random_squares_end_time.py: n x n particles of 1 um, 20 cells each
C1, C2 = 5.0, 3.0
CELLS_PER_PARTICLE = 20
PARTICLE_SIZE = 1.0

DATA_DIR = repo_root() / "py" / "results" / "reaction_end_time_based_on_size" / "data"


def end_times(stem: str) -> dict[int, float]:
    """End time of every trial of size SIZE, by trial."""
    rows = load_rows(DATA_DIR / f"{stem}_end_time_k1.csv")
    return {int(r["trial"]): float(r["end_time"]) for r in rows if int(r["size"]) == SIZE}


def c1_mask(ic: str, trial: int) -> np.ndarray:
    """Where the trial's initial condition holds c1, row 0 is the bottom row."""
    disc = yag.discretization(
        mesh_resolution=(CELLS_PER_PARTICLE * SIZE, CELLS_PER_PARTICLE * SIZE),
        physical_size=(PARTICLE_SIZE * SIZE, PARTICLE_SIZE * SIZE),
    )
    # The same seed as the trial in random_squares_end_time.py
    rng = np.random.default_rng([SIZE, trial])
    return particles.PARTICLE_ICS[ic].build(disc, SIZE, C1, C2, rng)[0] > 0


# %%
# Per IC and quantile: (trial, its end time, the quantile)
selected: dict[str, list[tuple[int, float, float]]] = {}

for ic, (stem, _) in ICS.items():
    times = end_times(stem)
    trials = np.array(list(times))
    t = np.array(list(times.values()))
    selected[ic] = []
    for q in QUANTILES:
        target = np.percentile(t, q)
        k = np.argmin(np.abs(t - target))
        selected[ic].append((int(trials[k]), float(t[k]), float(target)))

    print(f"{ic}, n = {SIZE}, {len(t)} trials:")
    for (trial, t_end, target), q in zip(selected[ic], QUANTILES):
        print(f"  {q}th percentile {target:.3f} s -> trial {trial}, end time {t_end:.3f} s")

# %%
# Same look as the other thesis figures, c1 is left blank and c2 is light gray
plt.style.use("ggplot")
plt.rcParams.update({
    "font.family": "Libertinus Serif",
    "mathtext.fontset": "custom",
    "mathtext.it": "Libertinus Serif:italic",
    "mathtext.rm": "Libertinus Serif",
    "mathtext.cal": "Libertinus Serif",
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.titlesize": 11,
})
IC_CMAP = ListedColormap(["#dedede", "#ffffff"])

fig, axes = plt.subplots(len(ICS), len(QUANTILES), figsize=(6.2, 4.4), dpi=150, layout="constrained")

for row, (ic, (_, ic_label)) in enumerate(ICS.items()):
    for col, ((trial, t_end, _), q_label) in enumerate(zip(selected[ic], QUANTILES.values())):
        ax = axes[row, col]
        ax.imshow(
            c1_mask(ic, trial), extent=(0, SIZE, 0, SIZE), origin="lower",
            cmap=IC_CMAP, vmin=0, vmax=1, interpolation="nearest",
        )
        ax.plot([0, SIZE, SIZE, 0, 0], [0, 0, SIZE, SIZE, 0], color="black", linewidth=1.0)
        ax.set_xlim(0, SIZE)
        ax.set_ylim(0, SIZE)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.grid(False)
        for spine in ax.spines.values():
            spine.set_visible(False)

        if row == 0:
            ax.set_title(q_label)
        ax.set_xlabel(f"$t \\approx {t_end:.1f}$ s", color="black", fontsize=10)
        if col == 0:
            ax.set_ylabel(ic_label, color="black")

fig.savefig(diagrams_dir() / "end-time-quartile-examples.png", dpi=300, bbox_inches="tight", pad_inches=0.05)
plt.show()
