#include <catch2/catch_test_macros.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Capture/Reducers/MolarQuantityReducer.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

TEST_CASE("Const. reagent quant., reaction off, resolution w!=h", "[solver]") {
  yag_model::SolverConfig config;
  config.discretization = yag_model::Discretization(1.0, 1.0, 40, 20);
  config.step = std::make_shared<yag_model::FixedTimeStep>(0.0001);
  config.brake = std::make_shared<yag_model::FixedStepBrake>(1000);
  config.capture.reducer = std::make_shared<yag_model::MolarQuantityReducer>();

  yag_model::ModelParameters params(
      {0.01, 0.01, 0.01, 0.01, 0.01},
      // Nothing reacts, only diffuses
      {0.0, 0.0, 0.0}
  );

  auto const& disc = config.discretization;
  auto ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 1.0);
  auto const result = yag_model::solve(config, ic, params);
  auto const q = result->all().values();

  for (size_t i = 0; i < ic.c.size(); ++i) {
    double const q_initial = quantity(ic.c[i], disc);

    for (size_t t = 0; t < result->size(); ++t) {
      REQUIRE(std::abs(q(t, i) - q_initial) < 1e-9);
    }
  }
}
