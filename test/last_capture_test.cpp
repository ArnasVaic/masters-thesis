#include <catch2/catch_test_macros.hpp>

#include "Brakes/FixedTimeBrake.h"
#include "Capture/Reducers/MolarQuantityReducer.h"
#include "Capture/Triggers/LastFrameTrigger.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

TEST_CASE("Last capture trigger test", "[solver]") {
  double constexpr dt = 0.0001;

  yag_model::SolverConfig config;
  config.discretization = yag_model::Discretization(2.1544, 2.1544, 40, 40);
  config.step = std::make_shared<yag_model::FixedTimeStep>(dt);
  config.brake = std::make_shared<yag_model::FixedTimeBrake>(1.0);
  config.capture.trigger = std::make_shared<yag_model::LastFrameTrigger>();
  config.capture.reducer = std::make_shared<yag_model::MolarQuantityReducer>();

  yag_model::ModelParameters const params({1e-5, 1e-5, 1e-5, 1e-5, 1e-5}, {100.0, 50.0, 20.0});

  auto ic = yag_model::buildCheckerboardInitialCondition(config.discretization, 3e-6, 5e-6);
  auto const result = yag_model::solve(config, ic, params);
  auto const t = result->all().times();

  // Accumulated dt may fall just short of 1.0, so the brake can fire one step later
  REQUIRE(result->size() == 1);
  REQUIRE(t(0) >= 1.0);
  REQUIRE(t(0) < 1.0 + dt);
}
