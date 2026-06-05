import yag_model as ym
import numpy as np

# Experimental data, element percentage by mass after 6hrs at 1400C
P_TRUE = np.array([ 29.21, 19.37, 15.08, 24.06, 12.27])

# Molar masses of elements within synthesis
MOLAR_MASSES = np.array([ 102.0, 225.8, 553.58, 163.89, 593.62 ])

def last_frame_mass_from_q(cpt: ym.QuantityCapture):
    q_pred = np.array(cpt.q_history[:, 0])
    return MOLAR_MASSES * q_pred

def mass(state: ym.SolutionState, speciesIdx: int, disc: ym.Discretization):
    M = MOLAR_MASSES[speciesIdx]
    q = ym.quantity(state[speciesIdx], disc)
    return M * q

def total_mass(state: ym.SolutionState, disc: ym.Discretization) -> float:
    return sum([ mass(state, i, disc) for i in range(5) ])

def get_p_pred(ic, disc, cpt):
    m0 = total_mass(ic, disc)
    q_pred = last_frame_mass_from_q(cpt)
    return 100 * q_pred / m0

def loss(ic, disc, cpt):
    p_pred = get_p_pred(ic, disc, cpt)
    return np.mean((p_pred - P_TRUE) ** 2)

def solve(mp, build_cfg):
    cfg = build_cfg(mp)
    ym.solve(*cfg)
    return cfg

def config_info(cfg):
    print('')

# Solver configuration for optimization
# - Hardcoded timestep
# - Rescaled model parameters
# - Only save quantity before brake
# - Parameters for 1400C at 6hrs
def build_optimization_config(mp: ym.ModelParameters):

    # Diffusion scaling for numerical stability
    D_ref = 1e4

    # um (other constants are already in terms of um)
    L0 = 1.0
    # um^2 / (um^2 / s) ~ s
    T0 = L0**2 / D_ref
    # mol / um^3
    C0 = 3.91e-14

    # Dimensionless model parameters
    mp_nd = ym.ModelParameters(
        [D / D_ref for D in mp.D],
        [k * C0 * T0 for k in mp.K]
    )

    # Dimensionless discretization, better for numerics, we define L0 which is a
    # micrometer constants
    disc = ym.Discretization(1.0 / L0, 1.0 / L0, 40, 40)

    # Dimensionless concentration is preferred for numerical stability,
    # account for this by scaling reaction coefficients. Resulting mass
    # parts would be scaled by the same constant so when optimizing 
    # parameters this doesn't matter much.
    ic = ym.build_checkerboard_initial_condition(
        disc, 
        1.0, 
        3/5
    )
    
    # We know the rough order of parameters so we can hardcode the timestep
    # because the simulation remains stable if this is used. Alternatively
    # time step could be chosen as a ratio dx^2 / D which would ensure comfortable
    # ADI solver cache constants and avoid numerical instabilities.
    time_step = 6.0 / T0 # scaled
    ts = ym.FixedTimeStep(time_step)

    # Concrete experiment time we're optimizing for is 6 hours
    t_end = 6 * 60 * 60 / T0
    br = ym.TimeBrake(t_end)
    
    # This run is only used for parameter search so we do not need to
    # capture any data other than the last quantity before braking at 6 hrs.
    cpt = ym.LastFrameCaptureTrigger(br)

    # For storage we only need 1 time step
    cp = ym.QuantityCapture(1, disc)

    cfg = [ disc, mp_nd, ts, br, cpt, cp, ic ]
    config_info(cfg)
    return cfg