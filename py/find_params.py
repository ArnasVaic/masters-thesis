# %%

import yag_model as ym
import optuna
from core import solve, build_optimization_config, loss

def objective(trial):
    D = [10**trial.suggest_float(f"logD{i}", -7, -5) for i in range(1, 6)]
    k = [10**trial.suggest_float(f"logk{i}", 9, 11) for i in range(1, 4)]
    mp = ym.ModelParameters(D, k)
    disc, _, _, _, _, cpt, ic = solve(mp, build_optimization_config)
    return loss(ic, disc, cpt)

study = optuna.create_study(
    study_name="yag_model_params",
    storage="sqlite:///reaction.db",
    load_if_exists=True,
    direction="minimize"
)

study.optimize(objective, n_trials=100)

# %%
