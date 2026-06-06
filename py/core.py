import yag_model as ym
import numpy as np

# Experimental data, element percentage by mass after 6hrs at 1400C
P_TRUE = np.array([ 29.21, 19.37, 15.08, 24.06, 12.27])

# Molar masses of elements within synthesis
MOLAR_MASSES = np.array([ 102.0, 225.8, 553.58, 163.89, 593.62 ])

class Scales:
    def __init__(self, L0, C0, D_ref):
        self.L0 = L0
        self.C0 = C0
        self.D_ref = D_ref
        self.T0 = L0 **2 / D_ref

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

def solve(mp, build_cfg, scales: Scales):
    cfg = build_cfg(mp, scales)
    ym.solve(*cfg)
    return cfg

def config_info(cfg, scales: Scales):
    disc, mp_nd, ts, br, cpt, cp, ic = cfg

    L0, T0, C0, D_ref = scales.L0, scales.T0, scales.C0, scales.D_ref
    print(f'[scales] L0: {L0}, T0: {T0}, C0: {C0}, D_ref: {D_ref}')

    print(f'[initial condition] max c_Al2O3(t=0): {np.max(ic[0])}, max c_Y2O3(t=0): {np.max(ic[1])}')
    
    mu_x = 0.5 * ts.dt / (disc.dx**2) * mp_nd.D
    mu_y = 0.5 * ts.dt / (disc.dy**2) * mp_nd.D
    print(f'[internal solver] mu_x: 1/2 dt D / dx^2, mu_y: 1/2 dt D / dy^2 ')
    print(f'[internal solver] mu_x: {mu_x}')
    print(f'[internal solver] mu_y: {mu_y}')

    print(f'[mesh] resolution: {disc.mesh_res_x} x {disc.mesh_res_y}')
    print(f'[mesh] phys. size: {disc.physical_space_w} x {disc.physical_space_h}')
    print(f'[mesh] dx = {disc.dx}, dy: {disc.dy}')

    print(f'[params] D: {mp_nd.D}')
    print(f'[params] D: {mp_nd.K}')

    if isinstance(ts, ym.FixedTimeStep):
        print(f'[timestep] dt: {ts.dt}')
    else:
        print(f'[timestep] Debug info not implemented!')

    if isinstance(br, ym.TimeBrake):
        print(f'[brake] t_end: {br.t_end}')
        if isinstance(ts, ym.FixedTimeStep):
            print(f'[brake] approx steps: {int(br.t_end / ts.dt)}')
    else:
        print(f'[brake] Debug info not implemented!')

# Solver configuration for optimization
# - Hardcoded timestep
# - Rescaled model parameters
# - Only save quantity before brake
# - Parameters for 1400C at 6hrs
def build_optimization_config(mp: ym.ModelParameters, scales: Scales):

    L0, T0, C0, D_ref = scales.L0, scales.T0, scales.C0, scales.D_ref

    # Dimensionless model parameters
    mp_nd = ym.ModelParameters(
        [D / D_ref for D in mp.D],
        [k * C0 * T0 for k in mp.K]
    )

    # Dimensionless discretization, better for numerics, we define L0 which is a
    # micrometer constants
    disc = ym.Discretization(1e-6 / L0, 1e-6 / L0, 40, 40)

    # Dimensionless concentration is preferred for numerical stability,
    # account for this by scaling reaction coefficients. Resulting mass
    # parts would be scaled by the same constant so when optimizing 
    # parameters this doesn't matter much.
    ic = ym.build_checkerboard_initial_condition(
        disc, 
        3.91e4 / C0, 
        3/5 * 3.91e4 / C0
    )
    
    # We know the rough order of parameters so we can hardcode the timestep
    # because the simulation remains stable if this is used. Alternatively
    # time step could be chosen as a ratio dx^2 / D which would ensure comfortable
    # ADI solver cache constants and avoid numerical instabilities.
    time_step = 1.0 / T0 # scaled
    ts = ym.FixedTimeStep(time_step)

    # Concrete experiment time we're optimizing for is 6 hours
    t_end = 6 * 60 * 60 / T0
    br = ym.TimeBrake(t_end)
    
    # This run is only used for parameter search so we do not need to
    # capture any data other than the last quantity before braking at 6 hrs.
    cpt = ym.LastFrameCaptureTrigger(br)

    # For storage we only need 1 time step
    cp = ym.QuantityCapture(1, disc)

    return [ disc, mp_nd, ts, br, cpt, cp, ic ]