# %%

import matplotlib.pyplot as plt
import numpy as np
import yag_model as yag
from scipy.stats import gaussian_kde
from tqdm.auto import tqdm
from yag_utils import particles
from yag_utils.batch import csv_appender, load_rows, run_batch
from yag_utils.paths import repo_root

MAX_SIZE = 20

# In total there are size^2 particles (squares), the builders of particles.PARTICLE_ICS fill
# about half of them with c1 = 5, the rest with c2 = 3
C1, C2 = 5.0, 3.0
# Selects the builder from particles.PARTICLE_ICS, each one writes to its own results file
IC = "random_rectangles"
# Deterministic builders give the same result every trial, so they need only one
TRIALS_PER_SIZE = 100 if particles.PARTICLE_ICS[IC].seeded else 1

# One row per finished trial, appended as soon as the trial ends. Rerunning skips
# trials already in the file, so the script can be interrupted and resumed.
# Delete the file (or change the name) after changing the setup below.
RESULTS_PATH = repo_root() / "py" / "results" / "data" / f"reaction_end_time_based_on_grid_size_{IC}.csv"
FIELDS = ["size", "trial", "end_time"]


def load_end_times(path) -> dict[tuple[int, int], float]:
    return {(int(r["size"]), int(r["trial"])): float(r["end_time"]) for r in load_rows(path)}


def initial_condition(ic: str, size: int, trial: int):
    # Seeded by (size, trial) so a resumed run uses the same initial conditions
    return particles.initial_condition(ic, size, trial, C1, C2)


def reaction_end_time(size: int, trial: int) -> float:
    config = yag.solver_config(
        discretization=particles.discretization(size),
        # Step in 10 microsecond steps
        step=yag.fixed_step(dt=1e-3),
        # Stop when the reagent mass drops to 10% of the original
        brake=yag.reagent_mass_threshold_brake(threshold=10e-2),
        # Only the time of the last frame is needed, total mass keeps the frame tiny
        capture=yag.capture_config(
            reducer=yag.reducers.total_mass(),
            trigger=yag.last_frame_trigger(),
        ),
    )

    ic = initial_condition(IC, size, trial)

    params = yag.model_params(D=[1e-2] * 5, k=[10] * 3)

    masses, times = yag.solve(config, ic, params).all()
    if not np.isfinite(masses).all():
        raise RuntimeError(f"Solution blew up for size {size}, trial {trial}")
    return float(times[-1])


# %%
end_times = load_end_times(RESULTS_PATH)
sizes = range(2, MAX_SIZE + 1)
todo = [(s, t) for s in sizes for t in range(TRIALS_PER_SIZE) if (s, t) not in end_times]
remaining = {s: sum(1 for ts, _ in todo if ts == s) for s in sizes}

with csv_appender(RESULTS_PATH, FIELDS) as append:
    size_bar = tqdm(total=len(sizes), initial=sum(n == 0 for n in remaining.values()), desc="sizes")
    trial_total = len(sizes) * TRIALS_PER_SIZE
    trial_bar = tqdm(total=trial_total, initial=trial_total - len(todo), desc="trials")

    def record(task, t_end):
        # Called on the main thread only, so the file and the bars need no locking
        size, trial = task
        end_times[(size, trial)] = t_end
        append({"size": size, "trial": trial, "end_time": t_end})
        trial_bar.update()

        remaining[size] -= 1
        if remaining[size] == 0:
            done = [end_times[(size, t)] for t in range(TRIALS_PER_SIZE)]
            size_bar.update()
            size_bar.set_postfix(size=size, avg_end_time=f"{np.mean(done):.4g}")

    try:
        # Submitted smallest size first, so sizes finish (and are averaged) roughly in order.
        # An interrupt raises KeyboardInterrupt, which stops here instead of going on to the plot
        run_batch(reaction_end_time, todo, record)
    finally:
        trial_bar.close()
        size_bar.close()

# %%

end_times = load_end_times(RESULTS_PATH)
sizes = sorted({s for s, _ in end_times})
per_size = [np.array([t for (s, _), t in end_times.items() if s == size]) for size in sizes]


def kde_mode(t: np.ndarray) -> float:
    # End times are continuous (almost all distinct from size 4 up), so the mode is taken as
    # the peak of a kernel density estimate rather than the most repeated value
    if np.ptp(t) == 0:
        return float(t[0])
    grid = np.linspace(t.min(), t.max(), 1000)
    return float(grid[np.argmax(gaussian_kde(t)(grid))])


means = np.array([t.mean() for t in per_size])
medians = np.array([np.median(t) for t in per_size])
modes = np.array([kde_mode(t) for t in per_size])

for size, t, mode in zip(sizes, per_size, modes):
    print(
        f"size {size:2d}: {len(t):3d} trials, end time {t.mean():.4g} ± {t.std():.2g}, "
        f"median {np.median(t):.4g}, mode {mode:.4g}"
    )

if TRIALS_PER_SIZE == 1:
    # Deterministic initial condition, there is no distribution to show
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(sizes, means, marker="o", color="C0")
    ax.set_xticks(sizes)
    ax.set_xlabel("particles per side")
    ax.set_ylabel("reaction end time")
    ax.set_title(f"initial condition: {IC}")
    ax.grid(True, alpha=0.3)
    plt.show()
else:
    # All trials as jittered points over a violin of their distribution, with the summary statistics
    fig, ax = plt.subplots(figsize=(10, 5))
    # A violin needs spread, so sizes with a single distinct end time get only their points
    spread = [i for i, t in enumerate(per_size) if np.ptp(t) > 0]
    if spread:
        violins = ax.violinplot(
            [per_size[i] for i in spread], positions=[sizes[i] for i in spread], widths=0.8, showextrema=False
        )
        for body in violins["bodies"]:
            body.set_facecolor("0.8")
    rng = np.random.default_rng(0)
    for size, t in zip(sizes, per_size):
        ax.scatter(size + rng.uniform(-0.2, 0.2, len(t)), t, s=6, color="0.3", alpha=0.4, linewidths=0)
    ax.plot(sizes, means, marker="o", color="C0", label="mean")
    ax.plot(sizes, medians, marker="s", color="C1", label="median")
    ax.plot(sizes, modes, marker="^", color="C2", label="mode (KDE peak)")
    ax.set_xticks(sizes)
    ax.set_xlabel("particles per side")
    ax.set_ylabel("reaction end time")
    ax.grid(True, alpha=0.3)
    ax.set_title(f"initial condition: {IC}")
    ax.legend()
    plt.show()

    # One histogram per size, sharing the time axis so the spread can be compared
    cols = 4
    rows = -(-len(sizes) // cols)
    fig, axes = plt.subplots(rows, cols, figsize=(3.5 * cols, 2.5 * rows), sharex=True, squeeze=False)
    bins = np.histogram_bin_edges(np.concatenate(per_size), bins=40)
    for ax, size, t, mean, median, mode in zip(axes.flat, sizes, per_size, means, medians, modes):
        ax.hist(t, bins=bins, color="0.6")
        ax.axvline(mean, color="C0", label="mean")
        ax.axvline(median, color="C1", label="median")
        ax.axvline(mode, color="C2", label="mode (KDE peak)")
        ax.set_title(f"{size} particles per side ({len(t)} trials)", fontsize=9)
    for ax in axes.flat[len(sizes):]:
        ax.set_visible(False)
    for ax in axes[-1]:
        ax.set_xlabel("reaction end time")
    axes[0, 0].legend(fontsize=7)
    fig.suptitle(f"initial condition: {IC}")
    fig.tight_layout()
    plt.show()

# %%
# Examples of the initial conditions, run this cell by hand (after the first one) to look at them.
# Shows the reagent channels c1 (Al2O3) and c2 (Y2O3) exactly as the trials of the given size get them

EXAMPLE_SIZE = 6
# Any keys of particles.PARTICLE_ICS
EXAMPLE_ICS = list(particles.PARTICLE_ICS)
# Trial indices to show for random builders, deterministic ones show only trial 0
EXAMPLE_TRIALS = [0, 1, 2]

examples = [
    (ic, trial)
    for ic in EXAMPLE_ICS
    for trial in (EXAMPLE_TRIALS if particles.PARTICLE_ICS[ic].seeded else [0])
]
channels = ["$c_1$ (Al$_2$O$_3$)", "$c_2$ (Y$_2$O$_3$)"]

fig, axes = plt.subplots(
    len(examples),
    len(channels),
    figsize=(2.5 * len(channels), 2.5 * len(examples)),
    squeeze=False,
    constrained_layout=True,
)
for row, (ic, trial) in enumerate(examples):
    state = initial_condition(ic, EXAMPLE_SIZE, trial)
    for col, label in enumerate(channels):
        ax = axes[row, col]
        ax.imshow(np.asarray(state[col]), cmap="viridis", origin="lower")
        # Particle boundaries
        ticks = np.arange(0, particles.PARTICLE_CELLS * EXAMPLE_SIZE + 1, particles.PARTICLE_CELLS) - 0.5
        ax.set_xticks(ticks, labels=[])
        ax.set_yticks(ticks, labels=[])
        ax.tick_params(length=0)
        ax.grid(True, color="white", linewidth=0.3, alpha=0.5)
        if row == 0:
            ax.set_title(label)
        if col == 0:
            ax.set_ylabel(f"{ic}\ntrial {trial}" if particles.PARTICLE_ICS[ic].seeded else ic)
fig.suptitle(f"initial conditions, {EXAMPLE_SIZE} particles per side")
plt.show()
