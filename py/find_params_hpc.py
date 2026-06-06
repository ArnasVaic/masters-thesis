# %%

from multiprocessing import Pool
import optuna
from optuna.storages import JournalStorage, JournalFileStorage
from optuna.storages.journal import JournalFileBackend

import yag_model as ym
from core import solve, build_optimization_config, loss, Scales


def objective(trial):
    scales = Scales(L0=1e-6, C0=3.91e4, D_ref=1e-7)

    D = [10**trial.suggest_float(f"logD{i}", -16, -14) for i in range(1, 6)]
    k = [10**trial.suggest_float(f"logk{i}", -9, -7) for i in range(1, 4)]

    mp = ym.ModelParameters(D, k)
    disc, _, _, _, _, cpt, ic = solve(mp, build_optimization_config, scales)

    return loss(ic, disc, cpt)


def run_optimization(_):
    study = optuna.create_study(
        study_name="journal_storage_multiprocess",
        storage=JournalStorage(JournalFileBackend(file_path="./journal.log")),
        load_if_exists=True, # Useful for multi-process or multi-node optimization.
    )
    study.optimize(objective, n_trials=3)

with Pool(processes=4) as pool:
    pool.map(run_optimization, range(2))
# %%
