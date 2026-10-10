# %%

import optuna
import yag_model as ym
from yag_utils.optimization import evaluate, loss


def objective(trial):
    D = [10**trial.suggest_float(f"logD{i}", -16, -14) for i in range(1, 6)]
    k = [10**trial.suggest_float(f"logk{i}", -9, -7) for i in range(1, 4)]
    return loss(evaluate(ym.model_params(D=D, k=k)))

study = optuna.create_study(
    study_name="yag_model_params",
    storage="sqlite:///reaction.db",
    load_if_exists=True,
    direction="minimize"
)

study.optimize(objective, n_trials=100)

# %%
