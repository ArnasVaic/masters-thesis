# %%
import time
import numpy as np
import yag_model as ym
import matplotlib.pyplot as plt

# disc = ym.Discretization(0.5, 0.3, 40, 40)

# ic = ym.build_checkerboard_initial_condition(disc, 1.0, 1.0)

# q0 = ym.reagent_quantity(ic, disc)

# mp = ym.ModelParameters(
#     [1e-4, 1e-4, 1e-4, 1e-4, 1e-4],
#     [100.0, 50.0, 20.0]
# )

# ts = ym.ClampedGeometricReagentQuantityThresholdStep(
#     1000,
#     0.0001,
#     2.0,
#     0.01,
#     0.0001,
#     0.03,
#     q0,
#     disc,
# )

# br = ym.FixedStepBrake(10000)
# cpt = ym.StrideCaptureTrigger(1)
# # cp = ym.QuantityCapture(10000, disc)
# cp = ym.InMemoryFrameCapture(10000, disc)

# # %%
# ym.solve(disc, mp, ts, br, cpt, cp, ic)

# # %%
# plt.plot(np.diff(cp.t_history))

# # %%
# plt.imshow(cp.c_history[4, 9000, :, :])
# plt.colorbar()

# %%

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()

        print(f"{func.__name__} took {end - start:.6f} seconds")
        return result

    return wrapper

P_TRUE = [ 29.21, 19.37, 15.08, 24.06, 12.27]
MOLAR_MASSES = [ 102.0, 225.8, 553.58, 163.89, 593.62 ]

def calculate_m_total(state: ym.SolutionState, disc: ym.Discretization) -> float:
    m_total = 0
    for species in range(5):
        M = MOLAR_MASSES[species]
        q = ym.quantity(state[species], disc)
        m_total += M * q
    return m_total

def build_cfg(mp: ym.ModelParameters):
    disc = ym.Discretization(5e-6, 3e-6, 40, 40)
    ic = ym.build_checkerboard_initial_condition(disc, 5e-6, 3e-6)
    # q0 = ym.reagent_quantity(ic, disc)
    # ts = ym.ClampedGeometricReagentQuantityThresholdStep(1000, 0.0001, 2.0, 0.01, 0.0001, 0.03, q0, disc)
    ts = ym.FixedTimeStep(0.01)
    # Fitting to 6hrs so need to continue further
    br = ym.TimeBrake(6 * 60 * 60)
    cpt = ym.LastFrameCaptureTrigger(br)
    cp = ym.QuantityCapture(2, disc)
    return [ disc, mp, ts, br, cpt, cp, ic ]

def solve(mp, build_cfg):
    cfg = build_cfg(mp)
    ym.solve(*cfg)
    return cfg

def loss(cfg):
    m_total = calculate_m_total(cfg[-1], cfg[0])
    q_pred = np.array(cfg[-2].q_history[:, 0])
    p_pred = MOLAR_MASSES * q_pred / m_total
    return np.mean((p_pred - P_TRUE) ** 2)

@timer
def cost(mp, build_cfg):
    cfg = solve(mp, build_cfg)
    return loss(cfg)

# %%

mp = ym.ModelParameters(
    [1e-4, 1e-4, 1e-4, 1e-4, 1e-4], 
    [100.0, 50.0, 20.0]
)

cfg = solve(mp, build_cfg)

L = loss(cfg)
# %%
