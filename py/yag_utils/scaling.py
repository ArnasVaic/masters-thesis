# Nondimensionalization of the model
#
# The solver behaves best with values of order one, so physical inputs are
# rescaled by characteristic length L0, concentration C0 and diffusion D_ref.
# Substituting x = L0 x*, t = T0 t*, c = C0 c* keeps the model in the same
# form with D* = D / D_ref and k* = k C0 T0, where T0 = L0^2 / D_ref.
#
# The solver works in 2D, so molar quantities (and masses) are per unit depth
# and scale by Q0 = C0 L0^2. Molar masses are not rescaled.

from dataclasses import dataclass

import numpy as np
import yag_model as yag
from yag_model import Discretization, IResult, ModelParameters


@dataclass(frozen=True)
class Scales:
    L0: float
    C0: float
    D_ref: float

    @property
    def T0(self) -> float:
        """Characteristic time L0^2 / D_ref."""
        return self.L0 ** 2 / self.D_ref

    @property
    def Q0(self) -> float:
        """Characteristic molar quantity C0 L0^2, masses scale the same way."""
        return self.C0 * self.L0 ** 2

    # Physical -> dimensionless

    def dimensionless_length(self, x):
        return x / self.L0

    def dimensionless_time(self, t):
        return t / self.T0

    def dimensionless_concentration(self, c):
        return c / self.C0

    def dimensionless_quantity(self, q):
        return q / self.Q0

    # Dimensionless -> physical

    def physical_length(self, x):
        return x * self.L0

    def physical_time(self, t):
        return t * self.T0

    def physical_concentration(self, c):
        return c * self.C0

    def physical_quantity(self, q):
        return q * self.Q0


def to_dimensionless(params: ModelParameters, scales: Scales) -> ModelParameters:
    return ModelParameters(
        D=params.D / scales.D_ref,
        k=params.k * scales.C0 * scales.T0,
    )


def to_physical(params: ModelParameters, scales: Scales) -> ModelParameters:
    return ModelParameters(
        D=params.D * scales.D_ref,
        k=params.k / (scales.C0 * scales.T0),
    )


def physical_discretization(disc: Discretization, scales: Scales) -> Discretization:
    """Same mesh as a dimensionless disc, sized in physical units."""
    w, h = disc.physical_size
    return yag.discretization(
        mesh_resolution=disc.mesh_resolution,
        physical_size=(scales.physical_length(w), scales.physical_length(h)),
    )


def physical_values(values: np.ndarray, reducer: str, scales: Scales) -> np.ndarray:
    """Captured frames of the given reducer in physical units."""
    match reducer:
        case "concentration_field" | "density_field":
            return scales.physical_concentration(values)
        case "total_molar_quantity" | "total_mass":
            return scales.physical_quantity(values)
        case _:
            raise ValueError(f"Unknown reducer '{reducer}'")


def physical_result(result: IResult, scales: Scales) -> tuple[np.ndarray, np.ndarray]:
    """All frames and capture times of a dimensionless solve in physical units."""
    values, times = result.all()
    return physical_values(values, result.metadata.reducer, scales), scales.physical_time(times)
