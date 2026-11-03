# %%
# Sanity checks of the shared runner, at the size of the parameter search
#
# 1. Determinism: the same seed gives the same initial condition and the same results.
# 2. Timing: one solve per IC type alone on the machine, ending at the reaction end and at
#    6 h (the fitting runs), to budget seed selection and the parameter search.
# 3. References: seed 0 of every IC type against its fixed 1 s step reference, appended to
#    runs.csv like any other case.

import numpy as np
from runner import FIELDS, RunParams, initial_condition, load_runs, run_case, run_cases
from yag_utils.batch import run_batch
from yag_utils.particles import PARTICLE_ICS

SIZE = 16
SEEDS = {ic: [0, 1] if spec.seeded else [0] for ic, spec in PARTICLE_ICS.items()}

# %% 1. Determinism

for ic, seeds in SEEDS.items():
    for seed in seeds:
        a, b = initial_condition(ic, seed, SIZE), initial_condition(ic, seed, SIZE)
        assert all(np.array_equal(np.asarray(a[i]), np.asarray(b[i])) for i in range(len(a))), (ic, seed)
    if len(seeds) > 1:
        a, b = (initial_condition(ic, seed, SIZE) for seed in seeds[:2])
        assert not np.array_equal(np.asarray(a[0]), np.asarray(b[0])), f"{ic}: seeds give the same IC"
print("Initial conditions: identical per seed, different across seeds")

# Every IC type solved twice in parallel, all results but the wall time must match exactly
tasks = [(ic, 0, SIZE, RunParams(), False) for ic in SEEDS for _ in range(2)]
rows = {}
run_batch(run_case, tasks, lambda task, row: rows.setdefault(task[0], []).append(row))

for ic, (a, b) in rows.items():
    differing = [f for f in FIELDS if f != "solve_time" and str(a.get(f)) != str(b.get(f))]
    assert not differing, f"{ic}: {differing}"
    print(f"{ic}: identical results, {a['steps']} steps, end at {a['end_time'] / 3600:.2f} h")

# %% 2. Timing, one solve at a time so the wall time is not shared with other solves

timings = {}
for ic in SEEDS:
    for label, params in [("reaction end", RunParams()), ("6 h", RunParams(final_time=6 * 60 * 60))]:
        row = run_case(ic, 0, SIZE, params, deviation=False)
        timings[ic, label] = row
        print(
            f"{ic:18s} to {label:12s}: {row['solve_time']:6.2f} s, {row['steps']} steps, "
            f"{1e3 * row['solve_time'] / row['steps']:.2f} ms/step"
        )

# %% 3. References and the deviation of r = 1.001 from them

cases = [(ic, 0, SIZE, params) for ic in SEEDS for params in (RunParams().reference(), RunParams())]
run_cases(cases)

runs = {(r["ic"], float(r["r"])): r for r in load_runs() if int(r["size"]) == SIZE and r["seed"] == "0"}
for ic in SEEDS:
    ref, run = runs[ic, 1.0], runs[ic, 1.001]
    print(
        f"{ic:18s}: reference {float(ref['solve_time']):6.1f} s / {ref['steps']} steps, "
        f"r = 1.001 {float(run['solve_time']):5.1f} s / {run['steps']} steps; "
        f"end time {float(run['dev_end_time_pct']):+.3f}%, deviation at end "
        f"{float(run['dev_end_pp']):.3g} pp, at 6 h {float(run['dev_6h_pp']):.3g} pp, "
        f"max {float(run['dev_max_pp']):.3g} pp"
    )
