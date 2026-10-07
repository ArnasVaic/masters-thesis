#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>
#include <xtensor/views/xview.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Capture/Reducers/ConcentrationFieldReducer.h"
#include "Capture/Reducers/DensityFieldReducer.h"
#include "Capture/Reducers/MolarQuantityReducer.h"
#include "Capture/Reducers/TotalMassReducer.h"
#include "Capture/Sinks/InMemorySink.h"
#include "Core/Channel.h"
#include "Core/Constants.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

namespace {

// Non-square so (H, W) vs (W, H) mix-ups show up
yag_model::Discretization const disc(1.0, 2.0, 6, 4);

yag_model::SolutionState distinctChannels() {
  yag_model::SolutionState s(disc.mesh_res_y, disc.mesh_res_x);
  for (size_t i = 0; i < s.c.size(); ++i) {
    s.c[i].fill(static_cast<double>(i + 1));
  }
  return s;
}

yag_model::ResultMetadata scalarMetadata() {
  return {{2}, yag_model::ALL, "test", disc};
}

}  // namespace

TEST_CASE("Field reducers select channels with (C, H, W) frames", "[reducer]") {
  auto const s = distinctChannels();
  auto const channels = yag_model::channelIndices(yag_model::Y2O3 | yag_model::YAG);

  auto const c = yag_model::ConcentrationFieldReducer().reduce(s, channels, disc);
  REQUIRE(c.shape() == std::vector<size_t>{2, 4, 6});
  REQUIRE(xt::all(xt::equal(xt::view(c, 0), 2.0)));
  REQUIRE(xt::all(xt::equal(xt::view(c, 1), 5.0)));

  auto const rho = yag_model::DensityFieldReducer().reduce(s, channels, disc);
  REQUIRE(rho.shape() == std::vector<size_t>{2, 4, 6});
  REQUIRE(rho(1, 3, 5) == Catch::Approx(5.0 * yag_model::Constants::M(4)));
}

TEST_CASE("Scalar reducers produce (C,) frames", "[reducer]") {
  auto const s = distinctChannels();
  auto const channels = yag_model::channelIndices(yag_model::AL2O3 | yag_model::YAM);

  auto const q = yag_model::MolarQuantityReducer().reduce(s, channels, disc);
  REQUIRE(q.shape() == std::vector<size_t>{2});
  REQUIRE(q(1) == Catch::Approx(yag_model::quantity(s.c[2], disc)));

  auto const m = yag_model::TotalMassReducer().reduce(s, channels, disc);
  REQUIRE(m(1) == Catch::Approx(yag_model::Constants::M(2) * yag_model::quantity(s.c[2], disc)));
}

TEST_CASE("In-memory sink with capacity keeps the first frames", "[sink]") {
  yag_model::InMemorySink sink(3);
  sink.begin(scalarMetadata());

  for (int i = 0; i < 5; ++i) {
    sink.write(xt::xarray<double>{1.0 * i, -1.0 * i}, 0.5 * i);
  }

  auto const result = sink.finish();
  REQUIRE(result->size() == 3);

  auto const all = result->all();
  REQUIRE(all.shape() == std::vector<size_t>{3, 2});
  REQUIRE(all.values()(2, 1) == -2.0);
  REQUIRE(all.times()(2) == 1.0);
}

TEST_CASE("In-memory sink reset leaves previous result intact", "[sink]") {
  yag_model::InMemorySink sink;

  sink.begin(scalarMetadata());
  sink.write(xt::xarray<double>{1.0, 2.0}, 0.0);
  auto const first = sink.finish();

  sink.begin(scalarMetadata());
  for (int i = 0; i < 4; ++i) {
    sink.write(xt::xarray<double>{3.0, 4.0}, 1.0);
  }
  auto const second = sink.finish();

  REQUIRE(first->size() == 1);
  REQUIRE(first->all().values()(0, 1) == 2.0);
  REQUIRE(second->size() == 4);
}

TEST_CASE("In-memory sink rejects frames of the wrong size", "[sink]") {
  yag_model::InMemorySink sink;
  sink.begin(scalarMetadata());
  REQUIRE_THROWS_AS(sink.write(xt::xarray<double>{1.0, 2.0, 3.0}, 0.0), std::invalid_argument);
}

TEST_CASE("Batches cover the result in order", "[result]") {
  yag_model::InMemorySink sink;
  sink.begin(scalarMetadata());
  for (int i = 0; i < 10; ++i) {
    sink.write(xt::xarray<double>{1.0 * i, 0.0}, 1.0 * i);
  }
  auto const result = sink.finish();

  auto const range = result->batches(4);
  REQUIRE(range.size() == 3);

  std::vector<size_t> sizes;
  double expected_t = 0.0;
  for (auto const& batch : range) {
    sizes.push_back(batch.size());
    for (size_t i = 0; i < batch.size(); ++i) {
      REQUIRE(batch.times()(i) == expected_t);
      REQUIRE(batch.values()(i, 0) == expected_t);
      expected_t += 1.0;
    }
  }

  REQUIRE(sizes == std::vector<size_t>{4, 4, 2});
  REQUIRE_THROWS_AS(result->batches(0), std::invalid_argument);
  REQUIRE_THROWS_AS(result->read(5, 11), std::out_of_range);
}

TEST_CASE("Batch keeps storage alive after result is gone", "[result]") {
  yag_model::InMemorySink sink;
  sink.begin(scalarMetadata());
  sink.write(xt::xarray<double>{7.0, 8.0}, 1.0);

  auto batch = sink.finish()->all();
  REQUIRE(batch.values()(0, 1) == 8.0);
}

TEST_CASE("Solve captures selected channels with metadata", "[solver]") {
  yag_model::SolverConfig config;
  config.discretization = disc;
  config.step = std::make_shared<yag_model::FixedTimeStep>(0.001);
  config.brake = std::make_shared<yag_model::FixedStepBrake>(9);
  config.capture.channels = yag_model::YAM | yag_model::YAG;
  config.capture.trigger = std::make_shared<yag_model::StrideTrigger>(3);

  yag_model::ModelParameters const params({0.01, 0.01, 0.01, 0.01, 0.01}, {1.0, 1.0, 1.0});
  auto const ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 1.0);

  auto const result = yag_model::solve(config, ic, params);
  auto const& meta = result->metadata();

  // Steps 0, 3, 6, 9
  REQUIRE(result->size() == 4);
  REQUIRE(meta.frame_shape == std::vector<size_t>{2, 4, 6});
  REQUIRE(meta.channels == (yag_model::YAM | yag_model::YAG));
  REQUIRE(meta.reducer == "concentration_field");
  REQUIRE(meta.discretization.mesh_res_x == 6);

  // Reusing the config produces an independent result
  auto const again = yag_model::solve(config, ic, params);
  REQUIRE(again->size() == 4);
  REQUIRE(result->size() == 4);
}

TEST_CASE("Default solver config solves", "[solver]") {
  yag_model::SolverConfig const config;
  yag_model::ModelParameters const params({1e-5, 1e-5, 1e-5, 1e-5, 1e-5}, {0.0, 0.0, 0.0});
  auto const ic = yag_model::buildCheckerboardInitialCondition(config.discretization, 1.0, 1.0);

  auto const result = yag_model::solve(config, ic, params);

  REQUIRE(result->size() == 101);
  REQUIRE(result->metadata().frame_shape == std::vector<size_t>{5, 40, 40});
}

TEST_CASE("Solve rejects invalid configuration", "[solver]") {
  yag_model::SolverConfig config;
  yag_model::ModelParameters const params({0.01, 0.01, 0.01, 0.01, 0.01}, {0.0, 0.0, 0.0});
  auto const ic = yag_model::buildCheckerboardInitialCondition(config.discretization, 1.0, 1.0);

  SECTION("empty channel mask") {
    config.capture.channels = 0;
    REQUIRE_THROWS_AS(yag_model::solve(config, ic, params), std::invalid_argument);
  }

  SECTION("mismatched initial condition") {
    config.discretization = disc;
    REQUIRE_THROWS_AS(yag_model::solve(config, ic, params), std::invalid_argument);
  }
}
