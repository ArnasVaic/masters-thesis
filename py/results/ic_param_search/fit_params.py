# Fit D and k to the 6 hour experiment (1400 C) from each initial condition of cases.py
#
#   python fit_params.py perlin_q1 checkerboard ...   cases by name, one after another
#   python fit_params.py all                          every case, one after another
#   python fit_params.py --case-index 3               the 4th case, for a SLURM array job
#   python fit_params.py --list                       print the cases and their progress
#
# Every case is its own Optuna study, stored in data/<case>/optuna-journal.log. The study is
# run by --workers processes (all CPUs this job may use by default), each one solves a trial,
# asks Optuna for the next one and so on, all sharing the journal. Workers stop once the study
# holds --trials finished trials, so an interrupted or timed out run is resumed by running the
# same command again, and a finished one is extended by a larger --trials. Up to workers - 1
# trials past --trials still finish, as they were already running.
#
# When a case is done its best parameters go to data/<case>/best_params.csv, and
# collect_params.py merges those of all cases into data/fitted_params.csv.

import argparse
import csv
import os
import platform
import socket
import sys
import time
from multiprocessing import get_context

import numpy as np
import optuna
import yag_model as yag
from optuna.study import MaxTrialsCallback
from optuna.trial import TrialState
from yag_utils.constants import FITTED_LOG_D, FITTED_LOG_K, P_TRUE
from yag_utils.optimization import loss

import cases
from cases import CASES, LOG_D_RANGE, LOG_K_RANGE, SCALES

FINISHED = (TrialState.COMPLETE, TrialState.FAIL)


def available_cpus() -> int:
    """CPUs this process may run on: the SLURM allocation or the affinity mask, not the whole node."""
    if "SLURM_CPUS_PER_TASK" in os.environ:
        return int(os.environ["SLURM_CPUS_PER_TASK"])
    return len(os.sched_getaffinity(0))


def log(name: str, who: str, message: str) -> None:
    print(f"{time.strftime('%H:%M:%S')} [{name} {who}] {message}", flush=True)


def fmt(values) -> str:
    return " ".join(f"{v:7.3f}" for v in values)


def finished(study: optuna.Study) -> int:
    return len(study.get_trials(deepcopy=False, states=FINISHED))


def load_study(name: str, sampler: optuna.samplers.BaseSampler | None = None) -> optuna.Study:
    return optuna.create_study(
        study_name=name,
        storage=cases.storage(name),
        sampler=sampler,
        direction="minimize",
        load_if_exists=True,
    )


def worker(name: str, index: int, n_trials: int, cells: int, seed: int) -> None:
    """Runs trials of the case's study until it holds n_trials finished ones."""
    who = f"w{index:02d}"
    # A spawned process starts with Optuna's defaults, its own lines below say the same in one line
    optuna.logging.set_verbosity(optuna.logging.WARNING)
    disc = cases.discretization(cells)
    ic = CASES[name].build(disc)

    # The seed also depends on the trials already in the study, so a resumed run does not repeat
    # the random proposals of the previous one
    done = finished(load_study(name))
    if done >= n_trials:
        return
    sampler_seed = int(np.random.SeedSequence([seed, index, done]).generate_state(1)[0])
    # Constant liar keeps parallel workers from proposing the same point while others still run
    sampler = optuna.samplers.TPESampler(multivariate=True, constant_liar=True, seed=sampler_seed)
    study = load_study(name, sampler)

    def objective(trial: optuna.Trial) -> float:
        log_D = [trial.suggest_float(f"logD{i}", *LOG_D_RANGE) for i in range(1, 6)]
        log_k = [trial.suggest_float(f"logk{i}", *LOG_K_RANGE) for i in range(1, 4)]
        params = yag.model_params(D=[10**d for d in log_D], k=[10**k for k in log_k])

        start = time.perf_counter()
        p_pred, min_c = cases.solve(params, disc, ic)
        solve_s = time.perf_counter() - start

        trial.set_user_attr("p_pred", p_pred.tolist())
        trial.set_user_attr("min_c", min_c)
        trial.set_user_attr("solve_s", solve_s)
        trial.set_user_attr("worker", f"{socket.gethostname()}:{who}")

        # Optuna marks a NaN result as a failed trial, the sampler then avoids that region
        if not np.isfinite(p_pred).all() or not np.isfinite(min_c):
            log(name, who, f"#{trial.number:4d} solution blew up after {solve_s:.1f} s, trial failed")
            return float("nan")
        if min_c < cases.NEGATIVE_TOLERANCE:
            log(name, who, f"#{trial.number:4d} negative concentration {min_c:.3g} after {solve_s:.1f} s, trial failed")
            return float("nan")
        return loss(p_pred)

    def report(study: optuna.Study, trial: optuna.trial.FrozenTrial) -> None:
        if trial.state != TrialState.COMPLETE:
            return
        done = finished(study)
        best = study.best_trial
        log(
            name, who,
            f"#{trial.number:4d} loss {trial.value:9.4f} | best {best.value:9.4f} (#{best.number}) | "
            f"{done}/{n_trials} | solve {trial.user_attrs['solve_s']:5.1f} s | "
            f"logD {fmt(trial.params[f'logD{i}'] for i in range(1, 6))} | "
            f"logk {fmt(trial.params[f'logk{i}'] for i in range(1, 4))}",
        )

    log(name, who, f"started, pid {os.getpid()}")
    study.optimize(
        objective,
        callbacks=[MaxTrialsCallback(n_trials, states=FINISHED), report],
        # A solver error fails that trial only, the worker goes on with the next one
        catch=(Exception,),
    )
    log(name, who, "done")


def describe(name: str, cells: int) -> None:
    """Initial condition and solver setup of the case, to check the job is set up as intended."""
    case = CASES[name]
    disc = cases.discretization(cells)
    ic = case.build(disc)
    c1_part = float(np.mean(np.asarray(ic[0]) > 0))
    D_max = 10 ** LOG_D_RANGE[1] / SCALES.D_ref
    dt = SCALES.dimensionless_time(1.0)
    print(f"  initial condition: {case.ic}, seed trial {case.trial}, end time quantile {case.quantile}")
    print(f"  c1 (Al2O3) = {cases.C1}, c2 (Y2O3) = {cases.C2} dimensionless, c1 takes {100 * c1_part:.1f}% of the area")
    print(f"  mesh {disc.nx} x {disc.ny} ({cells} cells per particle), dx = {disc.dx:.4g}, domain {disc.physical_size}")
    print(f"  dt = 1 s ({dt:.4g} dimensionless), 6 h = {int(6 * 3600)} steps, max 1/2 dt D / dx^2 = {0.5 * dt * D_max / disc.dx**2:.3g}")
    print(f"  search: logD in {LOG_D_RANGE}, logk in {LOG_K_RANGE}, loss = mean squared error of mass % vs {P_TRUE.tolist()}")


def write_best(name: str, study: optuna.Study) -> None:
    row = cases.summary_row(name, study)
    if row is None:
        print(f"[{name}] no finished trials, nothing to write", flush=True)
        return

    path = cases.best_params_path(name)
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=cases.SUMMARY_FIELDS)
        writer.writeheader()
        writer.writerow(row)

    print(f"[{name}] best trial #{row['best_trial']} of {row['n_complete']} ({row['n_fail']} failed), loss {row['loss']:.4f}")
    print(f"[{name}] logD {fmt(row[f'logD{i}'] for i in range(1, 6))}")
    print(f"[{name}] logk {fmt(row[f'logk{i}'] for i in range(1, 4))}")
    print(f"[{name}] {'species':<8} {'pred %':>8} {'true %':>8}")
    for i, (pred, true) in enumerate(zip([row[f"p{i}"] for i in range(1, 6)], P_TRUE), 1):
        print(f"[{name}] c_{i:<6} {pred:8.2f} {true:8.2f}")
    if row["at_edge"]:
        print(f"[{name}] WARNING: {row['at_edge']} at the search limit, widen it in cases.py and resume", flush=True)
    print(f"[{name}] written to {path}", flush=True)


def run_case(name: str, n_trials: int, workers: int, cells: int, seed: int) -> None:
    print(f"\n=== {name}", flush=True)
    describe(name, cells)

    study = load_study(name)
    stored_cells = study.user_attrs.get("cells_per_particle")
    if stored_cells is not None and stored_cells != cells:
        sys.exit(
            f"[{name}] the study was run with --cells {stored_cells}, not {cells}. Use the same mesh, "
            f"or move {cases.journal_path(name)} away to start over."
        )
    study.set_user_attr("cells_per_particle", cells)

    if not study.trials:
        # Start from the parameters fitted earlier on the 1 x 1 um checkerboard domain
        # (FITTED_LOG_D/K in yag_utils.constants), a known good point
        study.enqueue_trial(
            {**{f"logD{i}": d for i, d in enumerate(FITTED_LOG_D, 1)},
             **{f"logk{i}": k for i, k in enumerate(FITTED_LOG_K, 1)}}
        )
        print("  new study, the first trial is the earlier fit (yag_utils.constants FITTED_LOG_D/K)", flush=True)

    done = finished(study)
    print(f"  journal {cases.journal_path(name)}: {done} finished trials, target {n_trials}", flush=True)
    if done >= n_trials:
        print("  already done", flush=True)
    else:
        workers = min(workers, n_trials - done)
        print(f"  starting {workers} workers", flush=True)
        start = time.time()
        # spawn: workers import everything anew instead of inheriting the parent's open journal
        processes = [
            get_context("spawn").Process(target=worker, args=(name, i, n_trials, cells, seed), daemon=True)
            for i in range(workers)
        ]
        for p in processes:
            p.start()
        try:
            for p in processes:
                p.join()
        except KeyboardInterrupt:
            print(f"[{name}] interrupted, stopping workers, running trials are lost", flush=True)
            for p in processes:
                p.terminate()
            raise
        failed = [p.exitcode for p in processes if p.exitcode != 0]
        if failed:
            print(f"[{name}] WARNING: {len(failed)} workers exited with codes {failed}", flush=True)
        print(f"[{name}] {finished(load_study(name)) - done} trials in {(time.time() - start) / 60:.1f} min", flush=True)

    write_best(name, load_study(name))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("cases", nargs="*", help=f"case names or 'all': {', '.join(CASES)}")
    parser.add_argument("--case-index", type=int, help="run only the case at this index (SLURM_ARRAY_TASK_ID)")
    parser.add_argument("--trials", type=int, default=1500, help="finished trials per case (default 1500)")
    parser.add_argument("--workers", type=int, default=available_cpus(), help="parallel solves (default: all CPUs)")
    parser.add_argument("--cells", type=int, default=cases.DEFAULT_CELLS_PER_PARTICLE, help="mesh cells per particle side")
    parser.add_argument("--seed", type=int, default=0, help="sampler seed, mixed with the worker index and the trials already done")
    parser.add_argument("--list", action="store_true", help="print the cases and their progress, then exit")
    args = parser.parse_args()

    optuna.logging.set_verbosity(optuna.logging.WARNING)

    if args.cells % 2:
        parser.error("--cells must be even, the checkerboard is made of blocks of half a particle")

    if args.list:
        for i, name in enumerate(CASES):
            done = finished(load_study(name)) if cases.journal_path(name).exists() else 0
            print(f"{i}: {name:<24} {done} finished trials")
        return

    if args.case_index is not None:
        names = [list(CASES)[args.case_index]]
    elif args.cases == ["all"]:
        names = list(CASES)
    elif args.cases:
        unknown = [c for c in args.cases if c not in CASES]
        if unknown:
            parser.error(f"unknown cases {unknown}, choose from {list(CASES)}")
        names = args.cases
    else:
        parser.error("give case names, 'all' or --case-index")

    print(f"host {socket.gethostname()}, python {platform.python_version()}, optuna {optuna.__version__}")
    print(f"cpus available {available_cpus()} (node has {os.cpu_count()}), workers {args.workers}")
    print(f"slurm job {os.environ.get('SLURM_JOB_ID', '-')}, array task {os.environ.get('SLURM_ARRAY_TASK_ID', '-')}")
    print(f"cases {names}, {args.trials} trials each, data in {cases.DATA_DIR}", flush=True)

    start = time.time()
    for name in names:
        run_case(name, args.trials, args.workers, args.cells, args.seed)
    print(f"\nall done in {(time.time() - start) / 60:.1f} min", flush=True)


if __name__ == "__main__":
    main()
