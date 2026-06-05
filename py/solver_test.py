# %%
import math
import time
import numpy as np
import yag_model as ym
import matplotlib.pyplot as plt

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

def scale_parameters(mp, L0, T0, C0):
    return ym.ModelParameters(
        [D * T0 / (L0**2) for D in mp.D],
        [k * C0 * T0 for k in mp.K] 
    )

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
    # ic = ym.build_checkerboard_initial_condition(disc, 3.91e-14, 3/5 * 3.91e-14)
    # Written in terms of scale but in reality should be 1.0 and 3/5
    ic = ym.build_checkerboard_initial_condition(disc, 3.91e-14 / C0, 3/5 * 3.91e-14 / C0)
    ts = ym.FixedTimeStep(0.01 * disc.dx * disc.dx / mp.D[0])
    print("dt = ", ts.dt)

    t_end = 6 * 60 * 60
    br = ym.TimeBrake(t_end)
    
    # cpt = ym.LastFrameCaptureTrigger(br)

    target_frames = 1000
    frm_stride = math.ceil(t_end / (ts.dt * target_frames))

    cpt = ym.StrideCaptureTrigger(frm_stride)

    # cp = ym.QuantityCapture(1, disc)
    # cp = ym.QuantityCapture(10000, disc)

    # we want like at max a 1000 time steps

    cp = ym.InMemoryFrameCapture(1000, disc)

    return [ disc, mp_nd, ts, br, cpt, cp, ic ]

@timer
def solve(mp, build_cfg):
    cfg = build_cfg(mp)
    ym.solve(*cfg)
    return cfg

def loss(cfg):
    m_total = calculate_m_total(cfg[-1], cfg[0])
    q_pred = np.array(cfg[-2].q_history[:, 0])
    p_pred = MOLAR_MASSES * q_pred / m_total
    return np.mean((p_pred - P_TRUE) ** 2)

def cost(mp, build_cfg):
    cfg = solve(mp, build_cfg)
    return loss(cfg)

# %%

disc, _, _, _, _, cpt, ic = solve(
    ym.ModelParameters(
        [1e-18, 1e-18, 1e-18, 1e-18, 1e-18], 
        [5e4, 2.5e4, 1e4]
    ), 
    build_cfg
)

# %%

m0 = \
    MOLAR_MASSES[0] * ym.quantity(ic[0], disc) + \
    MOLAR_MASSES[1] * ym.quantity(ic[1], disc)

ELEMENT_NAME_STRINGS = [
    '$Al_2O_3$','$Y_2O_3$','$YAM$','$YAP$','$YAG$'
]

m_sum = np.zeros((cpt.size))
for i in range(5):
    qi = np.array([ ym.quantity(cpt.c_history[i, f, :, :], disc) for f in range(cpt.size) ])
    m = qi * MOLAR_MASSES[i]
    m_sum += m
    plt.plot(cpt.t_history[:cpt.size], 100 * m / m0, label=ELEMENT_NAME_STRINGS[i])

plt.plot(cpt.t_history[:cpt.size], 100 * m_sum / m0, label='$\\Sigma$')
plt.xlabel('Reakcijos laikas (s)')
plt.ylabel('Medžiagų masės dalys (%)')
plt.legend()
plt.tight_layout()

# disc = cfg[0]
# for i in range(5):
#     #qi = r.q_history[i]
#     qi = [ ym.quantity(r.c_history[i, frame_id, :, :], disc) for frame_id in range(r.c_history.shape[1]) ]
    
#     plt.plot(qi[:r.size], label=f'$c_{1+i}$')
# plt.legend()
# %%

frame = 800
assert frame < cpt.size
species = 4
plt.title(f"$c_{1+species}(t={cpt.t_history[frame]})$")

print(f"min = {np.min(cpt.c_history)}, max = {np.max(cpt.c_history)}")
mx = np.max(cpt.c_history)

plt.imshow(cpt.c_history[species, frame, :, :], vmin=0.0, vmax=mx)
#plt.imshow(cpt.c_history[species, frame, :, :])

plt.colorbar()
# %%
