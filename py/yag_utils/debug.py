# Human readable summary of a solver setup

import numpy as np
from yag_model import FixedTimeBrake, FixedTimeStep, ModelParameters, SolutionState, SolverConfig

from .scaling import Scales


def config_info(config: SolverConfig, ic: SolutionState, params: ModelParameters, scales: Scales):
    """Print scales, mesh, (dimensionless) parameters and solver constants."""
    disc, step, brake = config.discretization, config.step, config.brake

    print(f'[scales] L0: {scales.L0}, T0: {scales.T0}, C0: {scales.C0}, D_ref: {scales.D_ref}')

    print(f'[initial condition] max c_Al2O3(t=0): {np.max(ic[0])}, max c_Y2O3(t=0): {np.max(ic[1])}')

    if isinstance(step, FixedTimeStep):
        mu_x = 0.5 * step.dt / (disc.dx**2) * params.D
        mu_y = 0.5 * step.dt / (disc.dy**2) * params.D
        print(f'[internal solver] mu_x: 1/2 dt D / dx^2, mu_y: 1/2 dt D / dy^2 ')
        print(f'[internal solver] mu_x: {mu_x}')
        print(f'[internal solver] mu_y: {mu_y}')

    print(f'[mesh] resolution: {disc.nx} x {disc.ny}')
    print(f'[mesh] phys. size: {disc.physical_size[0]} x {disc.physical_size[1]}')
    print(f'[mesh] dx = {disc.dx}, dy: {disc.dy}')

    print(f'[params] D: {params.D}')
    print(f'[params] k: {params.k}')

    if isinstance(step, FixedTimeStep):
        print(f'[timestep] dt: {step.dt}')
    else:
        print(f'[timestep] Debug info not implemented!')

    if isinstance(brake, FixedTimeBrake):
        print(f'[brake] final_time: {brake.final_time}')
        if isinstance(step, FixedTimeStep):
            print(f'[brake] approx steps: {int(brake.final_time / step.dt)}')
    else:
        print(f'[brake] Debug info not implemented!')
