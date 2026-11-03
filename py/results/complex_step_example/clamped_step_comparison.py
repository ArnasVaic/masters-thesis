# %%
# Clamped geometric time step: calculation time and solution for different growth ratios r
#
# The 6 hour experiment (40 x 40 checkerboard, fitted parameters) is solved once per r.
# r = 1 keeps dt = dt_0 for the whole run and serves as the reference. Every case is solved
# timed with no captures, with masses on every step, and up to each frame time for fields.

import time

import matplotlib.pyplot as plt
import numpy as np
import yag_model as yag
from yag_utils import physical
from yag_utils.channels import AL2O3, LABELS, channel_indices
from yag_utils.constants import AL2O3_CONCENTRATION
from yag_utils.optimization import DEFAULT_SCALES
from yag_utils.scaling import physical_result

scales = DEFAULT_SCALES

# Growth ratios to compare, r = 1 is the fixed step reference
RATIOS = [1.0, 1.0001, 1.001, 1.01, 1.1]
DT_0 = 1.0             # s
UPPER_BOUND = 60.0     # s
EVERY = 1              # steps between dt increases
FINAL_TIME = 6 * 60 * 60  # s
THRESHOLD = 3 # %

# Timed solves per ratio, the fastest one is reported
REPEATS = 3

# Species and physical times shown in the frame grid. Diffusion evens out the
# checkerboard within about half an hour, so most frames are early
FRAME_CHANNEL = AL2O3
FRAME_TIMES = [0.0, 60, 5 * 60, 30 * 60, FINAL_TIME]  # s

# Fitted parameters (see py/solver_test.py), D in m^2/s, k in m^3/(mol s)
LOG_D = [-15.520843103369195, -14.962864487926721, -14.08355774833853, -15.939166775886509, -15.064413562884312]
LOG_K = [-8.81287507930491, -8.171172197361324, -8.998608159571566]

disc = physical.discretization(scales, physical_size=(1e-6, 1e-6), mesh_resolution=(40, 40))
ic = physical.checkerboard_initial_condition(scales, disc, AL2O3_CONCENTRATION, 3 / 5 * AL2O3_CONCENTRATION)
params = physical.model_params(scales, D=[10**d for d in LOG_D], k=[10**k for k in LOG_K])


def format_time(t: float) -> str:
    """Physical time in s with the most readable unit."""
    if t < 120:
        return f"{t:.3g} s"
    if t < 2 * 60 * 60:
        return f"{t / 60:.3g} min"
    return f"{t / 3600:.3g} h"


def solve(r: float, capture: yag.CaptureConfig, final_time: float = FINAL_TIME):
    config = yag.solver_config(
        discretization=disc,
        step=physical.clamped_geometric_step(scales, dt_0=DT_0, r=r, upper_bound=UPPER_BOUND, every=EVERY),
        # brake=physical.fixed_time_brake(scales, final_time=final_time),
        brake = yag.reagent_mass_threshold_brake(THRESHOLD / 100, every=10),
        capture=capture,
    )
    return yag.solve(config, ic, params)


def calculation_time(r: float) -> float:
    """Fastest wall time (s) of a solve capturing only the last frame."""
    capture = yag.capture_config(
        reducer=yag.reducers.total_mass(),
        trigger=yag.last_frame_trigger(),
    )
    times = []
    for _ in range(REPEATS):
        start = time.perf_counter()
        solve(r, capture)
        times.append(time.perf_counter() - start)
    return min(times)


def mass_history(r: float) -> tuple[np.ndarray, np.ndarray]:
    """Mass percentages (N, 5) and physical times (N,) on every step."""
    capture = yag.capture_config(reducer=yag.reducers.total_mass(), trigger=yag.stride_trigger(every=1))
    m, t = physical_result(solve(r, capture), scales)
    return 100 * m / m.sum(axis=1, keepdims=True), t


def field_frames(r: float) -> tuple[np.ndarray, np.ndarray]:
    """Concentration fields (mol/m^3) of FRAME_CHANNEL at FRAME_TIMES and their actual times (s).

    Each frame is the end of a solve braked at its time, overshooting it by less than one step.
    """
    capture = yag.capture_config(channels=FRAME_CHANNEL, trigger=yag.last_frame_trigger())
    frames = [physical_result(solve(r, capture, final_time=target), scales) for target in FRAME_TIMES]
    return np.stack([c[0, 0] for c, _ in frames]), np.array([t[0] for _, t in frames])


# %% Solve every case

runs = {}
for r in RATIOS:
    p, t = mass_history(r)
    steps = len(t) - 1
    assert np.isfinite(p).all(), f"Solution blew up for r = {r}"

    runs[r] = dict(
        seconds=calculation_time(r),
        steps=steps,
        p=p,
        t=t,
        # Mass percentages exactly at FINAL_TIME, the last step may overshoot it
        # p_final=np.array([np.interp(FINAL_TIME, t, p[:, i]) for i in range(5)]),
        p_final=np.array([p[-1, i] for i in range(5)]),
        frames=field_frames(r),
    )
    print(
        f"r = {r}: {runs[r]['seconds']:.3f} s, {steps} steps, "
        f"{1e3 * runs[r]['seconds'] / steps:.3f} ms/step"
    )

reference = runs[RATIOS[0]]
for run in runs.values():
    run["error"] = np.max(np.abs(run["p_final"] - reference["p_final"]))

# %% Calculation time, steps, dt and accuracy

plt.style.use("ggplot")

labels = [f"r = {r:g}" for r in RATIOS]
colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]
x = np.arange(len(RATIOS))

fig, axes = plt.subplots(2, 2, figsize=(12, 8), constrained_layout=True)
fig.suptitle(
    f"Clamped geometric step, dt_0 = {format_time(DT_0)}, upper bound = {format_time(UPPER_BOUND)}, "
    f"every {EVERY} step(s), {format_time(FINAL_TIME)} reaction"
)

ax = axes[0, 0]
seconds = [runs[r]["seconds"] for r in RATIOS]
bars = ax.bar(x, seconds, color=colors[:len(RATIOS)])
ax.bar_label(bars, labels=[f"{s:.2f} s\n×{reference['seconds'] / s:.1f}" for s in seconds])
ax.set_xticks(x, labels)
ax.set_ylabel("Calculation time (s)")
ax.set_title("Calculation time (speed-up vs. r = 1)")
ax.margins(y=0.25)

ax = axes[0, 1]
steps = [runs[r]["steps"] for r in RATIOS]
bars = ax.bar(x, steps, color=colors[:len(RATIOS)])
ax.bar_label(bars, labels=[f"{s}\n{1e3 * runs[r]['seconds'] / s:.2f} ms/step" for r, s in zip(RATIOS, steps)])
ax.set_xticks(x, labels)
ax.set_ylabel("Time steps")
ax.set_title("Time steps (cost per step)")
ax.margins(y=0.25)

ax = axes[1, 0]
for r, label, color in zip(RATIOS, labels, colors):
    t = runs[r]["t"]
    ax.step(t[1:] / 3600, np.diff(t), where="post", label=label, color=color)
ax.set_xlabel("Reaction time (h)")
ax.set_ylabel("dt (s)")
ax.set_yscale("log")
ax.set_title("Time step size")
ax.legend()

ax = axes[1, 1]
errors = [runs[r]["error"] for r in RATIOS]
bars = ax.bar(x, errors, color=colors[:len(RATIOS)])
ax.bar_label(bars, labels=[f"{e:.2g}" for e in errors])
ax.set_xticks(x, labels)
ax.set_ylabel("Max deviation (percentage points)")
ax.set_title(f"Mass percentages at {format_time(FINAL_TIME)} vs. r = 1")
ax.margins(y=0.25)

plt.show()

# %% Mass percentages over time

fig, axes = plt.subplots(1, 5, figsize=(20, 4), sharex=True, constrained_layout=True)
for i, ax in enumerate(axes):
    for r, label, color in zip(RATIOS, labels, colors):
        ax.plot(runs[r]["t"] / 3600, runs[r]["p"][:, i], label=label, color=color)
    ax.set_title(LABELS[i])
    ax.set_xlabel("Reaction time (h)")
axes[0].set_ylabel("Mass (%)")
axes[-1].legend()
plt.show()

# %% Field frames, rows are ratios, columns are times

species = LABELS[channel_indices(FRAME_CHANNEL)[0]]
vmax = max(run["frames"][0].max() for run in runs.values())

fig, axes = plt.subplots(
    len(RATIOS), len(FRAME_TIMES),
    figsize=(2.6 * len(FRAME_TIMES), 2.6 * len(RATIOS)),
    constrained_layout=True,
)
for row, (r, label) in enumerate(zip(RATIOS, labels)):
    c, t = runs[r]["frames"]
    for col, ax in enumerate(axes[row]):
        im = ax.imshow(c[col], vmin=0.0, vmax=vmax, origin="lower", cmap="viridis")
        # Actual frame time, at most one step past the requested one
        ax.set_title(f"t = {format_time(t[col])}", fontsize=10)
        ax.set_xticks([])
        ax.set_yticks([])
        if col == 0:
            ax.set_ylabel(label)

fig.colorbar(im, ax=axes, shrink=0.6, label=f"{species} concentration (mol/m³)")
plt.show()

# %% Field differences from r = 1 at the same requested times

c_ref, t_ref = reference["frames"]
others = RATIOS[1:]
diffs = {r: runs[r]["frames"][0] - c_ref for r in others}
limit = max(np.abs(d).max() for d in diffs.values())

fig, axes = plt.subplots(
    len(others), len(FRAME_TIMES),
    figsize=(2.6 * len(FRAME_TIMES), 2.6 * len(others)),
    constrained_layout=True,
    squeeze=False,
)
for row, r in enumerate(others):
    t = runs[r]["frames"][1]
    for col, ax in enumerate(axes[row]):
        im = ax.imshow(diffs[r][col], vmin=-limit, vmax=limit, origin="lower", cmap="RdBu_r")
        ax.set_title(f"t = {format_time(t[col])} (ref. {format_time(t_ref[col])})", fontsize=9)
        ax.set_xticks([])
        ax.set_yticks([])
        if col == 0:
            ax.set_ylabel(f"r = {r:g}")

fig.colorbar(im, ax=axes, shrink=0.6, label=f"{species} difference from r = 1 (mol/m³)")
plt.show()
