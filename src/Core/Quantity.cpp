#include "Quantity.h"

#include "Constants.h"

namespace yag_model {
double quantity(xt::xarray<double> const& c, Discretization const& disc) {
  return xt::sum(c)() * disc.dx * disc.dy;
}

double reagentQuantity(SolutionState const& state, Discretization const& disc) {
  double const q1 = quantity(state.c[0], disc);
  double const q2 = quantity(state.c[1], disc);
  return q1 + q2;
}

double reagentMass(SolutionState const& state, Discretization const& disc) {
  double const m1 = Constants::M[0] * quantity(state.c[0], disc);
  double const m2 = Constants::M[1] * quantity(state.c[1], disc);
  return m1 + m2;
}
}  // namespace yag_model
