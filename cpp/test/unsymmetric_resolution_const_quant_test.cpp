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

TEST_CASE("Const. reagent quant., reaction off, resolution w!=h", "[solver]") {
    using TestSolver = yag_model::ADISolver<yag_model::FixedTimeStep,
        yag_model::FixedStepBrake,
        yag_model::QuantityCapture>;

    yag_model::Discretization disc(1.0, 1.0, 40, 20);

    yag_model::ModelParameters params({0.01, 0.01, 0.01, 0.01, 0.01},
        // Nothing reacts, only diffuses
        {0.0, 0.0, 0.0});

    yag_model::FixedTimeStep const timeStepPolicy(0.0001);

    size_t const totalSteps = 1000;
    yag_model::FixedStepBrake const brakePolicy(totalSteps);
    yag_model::QuantityCapture capturePolicy(totalSteps, 1, disc);

    auto ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 1.0);

    TestSolver solver(
        disc, std::move(params), timeStepPolicy, brakePolicy, capturePolicy);

    solver.solve(ic);

    for (size_t i = 0; i < ic.c.size(); ++i) {
        double const q_initial = quantity(ic.c[i], disc);

        for (size_t t = 0; t < capturePolicy.t_history.size(); ++t) {
            double const qt = capturePolicy.q_history[i][t];
            REQUIRE(std::abs(qt - q_initial) < 1e-9);
        }
    }
}