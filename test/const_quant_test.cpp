//
// Created by arnas on 4/25/2026.
//

#include <catch2/catch_test_macros.hpp>

#include "../src/Captures/QuantityCapture.h"
#include "Brakes/FixedStepBrake.h"
#include "CaptureTrigger/StrideCaptureTrigger.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

TEST_CASE("Constant reagent quantity when reaction is off", "[solver]") {
    yag_model::Discretization disc(1.0, 1.0, 40, 40);

    yag_model::ModelParameters params({0.01, 0.01, 0.01, 0.01, 0.01},
        // Nothing reacts, only diffuses
        {0.0, 0.0, 0.0});

    size_t const totalSteps = 100;
    yag_model::FixedTimeStep step(0.0001);
    yag_model::FixedStepBrake brake(totalSteps);
    yag_model::StrideCaptureTrigger captureTrigger(1);
    yag_model::QuantityCapture capture(totalSteps, disc);

    auto ic = yag_model::buildCheckerboardInitialCondition(disc, 5.0, 5.0);
    yag_model::solve(disc, params, step, brake, captureTrigger, capture, ic);

    for (size_t i = 0; i < ic.c.size(); ++i) {
        double const q_initial = quantity(ic.c[i], disc);

        for (size_t t = 0; t < capture.t_history.size(); ++t) {
            double const qt = capture.q_history(i, t);
            REQUIRE(std::abs(qt - q_initial) < 1e-9);
        }
    }
}