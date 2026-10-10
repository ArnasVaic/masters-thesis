# Nondimensionalization of model parameters
#
# The solver behaves best with values of order one, so physical inputs are
# rescaled by characteristic length L0, concentration C0 and diffusion D_ref.

from dataclasses import dataclass

from yag_model import ModelParameters


@dataclass(frozen=True)
class Scales:
    L0: float
    C0: float
    D_ref: float

    @property
    def T0(self) -> float:
        """Characteristic time L0^2 / D_ref."""
        return self.L0 ** 2 / self.D_ref


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
