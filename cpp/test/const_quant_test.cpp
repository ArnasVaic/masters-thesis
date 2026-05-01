//
// Created by arnas on 4/25/2026.
//

#include <catch2/catch_test_macros.hpp>

#include "Brakes/FixedStepBrake.h"
#include "CaptureTrigger/QuantityCapture.h"
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
    auto step = std::make_shared<yag_model::FixedTimeStep>(0.0001);
    auto brake = std::make_shared<yag_model::FixedStepBrake>(totalSteps);
    yag_model::QuantityCapture capturePolicy(totalSteps, 1, disc);

    auto ic = yag_model::buildCheckerboardInitialCondition(disc, 5.0, 5.0);

    yag_model::ADISolver<yag_model::QuantityCapture> solver(
        disc, std::move(params), step, brake, capturePolicy);

    solver.solve(ic);

    for (size_t i = 0; i < ic.c.size(); ++i) {
        double const q_initial = quantity(ic.c[i], disc);

        for (size_t t = 0; t < capturePolicy.t_history.size(); ++t) {
            double const qt = capturePolicy.q_history[i][t];
            REQUIRE(std::abs(qt - q_initial) < 1e-9);
        }
    }
}