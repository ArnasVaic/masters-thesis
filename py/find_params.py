# %%

from dataclasses import dataclass
import math
import time
import numpy as np
import yag_model as ym
import matplotlib.pyplot as plt
import optuna

P_TRUE = np.array([ 29.21, 19.37, 15.08, 24.06, 12.27])
MOLAR_MASSES = np.array([ 102.0, 225.8, 553.58, 163.89, 593.62 ])

def scale_parameters(mp, L0, T0, C0):
    mp_nd = ym.ModelParameters()

    mp_nd.D = np.array([D * T0 / (L0**2) for D in mp.D])
    mp_nd.K = np.array([k * C0 * T0 for k in mp.K])

    return mp_nd

def calculate_m_total(state: ym.SolutionState, disc: ym.Discretization) -> float:
    m_total = 0
    for species in range(5):
        M = MOLAR_MASSES[species]
        q = ym.quantity(state[species], disc)
        m_total += M * q
    return m_total

def build_cfg(mp: ym.ModelParameters):
    L0 = 1e-6
    T0 = L0**2 / mp.D[0]
    C0 = 3.91e-14
    # mp_nd = scale_parameters(mp, L0, T0, C0)

    mp_nd = ym.ModelParameters(
        [D for D in mp.D],
        [k * C0 * T0 for k in mp.K]
    )

    disc = ym.Discretization(1e-6, 1e-6, 40, 40) #
    ic = ym.build_checkerboard_initial_condition(disc, 3.91e-14 / C0, 3/5 * 3.91e-14 / C0)

    # ts = ym.FixedTimeStep(0.01 * disc.dx * disc.dx / mp.D[0])
    ts = ym.FixedTimeStep(6) # 6 seconds is a good rough time step that keeps simulation stable

    t_end = 6 * 60 * 60
    br = ym.TimeBrake(t_end)
    
    cpt = ym.LastFrameCaptureTrigger(br)
    # target_frames = 1000
    # frm_stride = math.ceil(t_end / (ts.dt * target_frames))
    # cpt = ym.StrideCaptureTrigger(frm_stride)

    cp = ym.QuantityCapture(1, disc)
    # cp = ym.QuantityCapture(1000, disc)
    # cp = ym.InMemoryFrameCapture(1000, disc)

    return [ disc, mp_nd, ts, br, cpt, cp, ic ]

def solve(mp, build_cfg):
    cfg = build_cfg(mp)
    ym.solve(*cfg)
    return cfg

def loss(ic, disc, cpt):
    m_total = calculate_m_total(ic, disc)
    q_pred = np.array(cpt.q_history[:, 0])
    p_pred = 100 * MOLAR_MASSES * q_pred / m_total
    return np.mean((p_pred - P_TRUE) ** 2)

def cost(mp, build_cfg):
    cfg = solve(mp, build_cfg)
    return loss(cfg)

def objective(trial):

    logD1 = trial.suggest_float("logD1", -18, -16)
    logD2 = trial.suggest_float("logD2", -18, -16)
    logD3 = trial.suggest_float("logD3", -18, -16)
    logD4 = trial.suggest_float("logD4", -18, -16)
    logD5 = trial.suggest_float("logD5", -18, -16)

    logk1 = trial.suggest_float("logk1", 3, 5)
    logk2 = trial.suggest_float("logk2", 3, 5)    
    logk3 = trial.suggest_float("logk3", 3, 5)
    
    mp = ym.ModelParameters(
        [10**logD1, 10**logD2, 10**logD3, 10**logD4, 10**logD4],
        [10**logk1, 10**logk2, 10**logk3]
    )
    disc, _, _, _, _, cpt, ic = solve(mp, build_cfg)

    return loss(ic, disc, cpt)

study = optuna.create_study(
    study_name="yag_model_params",
    storage="sqlite:///reaction.db",
    load_if_exists=True,
    direction="minimize"
)

study.optimize(objective, n_trials=100)



# %%

from optuna.visualization import plot_optimization_history

fig = plot_optimization_history(study)
fig.show()
# %%
