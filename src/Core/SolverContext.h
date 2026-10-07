#pragma once

#include "Config/Discretization.h"
#include "Core/SolutionState.h"

namespace yag_model {

// Run-wide information handed to every solver component before the first step.
// References are only valid for the duration of begin().
struct SolverContext {
  Discretization const& disc;
  SolutionState const& initial;
};

}  // namespace yag_model
