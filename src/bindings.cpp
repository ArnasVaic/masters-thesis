#define FORCE_IMPORT_ARRAY
#define PY_ARRAY_UNIQUE_SYMBOL yag_model_array_api
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include <xtensor-python/pyarray.hpp>
#include <xtensor-python/pytensor.hpp>
#include <xtensor/containers/xarray.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/FixedTimeBrake.h"
#include "Brakes/IBrake.h"
#include "Brakes/ReagentQuantityThresholdBrake.h"
#include "Capture/Reducers/ConcentrationFieldReducer.h"
#include "Capture/Reducers/DensityFieldReducer.h"
#include "Capture/Reducers/MolarQuantityReducer.h"
#include "Capture/Reducers/TotalMassReducer.h"
#include "Capture/Sinks/HDF5Sink.h"
#include "Capture/Sinks/InMemorySink.h"
#include "Capture/Triggers/LastFrameTrigger.h"
#include "Capture/Triggers/StrideTrigger.h"
#include "Config/CaptureConfig.h"
#include "Config/ModelParameters.h"
#include "Config/SolverConfig.h"
#include "Core/Channel.h"
#include "Core/Constants.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Result/HDF5Result.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"
#include "TimeStep/GeometricTimeStep.h"
#include "TimeStep/ITimeStep.h"

namespace py = pybind11;

PYBIND11_MODULE(yag_model, m) {
  m.doc() = "YAG model bindings";

  xt::import_numpy();

  py::class_<yag_model::Discretization>(m, "Discretization")
      .def(
          py::init<double, double, size_t, size_t>(),
          py::arg("physical_space_w"),
          py::arg("physical_space_h"),
          py::arg("mesh_res_x"),
          py::arg("mesh_res_y")
      )
      .def_readonly("physical_space_w", &yag_model::Discretization::physical_space_w)
      .def_readonly("physical_space_h", &yag_model::Discretization::physical_space_h)
      .def_readonly("mesh_res_x", &yag_model::Discretization::mesh_res_x)
      .def_readonly("mesh_res_y", &yag_model::Discretization::mesh_res_y)
      .def_readonly("dx", &yag_model::Discretization::dx)
      .def_readonly("dy", &yag_model::Discretization::dy);

  py::class_<yag_model::ModelParameters>(m, "ModelParameters")
      .def(
          py::init<xt::pyarray<double> const&, xt::pyarray<double> const&>(),
          py::arg("D"),
          py::arg("K")
      )
      .def_property(
          "D",
          [](yag_model::ModelParameters& self) { return xt::pyarray<double>(self.D); },
          [](yag_model::ModelParameters& self, xt::pyarray<double> v) { self.D = v; }
      )

      .def_property(
          "K",
          [](yag_model::ModelParameters& self) { return xt::pyarray<double>(self.K); },
          [](yag_model::ModelParameters& self, xt::pyarray<double> v) { self.K = v; }
      );

  py::class_<yag_model::SolutionState>(m, "SolutionState")
      .def(py::init<size_t, size_t>(), py::arg("rows"), py::arg("cols"))
      .def("__getitem__", [](yag_model::SolutionState& self, size_t i) { return self.c[i]; })
      .def("__setitem__", [](yag_model::SolutionState& self, size_t i, xt::pyarray<double> v) {
        self.c[i] = v;
      });

  py::class_<yag_model::SolverState>(m, "SolverState")
      .def(py::init<size_t, size_t>(), py::arg("rows"), py::arg("cols"))
      .def_readwrite("solution", &yag_model::SolverState::solution)
      .def_readwrite("time", &yag_model::SolverState::time)
      .def_readwrite("step", &yag_model::SolverState::step)
      .def_readwrite("is_final", &yag_model::SolverState::is_final);

  py::enum_<yag_model::Channel>(m, "Channel", py::arithmetic())
      .value("AL2O3", yag_model::AL2O3)
      .value("Y2O3", yag_model::Y2O3)
      .value("YAM", yag_model::YAM)
      .value("YAP", yag_model::YAP)
      .value("YAG", yag_model::YAG)
      .value("ALL", yag_model::ALL)
      .export_values();

  m.attr("MOLAR_MASSES") = xt::pyarray<double>(yag_model::Constants::M);
  m.attr("DEFAULT_STOICHIOMETRY") = xt::pyarray<double>(yag_model::Constants::S);

  py::class_<yag_model::ITimeStep, std::shared_ptr<yag_model::ITimeStep>>(m, "ITimeStep")
      .def("advance", &yag_model::ITimeStep::advance, py::arg("state"));

  py::class_<
      yag_model::FixedTimeStep,
      yag_model::ITimeStep,
      std::shared_ptr<yag_model::FixedTimeStep>>(m, "FixedTimeStep")
      .def(py::init<double>(), py::arg("dt"))
      .def_readwrite("dt", &yag_model::FixedTimeStep::dt);

  py::class_<
      yag_model::GeometricTimeStep,
      yag_model::ITimeStep,
      std::shared_ptr<yag_model::GeometricTimeStep>>(m, "GeometricTimeStep")
      .def(py::init<double, double>(), py::arg("dt_0"), py::arg("r"))
      .def_readwrite("dt_0", &yag_model::GeometricTimeStep::dt_0)
      .def_readwrite("r", &yag_model::GeometricTimeStep::r);

  py::class_<yag_model::IBrake, std::shared_ptr<yag_model::IBrake>>(m, "IBrake");

  py::class_<
      yag_model::FixedStepBrake,
      yag_model::IBrake,
      std::shared_ptr<yag_model::FixedStepBrake>>(m, "FixedStepBrake")
      .def(py::init<size_t>(), py::arg("last_step"))
      .def_readwrite("last_step", &yag_model::FixedStepBrake::last_step);

  py::class_<
      yag_model::FixedTimeBrake,
      yag_model::IBrake,
      std::shared_ptr<yag_model::FixedTimeBrake>>(m, "FixedTimeBrake")
      .def(py::init<double>(), py::arg("final_time"))
      .def_readwrite("final_time", &yag_model::FixedTimeBrake::final_time);

  py::class_<
      yag_model::ReagentQuantityThresholdBrake,
      yag_model::IBrake,
      std::shared_ptr<yag_model::ReagentQuantityThresholdBrake>>(m, "ReagentQuantityThresholdBrake")
      .def(py::init<double, size_t>(), py::arg("threshold"), py::arg("stride"))
      .def_readwrite("threshold", &yag_model::ReagentQuantityThresholdBrake::threshold)
      .def_readwrite("stride", &yag_model::ReagentQuantityThresholdBrake::stride)
      .def_readonly(
          "initial_reagent_quantity",
          &yag_model::ReagentQuantityThresholdBrake::initial_reagent_quantity
      );

  py::class_<yag_model::ITrigger, std::shared_ptr<yag_model::ITrigger>>(m, "ITrigger")
      .def("shouldCapture", &yag_model::ITrigger::shouldCapture, py::arg("state"));

  py::class_<
      yag_model::StrideTrigger,
      yag_model::ITrigger,
      std::shared_ptr<yag_model::StrideTrigger>>(m, "StrideTrigger")
      .def(py::init<size_t>(), py::arg("stride"))
      .def_readwrite("stride", &yag_model::StrideTrigger::stride);

  py::class_<
      yag_model::LastFrameTrigger,
      yag_model::ITrigger,
      std::shared_ptr<yag_model::LastFrameTrigger>>(m, "LastFrameTrigger")
      .def(py::init<>());

  py::class_<yag_model::IReducer, std::shared_ptr<yag_model::IReducer>>(m, "IReducer")
      .def_property_readonly("name", &yag_model::IReducer::name);

  py::class_<
      yag_model::ConcentrationFieldReducer,
      yag_model::IReducer,
      std::shared_ptr<yag_model::ConcentrationFieldReducer>>(m, "ConcentrationFieldReducer")
      .def(py::init<>());

  py::class_<
      yag_model::DensityFieldReducer,
      yag_model::IReducer,
      std::shared_ptr<yag_model::DensityFieldReducer>>(m, "DensityFieldReducer")
      .def(py::init<>());

  py::class_<
      yag_model::MolarQuantityReducer,
      yag_model::IReducer,
      std::shared_ptr<yag_model::MolarQuantityReducer>>(m, "MolarQuantityReducer")
      .def(py::init<>());

  py::class_<
      yag_model::TotalMassReducer,
      yag_model::IReducer,
      std::shared_ptr<yag_model::TotalMassReducer>>(m, "TotalMassReducer")
      .def(py::init<>());

  py::class_<yag_model::ISink, std::shared_ptr<yag_model::ISink>>(m, "ISink");

  py::class_<yag_model::InMemorySink, yag_model::ISink, std::shared_ptr<yag_model::InMemorySink>>(
      m, "InMemorySink"
  )
      .def(py::init<std::optional<size_t>>(), py::arg("capacity") = py::none())
      .def_readwrite("capacity", &yag_model::InMemorySink::capacity);

  py::class_<yag_model::HDF5Sink, yag_model::ISink, std::shared_ptr<yag_model::HDF5Sink>>(
      m, "HDF5Sink"
  )
      .def(py::init<std::string>(), py::arg("path"))
      .def_readwrite("path", &yag_model::HDF5Sink::path);

  py::class_<yag_model::ResultMetadata>(m, "ResultMetadata")
      .def_readonly("frame_shape", &yag_model::ResultMetadata::frame_shape)
      .def_readonly("channels", &yag_model::ResultMetadata::channels)
      .def_readonly("reducer", &yag_model::ResultMetadata::reducer)
      .def_readonly("discretization", &yag_model::ResultMetadata::discretization);

  py::class_<yag_model::IResult, std::shared_ptr<yag_model::IResult>>(m, "IResult")
      .def("__len__", &yag_model::IResult::size)
      .def_property_readonly("metadata", &yag_model::IResult::metadata);

  py::class_<yag_model::HDF5Result, yag_model::IResult, std::shared_ptr<yag_model::HDF5Result>>(
      m, "HDF5Result"
  )
      .def(py::init<std::string const&>(), py::arg("path"));

  py::class_<yag_model::CaptureConfig>(m, "CaptureConfig")
      .def(py::init<>())
      .def_readwrite("channels", &yag_model::CaptureConfig::channels)
      .def_readwrite("reducer", &yag_model::CaptureConfig::reducer)
      .def_readwrite("trigger", &yag_model::CaptureConfig::trigger)
      .def_readwrite("sink", &yag_model::CaptureConfig::sink);

  py::class_<yag_model::SolverConfig>(m, "SolverConfig")
      .def(py::init<>())
      .def_readwrite("discretization", &yag_model::SolverConfig::discretization)
      .def_readwrite("step", &yag_model::SolverConfig::step)
      .def_readwrite("brake", &yag_model::SolverConfig::brake)
      .def_readwrite("capture", &yag_model::SolverConfig::capture)
      .def_property(
          "stoichiometry",
          [](yag_model::SolverConfig& self) { return xt::pyarray<double>(self.stoichiometry); },
          [](yag_model::SolverConfig& self, xt::pyarray<double> v) { self.stoichiometry = v; }
      );

  m.def(
      "solve",
      [](yag_model::SolverConfig const& config,
         yag_model::SolutionState const& ic,
         yag_model::ModelParameters const& params) {
        // Release the Python GIL
        py::gil_scoped_release release;

        return yag_model::solve(config, ic, params);
      },
      py::arg("config"),
      py::arg("ic"),
      py::arg("params")
  );

  m.def(
      "build_checkerboard_initial_condition",
      &yag_model::buildCheckerboardInitialCondition,
      py::arg("disc"),
      py::arg("c1_initial_concentration"),
      py::arg("c2_initial_concentration"),
      "Creates a checkerboard initial condition"
  );

  m.def(
      "quantity",
      &yag_model::quantity,
      py::arg("c"),
      py::arg("disc"),
      "Compute total quantity from concentration field"
  );

  m.def(
      "reagent_quantity",
      &yag_model::reagentQuantity,
      py::arg("state"),
      py::arg("disc"),
      "Compute reagent quantity from solution state"
  );
}
