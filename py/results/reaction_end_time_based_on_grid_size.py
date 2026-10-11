# %%

import csv
import os
import signal
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait

import matplotlib.pyplot as plt
import numpy as np
import yag_model as yag
import yag_utils.initial_conditions as ics
from tqdm.auto import tqdm
from yag_utils.paths import repo_root

MAX_SIZE = 20
TRIALS_PER_SIZE = 100
# Trials run in parallel threads (solve releases the GIL), one per physical core by default
WORKERS = max(1, (os.cpu_count() or 2) // 2)

# One row per finished trial, appended as soon as the trial ends. Rerunning skips
# trials already in the file, so the script can be interrupted and resumed.
# Delete the file (or change the name) after changing the setup below.
RESULTS_PATH = repo_root() / "py" / "results" / "data" / "reaction_end_time_based_on_grid_size.csv"
FIELDS = ["size", "trial", "end_time"]


def load_end_times(path) -> dict[tuple[int, int], float]:
    if not path.exists():
        return {}
    with open(path, newline="") as f:
        return {(int(r["size"]), int(r["trial"])): float(r["end_time"]) for r in csv.DictReader(f)}


def reaction_end_time(size: int, trial: int) -> float:
    # in total there will be size^2 particles (squares)
    # mesh resolution of a single Al2O3 / Y2O3 particle (square) is 20x20
    config = yag.solver_config(
        discretization=yag.discretization(
            # begin from usual 40 x 40 resolution, growing by one particle per side each size
            mesh_resolution=(20 * size, 20 * size),
            # Dimensionless like D and k: a particle is 0.5 x 0.5 (0.5 um with L0 = 1 um).
            # Sizes in metres make D * dt / dx^2 ~ 1e7 and the solution blows up
            physical_size=(0.5 * size, 0.5 * size),
        ),
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

    # Seeded by (size, trial) so a resumed run uses the same initial conditions
    ic = ics.random_rectangles(
        config.discretization,
        5.0,
        3.0,
        (size, size),
        size**2 // 2,
        rng=np.random.default_rng([size, trial]),
    )

    params = yag.model_params(D=[1e-2] * 5, k=[10] * 3)

    masses, times = yag.solve(config, ic, params).all()
    if not np.isfinite(masses).all():
        raise RuntimeError(f"Solution blew up for size {size}, trial {trial}")
    return float(times[-1])


# %%
RESULTS_PATH.parent.mkdir(parents=True, exist_ok=True)
end_times = load_end_times(RESULTS_PATH)
sizes = range(2, MAX_SIZE + 1)
todo = [(s, t) for s in sizes for t in range(TRIALS_PER_SIZE) if (s, t) not in end_times]
remaining = {s: sum(1 for ts, _ in todo if ts == s) for s in sizes}

with open(RESULTS_PATH, "a", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=FIELDS)
    if f.tell() == 0:
        writer.writeheader()

    size_bar = tqdm(total=len(sizes), initial=sum(n == 0 for n in remaining.values()), desc="sizes")
    trial_total = len(sizes) * TRIALS_PER_SIZE
    trial_bar = tqdm(total=trial_total, initial=trial_total - len(todo), desc="trials")

    def record(future, size, trial):
        # Called on the main thread only, so the file and the bars need no locking
        end_times[(size, trial)] = t_end = future.result()
        writer.writerow({"size": size, "trial": trial, "end_time": t_end})
        f.flush()
        trial_bar.update()

        remaining[size] -= 1
        if remaining[size] == 0:
            done = [end_times[(size, t)] for t in range(TRIALS_PER_SIZE)]
            size_bar.update()
            size_bar.set_postfix(size=size, avg_end_time=f"{np.mean(done):.4g}")

    # Ctrl+C (or interrupting the kernel) only counts here and the loop below reacts to it. A
    # KeyboardInterrupt raised inside concurrent.futures can leave its locks held and deadlock.
    interrupts = 0

    def on_interrupt(signum, frame):
        global interrupts
        interrupts += 1

    executor = ThreadPoolExecutor(max_workers=WORKERS)
    # Submitted smallest size first, so sizes finish (and are averaged) roughly in order
    futures = {executor.submit(reaction_end_time, s, t): (s, t) for s, t in todo}
    pending = set(futures)
    previous_handler = signal.signal(signal.SIGINT, on_interrupt)
    try:
        cancelled = False
        while pending:
            done, pending = wait(pending, timeout=0.5, return_when=FIRST_COMPLETED)
            for future in done:
                if not future.cancelled():
                    record(future, *futures[future])

            if interrupts >= 1 and not cancelled:
                # Queued trials are dropped. Running ones cannot be stopped mid-solve, so wait for
                # them and save their results too
                cancelled = True
                pending = {f_ for f_ in pending if not f_.cancel()}
                tqdm.write(
                    f"Interrupted, saving the {len(pending)} trials still running "
                    "(interrupt again to drop them)..."
                )
            if interrupts >= 2:
                tqdm.write(f"Dropped {len(pending)} running trials")
                break
    finally:
        signal.signal(signal.SIGINT, previous_handler)
        executor.shutdown(wait=False, cancel_futures=True)
        trial_bar.close()
        size_bar.close()

    if interrupts:
        # Stop here instead of going on to the plot
        raise KeyboardInterrupt

# %%

end_times = load_end_times(RESULTS_PATH)
sizes = sorted({s for s, _ in end_times})
per_size = [np.array([t for (s, _), t in end_times.items() if s == size]) for size in sizes]
means = np.array([t.mean() for t in per_size])
stds = np.array([t.std() for t in per_size])

for size, t in zip(sizes, per_size):
    print(f"size {size:2d}: {len(t):3d} trials, end time {t.mean():.4g} ± {t.std():.2g}")

plt.errorbar(sizes, means, yerr=stds, marker="o", capsize=3)
plt.xlabel("particles per side")
plt.ylabel("reaction end time")
plt.grid(True)
plt.show()
