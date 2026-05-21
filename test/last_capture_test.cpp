//
// Created by arnas on 4/25/2026.
//

#include <catch2/catch_test_macros.hpp>

#include "../src/Captures/QuantityCapture.h"
#include "Brakes/FixedStepBrake.h"
#include "Brakes/TimeBrake.h"
#include "CaptureTrigger/LastFrameCaptureTrigger.h"
#include "CaptureTrigger/StrideCaptureTrigger.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

TEST_CASE("Last capture trigger test", "[solver]") {
    yag_model::Discretization const disc(2.1544, 2.1544, 40, 40);

    yag_model::ModelParameters const params({1e-5, 1e-5, 1e-5, 1e-5, 1e-5},
        // Nothing reacts, only diffuses
        {100.0, 50.0, 20.0});

    yag_model::FixedTimeStep step(0.0001);
    auto brake = std::make_shared<yag_model::TimeBrake>(1.0);
    yag_model::LastFrameCaptureTrigger captureTrigger(brake);
    yag_model::QuantityCapture capture(1, disc);

    auto ic = yag_model::buildCheckerboardInitialCondition(disc, 3e-6, 5e-6);

    yag_model::solve(disc, params, step, *brake, captureTrigger, capture, ic);

    REQUIRE(std::abs(capture.t_history(0) - 1.0) < 1e-9);
}