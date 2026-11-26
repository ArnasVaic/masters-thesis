# %%
# Distribution of the reaction end time over random arrangements of square particles
#
# Sizes count whole particles per side, as in the random squares figure of the thesis: n x n
# particles of 1 um. Note yag_utils.particles.discretization uses 0.5 um particles instead, so
# it is not used here. The parameters only illustrate how the end time spreads with size. The
# rates are 10 times below those of checkerboard_end_time.py, so the step can be 10 times larger
# and many arrangements are affordable, while the arrangement still decides the end time.
#
# The arrangement comes from particles.PARTICLE_ICS, random squares by default. Another one is
# picked with the IC environment variable, e.g. `IC=perlin python random_squares_end_time.py`,
# and gets its own results file and figure.

import os

import matplotlib.pyplot as plt
import numpy as np
import yag_model as yag
from scipy.stats import gaussian_kde
from tqdm.auto import tqdm
from yag_utils import particles
from yag_utils.batch import csv_appender, load_rows, run_batch
from yag_utils.paths import diagrams_dir, repo_root

IC = os.environ.get("IC", "random_rectangles")
# File name stem of the results and figure, random squares keep the names they had before
NAMES = {"random_rectangles": "random_squares", "perlin": "perlin"}

SIZES = [4, 8, 12, 16]
TRIALS_PER_SIZE = 1000

C1, C2 = 5.0, 3.0
D = [1e-2] * 5
K = [1.0, 0.5, 0.1]

CELLS_PER_PARTICLE = 20
PARTICLE_SIZE = 1.0

# The reaction ends when the reagent mass drops to this part of the original
THRESHOLD = 10e-2

# Too large a step does not blow up, the reagents collapse and the solve ends far too early
# with finite values. dt reaches the bound at about t = UPPER_BOUND / (R - 1) = 20, well before
# the shortest true end times, so such a trial would stand out as an early cluster.
DT_0 = 2e-3
R = 1.01
UPPER_BOUND = 0.2

# The solver is single threaded and this machine has no hyperthreading, so one worker per core
WORKERS = os.cpu_count() or 1

# One row per finished trial, appended as soon as the trial ends. Rerunning skips trials
# already in the file, so the run can be interrupted and resumed, and rerunning a finished
# study only redraws the figure. Delete the file after changing the setup above.
RESULTS_PATH = (
    repo_root() / "py" / "results" / "reaction_end_time_based_on_size" / "data" / f"{NAMES[IC]}_end_time_k1.csv"
)
FIELDS = ["size", "trial", "end_time"]


def load_end_times() -> dict[tuple[int, int], float]:
    return {(int(r["size"]), int(r["trial"])): float(r["end_time"]) for r in load_rows(RESULTS_PATH)}


def reaction_end_time(size: int, trial: int) -> float:
    disc = yag.discretization(
        mesh_resolution=(CELLS_PER_PARTICLE * size, CELLS_PER_PARTICLE * size),
        physical_size=(PARTICLE_SIZE * size, PARTICLE_SIZE * size),
    )
    config = yag.solver_config(
        discretization=disc,
        step=yag.clamped_geometric_step(dt_0=DT_0, r=R, upper_bound=UPPER_BOUND),
        brake=yag.reagent_mass_threshold_brake(threshold=THRESHOLD),
        # Only the time of the last frame is needed, total mass keeps the frame tiny
        capture=yag.capture_config(
            reducer=yag.reducers.total_mass(),
            trigger=yag.last_frame_trigger(),
        ),
    )
    # Seeded by (size, trial), trial 0 is the arrangement drawn in the thesis figure
    rng = np.random.default_rng([size, trial])
    ic = particles.PARTICLE_ICS[IC].build(disc, size, C1, C2, rng)

    masses, times = yag.solve(config, ic, yag.model_params(D=D, k=K)).all()
    if not np.isfinite(masses).all():
        raise RuntimeError(f"Solution blew up for size {size}, trial {trial}")
    return float(times[-1])


# %%
end_times = load_end_times()
todo = [(s, t) for s in SIZES for t in range(TRIALS_PER_SIZE) if (s, t) not in end_times]

with csv_appender(RESULTS_PATH, FIELDS) as append:
    total = len(SIZES) * TRIALS_PER_SIZE
    bar = tqdm(total=total, initial=total - len(todo), desc="trials")

    def record(task, t_end):
        size, trial = task
        append({"size": size, "trial": trial, "end_time": t_end})
        bar.update()

    try:
        # An interrupt raises KeyboardInterrupt, which stops here instead of going on to the plot
        run_batch(reaction_end_time, todo, record, workers=WORKERS)
    finally:
        bar.close()

# %%
end_times = load_end_times()
per_size = {size: np.array([t for (s, _), t in sorted(end_times.items()) if s == size]) for size in SIZES}

for size, t in per_size.items():
    q1, median, q3 = np.percentile(t, [25, 50, 75])
    print(
        f"n = {size:2d}: {len(t)} trials, median {median:.3f} s, IQR {q1:.3f}-{q3:.3f} s, "
        f"range {t.min():.3f}-{t.max():.3f} s, mean {t.mean():.3f} s"
    )

# %%
# Same look as the other thesis figures
plt.style.use("ggplot")
plt.rcParams.update({
    "font.family": "Libertinus Serif",
    "mathtext.fontset": "custom",
    "mathtext.it": "Libertinus Serif:italic",
    "mathtext.rm": "Libertinus Serif",
    "mathtext.cal": "Libertinus Serif",
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "grid.alpha": 0.3,
})

COLORS = dict(zip(SIZES, ["#2a78d6", "#eb6834", "#1baf7a", "#eda100"]))

fig, (ax_hist, ax_points) = plt.subplots(
    2, 1, figsize=(6.2, 4.4), dpi=150, sharex=True, height_ratios=[3, 1.25], layout="constrained"
)

# From zero, so the density curves fall off instead of being cut at the shortest trial
xs = np.linspace(0, max(t.max() for t in per_size.values()), 800)
rng = np.random.default_rng(0)

for row, size in enumerate(SIZES):
    t = per_size[size]
    color = COLORS[size]
    median = np.median(t)

    ax_hist.plot(xs, gaussian_kde(t)(xs), color=color, linewidth=1.8, label=f"$n = {size}$")
    ax_hist.axvline(median, color=color, linestyle="--", linewidth=1.2)

    # One strip per size, each dot is one trial
    ax_points.scatter(t, row + rng.uniform(-0.25, 0.25, len(t)), s=4, color=color, alpha=0.3, linewidths=0)
    ax_points.plot([median, median], [row - 0.4, row + 0.4], color="0.15", linewidth=1.6, solid_capstyle="butt")

ax_hist.set_ylabel("Tankis")
ax_hist.set_ylim(bottom=0)
ax_hist.legend(frameon=False, loc="upper right")

ax_points.set_yticks(range(len(SIZES)), [f"$n = {s}$" for s in SIZES])
ax_points.set_ylim(len(SIZES) - 0.45, -0.55)
ax_points.grid(False, axis="y")
ax_points.set_xlabel("Reakcijos pabaigos laikas (s)")

fig.align_ylabels()
fig.savefig(diagrams_dir() / f"{NAMES[IC].replace('_', '-')}-end-time-distribution.png", dpi=300)
plt.show()
