#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/ReagentQuantityThresholdBrake.h"
#include "Capture/Triggers/LastFrameTrigger.h"
#include "Core/Channel.h"
#include "Core/Constants.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"
#include "TimeStep/GeometricTimeStep.h"

TEST_CASE("Geometric time step grows and resets on begin", "[timestep]") {
  yag_model::Discretization const disc(1.0, 1.0, 4, 4);
  yag_model::SolutionState const ic(4, 4);
  yag_model::SolverState const state(4, 4);
  yag_model::SolverContext const ctx{disc, ic};

  yag_model::GeometricTimeStep step(1.0, 2.0);

  step.begin(ctx);
  REQUIRE(step.advance(state) == 1.0);
  REQUIRE(step.advance(state) == 2.0);
  REQUIRE(step.advance(state) == 4.0);

  step.begin(ctx);
  REQUIRE(step.advance(state) == 1.0);
}

TEST_CASE("Reagent threshold brake initializes from initial condition", "[brake]") {
  yag_model::Discretization const disc(1.0, 1.0, 4, 4);
  auto const ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 2.0);
  yag_model::SolverContext const ctx{disc, ic};

  yag_model::ReagentQuantityThresholdBrake brake(0.5, 1);
  brake.begin(ctx);

  REQUIRE(brake.initial_reagent_quantity == Catch::Approx(reagentQuantity(ic, disc)));

  yag_model::SolverState state(4, 4);
  state.solution = ic;
  REQUIRE_FALSE(brake.shouldBrake(state));

  state.solution.c[0] *= 0.25;
  state.solution.c[1] *= 0.25;
  REQUIRE(brake.shouldBrake(state));
}

TEST_CASE("Channel mask maps to channel indices", "[channel]") {
  REQUIRE(yag_model::channelIndices(yag_model::ALL) == std::vector<size_t>{0, 1, 2, 3, 4});
  REQUIRE(yag_model::channelIndices(yag_model::YAM | yag_model::YAG) == std::vector<size_t>{2, 4});
  REQUIRE(yag_model::channelIndices(0).empty());
}

TEST_CASE("Last frame trigger captures exactly the final state", "[solver]") {
  yag_model::SolverConfig config;
  config.discretization = yag_model::Discretization(1.0, 1.0, 8, 8);
  config.step = std::make_shared<yag_model::FixedTimeStep>(0.5);
  config.brake = std::make_shared<yag_model::FixedStepBrake>(10);
  config.capture.trigger = std::make_shared<yag_model::LastFrameTrigger>();

  yag_model::ModelParameters const params({0.01, 0.01, 0.01, 0.01, 0.01}, {0.0, 0.0, 0.0});

  auto const ic = yag_model::buildCheckerboardInitialCondition(config.discretization, 1.0, 1.0);
  auto const result = yag_model::solve(config, ic, params);

  REQUIRE(result->size() == 1);
  REQUIRE(result->all().times()(0) == Catch::Approx(5.0));
}

TEST_CASE("Geometric time step drives solver time", "[solver]") {
  yag_model::SolverConfig config;
  config.discretization = yag_model::Discretization(1.0, 1.0, 8, 8);
  config.step = std::make_shared<yag_model::GeometricTimeStep>(0.1, 2.0);
  config.brake = std::make_shared<yag_model::FixedStepBrake>(4);
  config.capture.trigger = std::make_shared<yag_model::LastFrameTrigger>();

  yag_model::ModelParameters const params({0.01, 0.01, 0.01, 0.01, 0.01}, {0.0, 0.0, 0.0});

  auto const ic = yag_model::buildCheckerboardInitialCondition(config.discretization, 1.0, 1.0);

  // Solving twice checks that begin() resets the step
  for (int run = 0; run < 2; ++run) {
    auto const result = yag_model::solve(config, ic, params);

    // 0.1 + 0.2 + 0.4 + 0.8
    REQUIRE(result->all().times()(0) == Catch::Approx(1.5));
  }
}

TEST_CASE("Molar masses match YAG synthesis species", "[constants]") {
  REQUIRE(yag_model::Constants::M(0) == Catch::Approx(101.961));
  REQUIRE(yag_model::Constants::M(4) == Catch::Approx(593.616));
}
