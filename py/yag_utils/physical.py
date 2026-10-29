# Solver components built from physical inputs
#
# Each function mirrors the yag_model factory of the same name, takes values
# in SI units and returns the component in dimensionless units of the given
# scales. Unitless arguments (mesh resolution, growth ratios) pass through.

import yag_model as yag
from yag_model import (
    ClampedGeometricTimeStep,
    Discretization,
    FixedTimeBrake,
    FixedTimeStep,
    GeometricTimeStep,
    ModelParameters,
    SolutionState,
)

from .scaling import Scales, to_dimensionless


def discretization(
        scales: Scales,
        *,
        physical_size: tuple[float, float],
        mesh_resolution: tuple[int, int] = (40, 40)) -> Discretization:
    """Mesh over a domain of physical_size=(width, height) in m."""
    w, h = physical_size
    return yag.discretization(
        mesh_resolution=mesh_resolution,
        physical_size=(scales.dimensionless_length(w), scales.dimensionless_length(h)),
    )


def model_params(scales: Scales, *, D, k) -> ModelParameters:
    """Diffusion D in m^2/s, reaction rates k in m^3/(mol s)."""
    return to_dimensionless(yag.model_params(D=D, k=k), scales)


def checkerboard_initial_condition(
        scales: Scales, disc: Discretization, c1: float, c2: float) -> SolutionState:
    """Checkerboard of concentrations c1, c2 in mol/m^3 on a dimensionless disc."""
    return yag.checkerboard_initial_condition(
        disc, scales.dimensionless_concentration(c1), scales.dimensionless_concentration(c2)
    )


def fixed_step(scales: Scales, *, dt: float) -> FixedTimeStep:
    """Constant step dt in s."""
    return yag.fixed_step(dt=scales.dimensionless_time(dt))


def geometric_step(scales: Scales, *, dt_0: float, r: float) -> GeometricTimeStep:
    """Step growing as dt_0 * r^n, dt_0 in s."""
    return yag.geometric_step(dt_0=scales.dimensionless_time(dt_0), r=r)


def clamped_geometric_step(
        scales: Scales,
        *,
        dt_0: float,
        r: float,
        upper_bound: float,
        every: int = 1) -> ClampedGeometricTimeStep:
    """Step from dt_0, multiplied by r after every `every` steps up to upper_bound, both in s."""
    return yag.clamped_geometric_step(
        dt_0=scales.dimensionless_time(dt_0),
        r=r,
        upper_bound=scales.dimensionless_time(upper_bound),
        every=every,
    )


def fixed_time_brake(scales: Scales, *, final_time: float) -> FixedTimeBrake:
    """Stops once final_time in s is reached."""
    return yag.fixed_time_brake(final_time=scales.dimensionless_time(final_time))
