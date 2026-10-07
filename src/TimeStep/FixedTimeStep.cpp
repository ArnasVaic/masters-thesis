#include "FixedTimeStep.h"

namespace yag_model {

FixedTimeStep::FixedTimeStep(double const dt) : dt(dt) {}

double FixedTimeStep::advance(SolverState const& state) {
  return dt;
}

}  // namespace yag_model
