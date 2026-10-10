#include "ClampedGeometricTimeStep.h"

namespace yag_model {
ClampedGeometricTimeStep::ClampedGeometricTimeStep(
    double dt_0, double r, double upper_bound, size_t stride
)
    : dt_0(dt_0), r(r), upper_bound(upper_bound), stride(stride) {}

void ClampedGeometricTimeStep::begin(SolverContext const& ctx) {
  dt = dt_0;
}

double ClampedGeometricTimeStep::advance(SolverState const& state) {
  if (state.step % stride != 0) {
    return dt;
  }
  dt = std::min(dt * r, upper_bound);
  return dt;
}
}  // namespace yag_model