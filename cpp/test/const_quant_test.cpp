//
// Created by arnas on 4/25/2026.
//

#include <catch2/catch_test_macros.hpp>

#include "ADISolver.h"
#include "Brakes/FixedStepBrake.h"
#include "Captures/QuantityCapture.h"
#include "CheckerboardInitialCondition.h"
#include "FixedTimeStep.h"

TEST_CASE("Constant reagent quantity when reaction is off", "[solver]") {
  using TestSolver =
      yag_model::ADISolver<yag_model::FixedTimeStep, yag_model::FixedStepBrake,
                           yag_model::QuantityCapture>;

  yag_model::Discretization disc(1.0, 1.0, 40, 40);

  yag_model::ModelParameters params({1.0, 1.0, 1.0, 1.0, 1.0},
                                    // Nothing reacts, only diffuses
                                    {5000.0, 5000.0, 5000.0});

  yag_model::FixedTimeStep const timeStepPolicy(0.0001);

  size_t const totalSteps = 100;
  yag_model::FixedStepBrake const brakePolicy(totalSteps);
  yag_model::QuantityCapture capturePolicy(totalSteps, 1, disc);

  auto ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 1.0);

  TestSolver solver(disc, std::move(params), std::move(timeStepPolicy),
                    std::move(brakePolicy), capturePolicy);

  solver.solve(ic);

  for (size_t i = 0; i < ic.c.size(); ++i) {
    double const q_initial = quantity(ic.c[i], disc);

    for (size_t t = 0; t < capturePolicy.t_history.size(); ++t) {
      double const qt = capturePolicy.q_history[i][t];
      REQUIRE(std::abs(qt - q_initial) < 1e-9);
    }
  }
}