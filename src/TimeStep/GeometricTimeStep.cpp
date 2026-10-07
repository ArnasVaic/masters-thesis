#include "GeometricTimeStep.h"

namespace yag_model {

GeometricTimeStep::GeometricTimeStep(double const dt_0, double const r)
    : dt_0(dt_0), r(r), dt(dt_0) {}

void GeometricTimeStep::begin(SolverContext const& ctx) {
  dt = dt_0;
}

double GeometricTimeStep::advance(SolverState const& state) {
  double const current = dt;
  dt *= r;
  return current;
}

}  // namespace yag_model
