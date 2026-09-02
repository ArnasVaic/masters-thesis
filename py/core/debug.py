import numpy as np

from py.core.core import Scales
from yag_model import FixedTimeStep, TimeBrake

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

    if isinstance(ts, FixedTimeStep):
        print(f'[timestep] dt: {ts.dt}')
    else:
        print(f'[timestep] Debug info not implemented!')

    if isinstance(br, TimeBrake):
        print(f'[brake] t_end: {br.t_end}')
        if isinstance(ts, FixedTimeStep):
            print(f'[brake] approx steps: {int(br.t_end / ts.dt)}')
    else:
        print(f'[brake] Debug info not implemented!')