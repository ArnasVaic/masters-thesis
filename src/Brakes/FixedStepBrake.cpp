#include "FixedStepBrake.h"

namespace yag_model {

FixedStepBrake::FixedStepBrake(size_t const last_step) : last_step(last_step) {}

bool FixedStepBrake::shouldBrake(SolverState const& state) const {
  return state.step >= last_step;
}

}  // namespace yag_model
