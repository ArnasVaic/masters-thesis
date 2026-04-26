//
// Created by arnas on 4/26/2026.
//

#include "FixedStepBrake.h"

namespace yag_model {

FixedStepBrake::FixedStepBrake(size_t const steps) : steps(steps) {}

bool FixedStepBrake::shouldBrake(SolverState const& state) const {
  return state.step == steps;
}

}  // namespace yag_model
