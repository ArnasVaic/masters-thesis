#include <iostream>
#include <xtensor.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/TimeBrake.h"
#include "CaptureTrigger/LastFrameCaptureTrigger.h"
#include "Captures/QuantityCapture.h"
#include "Config/Discretization.h"
#include "Config/ModelParameters.h"
#include "Core/SolutionState.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

int main() {
    yag_model::Discretization const disc(2.1544, 2.1544, 40, 40);

    yag_model::ModelParameters const params({1e-5, 1e-5, 1e-5, 1e-5, 1e-5},
        // Nothing reacts, only diffuses
        {100.0, 50.0, 20.0});

    yag_model::FixedTimeStep step(0.0001);
    auto brake = std::make_shared<yag_model::TimeBrake>(0.001);
    yag_model::LastFrameCaptureTrigger captureTrigger(brake);
    yag_model::QuantityCapture capture(10, disc);

    auto ic = yag_model::buildCheckerboardInitialCondition(disc, 3e-6, 5e-6);

    yag_model::solve(disc, params, step, *brake, captureTrigger, capture, ic);
}
