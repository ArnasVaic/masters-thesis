# %%

from dataclasses import dataclass
import math
import time
import numpy as np
import yag_model as ym
import matplotlib.pyplot as plt

P_TRUE = np.array([ 29.21, 19.37, 15.08, 24.06, 12.27])
MOLAR_MASSES = np.array([ 102.0, 225.8, 553.58, 163.89, 593.62 ])

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
    mp_nd = ym.ModelParameters(
        [D for D in mp.D],
        [k * C0 * T0 for k in mp.K]
    )
    disc = ym.Discretization(1e-6, 1e-6, 40, 40) #
    ic = ym.build_checkerboard_initial_condition(disc, 3.91e-14 / C0, 3/5 * 3.91e-14 / C0)
    # 6 seconds is a good rough time step that keeps simulation stable
    ts = ym.FixedTimeStep(6) 
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

    print(q_pred.shape)

    p_pred = 100 * MOLAR_MASSES * q_pred / m_total

    print(f"{'Species':<10} {'Predicted':<10} {'True':<10}")
    print("-" * 20)
    pp_sum, pt_sum = 0, 0
    for i, (pp, pt) in enumerate(zip(p_pred, P_TRUE)):
        pp_sum += pp
        pt_sum += pt
        print(f"c_{i+1:<8} {pp:<10.2f} {pt:<10.2f}")

    print("-" * 35)
    print(f"{'total':<10} {pp_sum:<10.2f} {pt_sum:<10.2f}")

    return np.mean((p_pred - P_TRUE) ** 2)

mp = ym.ModelParameters(
    [
        10**-17.151528159149557,
        10**-17.68117146705129,
        10**-17.540303191988034,
        10**-16.97125397545409,
        10**-17.524169541373478,
    ],
    [
        10**4.196087053883452,
        10**4.814049920233035,
        10**3.6630618938287576,
    ]
)

disc, _, _, _, _, cpt, ic = solve(mp, build_cfg)

loss(ic, disc, cpt)
# %%
