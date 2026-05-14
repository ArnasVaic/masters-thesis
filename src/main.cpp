#include <iostream>
#include <xtensor.hpp>

#include "Brakes/FixedStepBrake.h"
#include "CaptureTrigger/LastFrameCaptureTrigger.h"
#include "Captures/QuantityCapture.h"
#include "Config/Discretization.h"
#include "Config/ModelParameters.h"
#include "Core/SolutionState.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

int main() {
    yag_model::Discretization disc(1.0, 1.0, 40, 20);

    yag_model::ModelParameters params({0.01, 0.01, 0.01, 0.01, 0.01},
        // Nothing reacts, only diffuses
        {0.0, 0.0, 0.0});

    size_t const totalSteps = 1000;
    auto step = std::make_shared<yag_model::FixedTimeStep>(0.0001);
    auto brake = std::make_shared<yag_model::FixedStepBrake>(totalSteps);
    auto captureTrigger =
        std::make_shared<yag_model::LastFrameCaptureTrigger>(brake);
    auto capture = std::make_unique<yag_model::QuantityCapture>(1, disc);

    auto ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 1.0);

    yag_model::ADISolver solver(
        disc, params, step, brake, captureTrigger, std::move(capture));

    auto captured = solver.solve(ic);
}
