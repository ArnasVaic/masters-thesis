#pragma once

#include "Brakes/IBrake.h"
#include "Capture/Triggers/ITrigger.h"
#include "Captures/ICapture.h"
#include "Config/Discretization.h"
#include "Config/ModelParameters.h"
#include "Core/SolutionState.h"
#include "TimeStep/ITimeStep.h"

namespace yag_model {
void solve(
    xt::xarray<double> const& S,
    Discretization const& disc,
    ModelParameters const& params,
    ITimeStep& timeStep,
    IBrake& brake,
    ITrigger& trigger,
    ICapture& capture,
    SolutionState const& ic
);
}  // namespace yag_model
