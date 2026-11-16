# Best parameters of every case of fit_params.py in one table
#
# Reads the Optuna journals in data/<case>/ (finished or still running) and writes
# data/fitted_params.csv, one row per case with the best trial so far, then prints it.

import csv

import optuna
from yag_utils.constants import FITTED_LOG_D, FITTED_LOG_K, P_TRUE

import cases
from cases import CASES


def main() -> None:
    optuna.logging.set_verbosity(optuna.logging.WARNING)

    rows = []
    for name in CASES:
        if not cases.journal_path(name).exists():
            print(f"{name}: no journal yet")
            continue
        study = optuna.load_study(study_name=name, storage=cases.storage(name))
        row = cases.summary_row(name, study)
        if row is None:
            print(f"{name}: no finished trials yet")
            continue
        rows.append(row)

    path = cases.DATA_DIR / "fitted_params.csv"
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=cases.SUMMARY_FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    print(f"{len(rows)} cases written to {path}\n")

    def line(label, loss, log_D, log_k, p):
        print(
            f"{label:<24} {loss:>8} | " + " ".join(f"{v:7.3f}" for v in log_D) + " | "
            + " ".join(f"{v:7.3f}" for v in log_k) + " | " + " ".join(f"{v:6.2f}" for v in p)
        )

    print(f"{'case':<24} {'loss':>8} | {'logD1..5':<39} | {'logk1..3':<23} | mass % p1..5")
    line("experiment", "", [float("nan")] * 5, [float("nan")] * 3, P_TRUE)
    line("earlier fit (start)", "", FITTED_LOG_D, FITTED_LOG_K, [float("nan")] * 5)
    for r in rows:
        if r["at_edge"]:
            print(f"WARNING: {r['case']}: {r['at_edge']} at the search limit, widen it in cases.py and resume")
    for r in rows:
        line(
            f"{r['case']} ({r['n_complete']})", f"{r['loss']:.4f}",
            [r[f"logD{i}"] for i in range(1, 6)], [r[f"logk{i}"] for i in range(1, 4)],
            [r[f"p{i}"] for i in range(1, 6)],
        )


if __name__ == "__main__":
    main()
