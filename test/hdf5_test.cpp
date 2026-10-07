#include <catch2/catch_test_macros.hpp>
#include <filesystem>
#include <highfive/H5File.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Capture/Sinks/HDF5Sink.h"
#include "Core/Channel.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Result/HDF5Result.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

namespace {

// Removes the file when the test ends
struct TempFile {
  std::string path;

  explicit TempFile(std::string const& name)
      : path((std::filesystem::temp_directory_path() / ("yag_model_" + name + ".h5")).string()) {
    std::filesystem::remove(path);
  }

  ~TempFile() { std::filesystem::remove(path); }
};

yag_model::Discretization const disc(1.0, 2.0, 6, 4);

yag_model::ResultMetadata fieldMetadata() {
  return {{2, 4, 6}, yag_model::YAM | yag_model::YAG, "concentration_field", disc};
}

xt::xarray<double> frameFilledWith(double const v) {
  return xt::xarray<double>(std::vector<size_t>{2, 4, 6}, v);
}

}  // namespace

TEST_CASE("HDF5 sink round-trips frames and metadata", "[hdf5]") {
  TempFile const tmp("round_trip");
  yag_model::HDF5Sink sink(tmp.path);

  sink.begin(fieldMetadata());
  for (int i = 0; i < 7; ++i) {
    auto frame = frameFilledWith(i);
    frame(1, 3, 5) = -i;
    sink.write(frame, 0.25 * i);
  }
  auto const result = sink.finish();

  REQUIRE(result->size() == 7);

  auto const& meta = result->metadata();
  REQUIRE(meta.frame_shape == std::vector<size_t>{2, 4, 6});
  REQUIRE(meta.channels == (yag_model::YAM | yag_model::YAG));
  REQUIRE(meta.reducer == "concentration_field");
  REQUIRE(meta.discretization.mesh_res_x == 6);
  REQUIRE(meta.discretization.mesh_res_y == 4);
  REQUIRE(meta.discretization.physical_space_w == 1.0);
  REQUIRE(meta.discretization.physical_space_h == 2.0);

  auto const all = result->all();
  REQUIRE(all.shape() == std::vector<size_t>{7, 2, 4, 6});
  REQUIRE(all.values()(6, 0, 0, 0) == 6.0);
  REQUIRE(all.values()(6, 1, 3, 5) == -6.0);
  REQUIRE(all.times()(6) == 1.5);

  std::vector<size_t> sizes;
  double expected = 0.0;
  for (auto const& batch : result->batches(3)) {
    sizes.push_back(batch.size());
    for (size_t i = 0; i < batch.size(); ++i) {
      REQUIRE(batch.values()(i, 0, 1, 1) == expected);
      expected += 1.0;
    }
  }
  REQUIRE(sizes == std::vector<size_t>{3, 3, 1});
}

TEST_CASE("HDF5 result reopens a finished file", "[hdf5]") {
  TempFile const tmp("reopen");
  yag_model::HDF5Sink sink(tmp.path);

  sink.begin(fieldMetadata());
  sink.write(frameFilledWith(3.0), 1.0);
  sink.finish().reset();

  yag_model::HDF5Result const reopened(tmp.path);
  REQUIRE(reopened.size() == 1);
  REQUIRE(reopened.all().values()(0, 1, 2, 3) == 3.0);
}

TEST_CASE("HDF5 batch outlives its result", "[hdf5]") {
  TempFile const tmp("outlive");
  yag_model::HDF5Sink sink(tmp.path);

  sink.begin(fieldMetadata());
  sink.write(frameFilledWith(2.0), 1.0);

  auto const batch = sink.finish()->all();
  REQUIRE(batch.values()(0, 0, 0, 0) == 2.0);
}

TEST_CASE("HDF5 result of an empty run", "[hdf5]") {
  TempFile const tmp("empty");
  yag_model::HDF5Sink sink(tmp.path);

  sink.begin(fieldMetadata());
  auto const result = sink.finish();

  REQUIRE(result->size() == 0);
  REQUIRE(result->all().shape() == std::vector<size_t>{0, 2, 4, 6});
  REQUIRE(result->batches(10).size() == 0);
}

TEST_CASE("HDF5 result rejects files of other formats", "[hdf5]") {
  TempFile const tmp("foreign");
  {
    HighFive::File file(tmp.path, HighFive::File::Overwrite);
    file.createAttribute("format_version", uint32_t{99});
  }

  REQUIRE_THROWS_AS(yag_model::HDF5Result(tmp.path), std::runtime_error);
}

TEST_CASE("HDF5 sink matches in-memory sink through solve", "[hdf5][solver]") {
  TempFile const tmp("solve");

  yag_model::SolverConfig config;
  config.discretization = disc;
  config.step = std::make_shared<yag_model::FixedTimeStep>(0.001);
  config.brake = std::make_shared<yag_model::FixedStepBrake>(20);
  config.capture.channels = yag_model::AL2O3 | yag_model::YAG;
  config.capture.trigger = std::make_shared<yag_model::StrideTrigger>(5);

  yag_model::ModelParameters const params({0.01, 0.01, 0.01, 0.01, 0.01}, {1.0, 1.0, 1.0});
  auto const ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 1.0);

  auto const in_memory = yag_model::solve(config, ic, params);

  config.capture.sink = std::make_shared<yag_model::HDF5Sink>(tmp.path);
  auto from_file = yag_model::solve(config, ic, params);

  REQUIRE(from_file->size() == in_memory->size());
  REQUIRE(from_file->metadata().frame_shape == in_memory->metadata().frame_shape);
  REQUIRE(from_file->all().values() == in_memory->all().values());
  REQUIRE(from_file->all().times() == in_memory->all().times());

  SECTION("reusing the config overwrites the file once the old result is gone") {
    from_file.reset();
    config.brake = std::make_shared<yag_model::FixedStepBrake>(5);

    auto const rerun = yag_model::solve(config, ic, params);
    REQUIRE(rerun->size() == 2);
  }

  SECTION("overwriting a file still open by a result fails") {
    REQUIRE_THROWS_AS(yag_model::solve(config, ic, params), std::runtime_error);
  }
}

TEST_CASE("HDF5 result reports missing files", "[hdf5]") {
  TempFile const tmp("missing");
  REQUIRE_THROWS_AS(yag_model::HDF5Result(tmp.path), std::runtime_error);
}
