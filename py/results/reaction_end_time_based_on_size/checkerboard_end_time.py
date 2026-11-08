# %%
# Reaction end time of the checkerboard as the domain grows
#
# The arrangement is deterministic, so each size is solved once. Sizes count blocks per side
# as in yag_utils.particles (0.5 um each), so size = 2 n for n whole particles per side.
# Parameters are those of the small example in the results chapter, not fitted ones.

import time

import matplotlib.pyplot as plt
import numpy as np
import yag_model as yag
from yag_utils import particles
from yag_utils.batch import run_batch
from yag_utils.paths import diagrams_dir

SIZES = list(range(2, 21, 2))
C1, C2 = 5.0, 3.0
D = [1e-2] * 5
K = [10.0, 5.0, 1.0]

# The reaction ends when the reagent mass drops to this part of the original
THRESHOLD = 10e-2

DT_0 = 1e-4
R = 1.001
UPPER_BOUND = 1e-3


def reaction_end_time(size: int) -> tuple[float, float]:
    """End time of a size x size checkerboard and the wall time (s) of its solve."""
    config = yag.solver_config(
        discretization=particles.discretization(size),
        step=yag.clamped_geometric_step(dt_0=DT_0, r=R, upper_bound=UPPER_BOUND),
        brake=yag.reagent_mass_threshold_brake(threshold=THRESHOLD),
        capture=yag.capture_config(
            reducer=yag.reducers.total_mass(),
            trigger=yag.last_frame_trigger(),
        ),
    )
    ic = particles.initial_condition("checkerboard", size, 0, C1, C2)

    start = time.perf_counter()
    masses, times = yag.solve(config, ic, yag.model_params(D=D, k=K)).all()
    wall = time.perf_counter() - start

    if not np.isfinite(masses).all():
        raise RuntimeError(f"Solution blew up for size {size}")
    return float(times[-1]), wall


# %%
results: dict[int, tuple[float, float]] = {}
run_batch(reaction_end_time, [(s,) for s in SIZES], lambda task, r: results.update({task[0]: r}))

end_times = np.array([results[s][0] for s in SIZES])
for size, end_time in zip(SIZES, end_times):
    print(
        f"size {size:2d} (n = {size // 2:2d}): end time {end_time:.5g}, "
        f"{end_time / end_times[0] - 1:+.3%} vs size {SIZES[0]}, solved in {results[size][1]:.1f} s"
    )

# %%
# Same look as the other thesis figures. The axis starts at zero so the drift of a few
# percent is drawn at its true size next to the end time itself
plt.style.use("ggplot")
plt.rcParams.update({
    "font.family": "Libertinus Serif",
    "mathtext.fontset": "custom",
    "mathtext.it": "Libertinus Serif:italic",
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "grid.alpha": 0.3,
})

n = np.array(SIZES) // 2

fig, ax = plt.subplots(figsize=(6, 3), dpi=150)
ax.plot(n, end_times, marker="o", markersize=6, linewidth=2)
for i in (0, -1):
    ax.annotate(
        f"{end_times[i]:.2f} s", (n[i], end_times[i]), xytext=(0, 8), textcoords="offset points", ha="center"
    )
ax.set_xticks(n)
ax.set_ylim(0, 10)
ax.set_xlabel("Dalelių skaičius srities kraštinėje $n$")
ax.set_ylabel("Reakcijos pabaigos laikas (s)")
fig.tight_layout()
fig.savefig(diagrams_dir() / "checkerboard-end-time.png", dpi=300)
plt.show()
