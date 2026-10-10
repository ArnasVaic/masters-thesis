# %%

from multiprocessing import Pool
import optuna
from optuna.storages import JournalStorage
from optuna.storages.journal import JournalFileBackend

import yag_model as ym
from yag_utils.optimization import evaluate, loss


def objective(trial):
    D = [10**trial.suggest_float(f"logD{i}", -16, -14) for i in range(1, 6)]
    k = [10**trial.suggest_float(f"logk{i}", -9, -7) for i in range(1, 4)]
    return loss(evaluate(ym.model_params(D=D, k=k)))


def run_optimization(_):
    study = optuna.create_study(
        study_name="journal_storage_multiprocess",
        storage=JournalStorage(JournalFileBackend(file_path="./journal.log")),
        load_if_exists=True, # Useful for multi-process or multi-node optimization.
    )
    study.optimize(objective, n_trials=100)

with Pool(processes=16) as pool:
    pool.map(run_optimization, range(16))
# %%
