#pragma once

#include <memory>

#include "Config/ModelParameters.h"
#include "Config/SolverConfig.h"
#include "Core/SolutionState.h"
#include "Result/IResult.h"

namespace yag_model {
std::shared_ptr<IResult> solve(
    SolverConfig const& config, SolutionState const& ic, ModelParameters const& params
);
}  // namespace yag_model
