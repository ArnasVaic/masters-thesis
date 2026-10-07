#include <catch2/catch_test_macros.hpp>

#include "../src/Captures/QuantityCapture.h"
#include "Brakes/FixedTimeBrake.h"
#include "Capture/Triggers/LastFrameTrigger.h"
#include "Capture/Triggers/StrideTrigger.h"
#include "Core/Constants.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

TEST_CASE("Last capture trigger test", "[solver]") {
  yag_model::Discretization const disc(2.1544, 2.1544, 40, 40);
  auto s = yag_model::Constants::S;
  yag_model::ModelParameters const params(
      {1e-5, 1e-5, 1e-5, 1e-5, 1e-5},
      // Nothing reacts, only diffuses
      {100.0, 50.0, 20.0}
  );

  yag_model::FixedTimeStep step(0.0001);
  yag_model::FixedTimeBrake brake(1.0);
  yag_model::LastFrameTrigger captureTrigger;
  yag_model::QuantityCapture capture(1, disc);

  auto ic = yag_model::buildCheckerboardInitialCondition(disc, 3e-6, 5e-6);

  yag_model::solve(s, disc, params, step, brake, captureTrigger, capture, ic);

  // Accumulated dt may fall just short of 1.0, so the brake can fire one step later
  REQUIRE(capture.size == 1);
  REQUIRE(capture.t_history(0) >= 1.0);
  REQUIRE(capture.t_history(0) < 1.0 + step.dt);
}
