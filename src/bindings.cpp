#define FORCE_IMPORT_ARRAY
#define PY_ARRAY_UNIQUE_SYMBOL yag_model_array_api
#include <pybind11/numpy.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include <xtensor-python/pyarray.hpp>
#include <xtensor/containers/xarray.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/FixedTimeBrake.h"
#include "Brakes/IBrake.h"
#include "Brakes/ReagentMassThresholdBrake.h"
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
#include "Result/InMemoryResult.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"
#include "TimeStep/GeometricTimeStep.h"
#include "TimeStep/ITimeStep.h"

namespace py = pybind11;
namespace ym = yag_model;

namespace {

using Pair = std::pair<double, double>;
using SizePair = std::pair<size_t, size_t>;

// Read-only numpy array over storage owned by a result. The array base holds a
// reference to the owner, so the data outlives the result and the batch.
py::array readOnlyView(
    std::shared_ptr<void const> const& owner, double const* data, std::vector<size_t> const& shape
) {
  auto* const keep_alive = new std::shared_ptr<void const>(owner);
  py::capsule const base(keep_alive, [](void* p) {
    delete static_cast<std::shared_ptr<void const>*>(p);
  });

  py::array view(py::dtype::of<double>(), shape, data, base);
  view.attr("flags").attr("writeable") = false;
  return view;
}

py::array readOnlyCopy(xt::xarray<double> const& constant) {
  py::array array = xt::pyarray<double>(constant);
  array.attr("flags").attr("writeable") = false;
  return array;
}

std::string shapeString(std::vector<size_t> const& shape) {
  std::string s = "(";
  for (size_t i = 0; i < shape.size(); ++i) {
    if (i > 0) {
      s += ", ";
    }
    s += std::to_string(shape[i]);
  }
  return s + (shape.size() == 1 ? ",)" : ")");
}

template <typename T, typename... Args>
std::shared_ptr<T> make(Args... args) {
  return std::make_shared<T>(std::move(args)...);
}

// Binds fn as the class constructor and as a snake_case factory in scope with the same signature.
// A plain alias of the class would hide the parameters from stub-based intellisense.
template <typename Class, typename Fn, typename... Extra>
Class withFactory(
    Class cls, py::module_& scope, char const* factory, Fn const& fn, Extra const&... extra
) {
  cls.def(py::init(fn), extra...);
  scope.def(factory, fn, extra...);
  return cls;
}

}  // namespace

PYBIND11_MODULE(yag_model, m) {
  m.doc() = "YAG synthesis reaction-diffusion model";

  xt::import_numpy();

  // ---------------------------------------------------------------------------
  // Model inputs
  // ---------------------------------------------------------------------------

  withFactory(
      py::class_<ym::Discretization>(m, "Discretization"),
      m,
      "discretization",
      [](SizePair const mesh_resolution, Pair const physical_size) {
        return ym::Discretization(
            physical_size.first, physical_size.second, mesh_resolution.first, mesh_resolution.second
        );
      },
      py::kw_only(),
      py::arg("mesh_resolution") = SizePair{40, 40},
      py::arg("physical_size") = Pair{1.0, 1.0},
      "Uniform mesh. Tuples are (x, y): mesh_resolution=(nx, ny), physical_size=(width, height)"
  )
      .def_property_readonly(
          "mesh_resolution",
          [](ym::Discretization const& d) { return SizePair{d.mesh_res_x, d.mesh_res_y}; }
      )
      .def_property_readonly(
          "physical_size",
          [](ym::Discretization const& d) { return Pair{d.physical_space_w, d.physical_space_h}; }
      )
      .def_readonly("nx", &ym::Discretization::mesh_res_x)
      .def_readonly("ny", &ym::Discretization::mesh_res_y)
      .def_readonly("dx", &ym::Discretization::dx)
      .def_readonly("dy", &ym::Discretization::dy)
      .def_property_readonly(
          "shape",
          [](ym::Discretization const& d) { return SizePair{d.mesh_res_y, d.mesh_res_x}; },
          "Shape (ny, nx) of a single concentration field"
      )
      .def("__repr__", [](ym::Discretization const& d) {
        return py::str("Discretization(mesh_resolution=({}, {}), physical_size=({}, {}))")
            .format(d.mesh_res_x, d.mesh_res_y, d.physical_space_w, d.physical_space_h);
      });

  withFactory(
      py::class_<ym::ModelParameters>(m, "ModelParameters"),
      m,
      "model_params",
      [](xt::pyarray<double> const& D, xt::pyarray<double> const& k) {
        return ym::ModelParameters(D, k);
      },
      py::arg("D"),
      py::arg("k"),
      "Diffusion coefficients D (5,) and reaction rate constants k (3,)"
  )
      .def_property(
          "D",
          [](ym::ModelParameters& self) { return xt::pyarray<double>(self.D); },
          [](ym::ModelParameters& self, xt::pyarray<double> const& v) { self.D = v; }
      )
      .def_property(
          "k",
          [](ym::ModelParameters& self) { return xt::pyarray<double>(self.k); },
          [](ym::ModelParameters& self, xt::pyarray<double> const& v) { self.k = v; }
      )
      .def("__repr__", [](ym::ModelParameters& self) {
        return py::str("ModelParameters(D={}, k={})")
            .format(xt::pyarray<double>(self.D), xt::pyarray<double>(self.k));
      });

  py::class_<ym::SolutionState>(m, "SolutionState")
      .def(py::init<size_t, size_t>(), py::arg("rows"), py::arg("cols"))
      .def(
          py::init([](ym::Discretization const& disc) {
            return ym::SolutionState(disc.mesh_res_y, disc.mesh_res_x);
          }),
          py::arg("disc"),
          "Zero state with fields shaped to the discretization"
      )
      .def("__len__", [](ym::SolutionState const& self) { return self.c.size(); })
      .def(
          "__getitem__",
          [](ym::SolutionState const& self, size_t const i) {
            if (i >= self.c.size()) {
              throw py::index_error();
            }
            return xt::pyarray<double>(self.c[i]);
          }
      )
      .def(
          "__setitem__", [](ym::SolutionState& self, size_t const i, xt::pyarray<double> const& v) {
            if (i >= self.c.size()) {
              throw py::index_error();
            }
            self.c[i] = v;
          }
      );

  py::enum_<ym::Channel>(m, "Channel", py::arithmetic())
      .value("AL2O3", ym::AL2O3)
      .value("Y2O3", ym::Y2O3)
      .value("YAM", ym::YAM)
      .value("YAP", ym::YAP)
      .value("YAG", ym::YAG)
      .value("ALL", ym::ALL)
      .export_values();

  m.def(
      "channel_indices",
      &ym::channelIndices,
      py::arg("mask"),
      "Indices of the channels selected by a mask, in ascending order"
  );

  m.attr("MOLAR_MASSES") = readOnlyCopy(ym::Constants::M);
  m.attr("DEFAULT_STOICHIOMETRY") = readOnlyCopy(ym::Constants::S);

  // ---------------------------------------------------------------------------
  // Time steps
  // ---------------------------------------------------------------------------

  py::class_<ym::ITimeStep, std::shared_ptr<ym::ITimeStep>>(m, "ITimeStep");

  withFactory(
      py::class_<ym::FixedTimeStep, ym::ITimeStep, std::shared_ptr<ym::FixedTimeStep>>(
          m, "FixedTimeStep"
      ),
      m,
      "fixed_step",
      &make<ym::FixedTimeStep, double>,
      py::arg("dt") = 1.0
  )
      .def_readwrite("dt", &ym::FixedTimeStep::dt);

  withFactory(
      py::class_<ym::GeometricTimeStep, ym::ITimeStep, std::shared_ptr<ym::GeometricTimeStep>>(
          m, "GeometricTimeStep"
      ),
      m,
      "geometric_step",
      &make<ym::GeometricTimeStep, double, double>,
      py::arg("dt_0"),
      py::arg("r"),
      "dt_n = dt_0 * r^n"
  )
      .def_readwrite("dt_0", &ym::GeometricTimeStep::dt_0)
      .def_readwrite("r", &ym::GeometricTimeStep::r);

  // ---------------------------------------------------------------------------
  // Brakes
  // ---------------------------------------------------------------------------

  py::class_<ym::IBrake, std::shared_ptr<ym::IBrake>>(m, "IBrake");

  withFactory(
      py::class_<ym::FixedStepBrake, ym::IBrake, std::shared_ptr<ym::FixedStepBrake>>(
          m, "FixedStepBrake"
      ),
      m,
      "fixed_step_brake",
      &make<ym::FixedStepBrake, size_t>,
      py::arg("last_step") = 100
  )
      .def_readwrite("last_step", &ym::FixedStepBrake::last_step);

  withFactory(
      py::class_<ym::FixedTimeBrake, ym::IBrake, std::shared_ptr<ym::FixedTimeBrake>>(
          m, "FixedTimeBrake"
      ),
      m,
      "fixed_time_brake",
      &make<ym::FixedTimeBrake, double>,
      py::arg("final_time")
  )
      .def_readwrite("final_time", &ym::FixedTimeBrake::final_time);

  withFactory(
      py::class_<
          ym::ReagentQuantityThresholdBrake,
          ym::IBrake,
          std::shared_ptr<ym::ReagentQuantityThresholdBrake>>(m, "ReagentQuantityThresholdBrake"),
      m,
      "reagent_quantity_threshold_brake",
      &make<ym::ReagentQuantityThresholdBrake, double, size_t>,
      py::arg("threshold"),
      py::arg("every") = 1,
      "Brakes once reagent quantity drops to `threshold` of the initial one, checked every "
      "`every` steps"
  )
      .def_readwrite("threshold", &ym::ReagentQuantityThresholdBrake::threshold)
      .def_readwrite("every", &ym::ReagentQuantityThresholdBrake::stride)
      .def_readonly(
          "initial_reagent_quantity", &ym::ReagentQuantityThresholdBrake::initial_reagent_quantity
      );

  withFactory(
      py::class_<
          ym::ReagentMassThresholdBrake,
          ym::IBrake,
          std::shared_ptr<ym::ReagentMassThresholdBrake>>(m, "ReagentMassThresholdBrake"),
      m,
      "reagent_mass_threshold_brake",
      &make<ym::ReagentMassThresholdBrake, double, size_t>,
      py::arg("threshold"),
      py::arg("every") = 1,
      "Brakes once reagent mass drops to `threshold` of the initial one, checked every "
      "`every` steps"
  )
      .def_readwrite("threshold", &ym::ReagentMassThresholdBrake::threshold)
      .def_readwrite("every", &ym::ReagentMassThresholdBrake::stride)
      .def_readonly(
          "initial_reagent_mass", &ym::ReagentMassThresholdBrake::initial_reagent_mass
      );

  // ---------------------------------------------------------------------------
  // Capture: triggers, reducers, sinks
  // ---------------------------------------------------------------------------

  py::class_<ym::ITrigger, std::shared_ptr<ym::ITrigger>>(m, "ITrigger");

  withFactory(
      py::class_<ym::StrideTrigger, ym::ITrigger, std::shared_ptr<ym::StrideTrigger>>(
          m, "StrideTrigger"
      ),
      m,
      "stride_trigger",
      &make<ym::StrideTrigger, size_t>,
      py::arg("every") = 1
  )
      .def_readwrite("every", &ym::StrideTrigger::stride);

  withFactory(
      py::class_<ym::LastFrameTrigger, ym::ITrigger, std::shared_ptr<ym::LastFrameTrigger>>(
          m, "LastFrameTrigger"
      ),
      m,
      "last_frame_trigger",
      &make<ym::LastFrameTrigger>
  );

  py::module_ reducers = m.def_submodule("reducers", "Reducers turning a solution into a frame");

  py::class_<ym::IReducer, std::shared_ptr<ym::IReducer>>(m, "IReducer")
      .def_property_readonly("name", &ym::IReducer::name);

  withFactory(
      py::class_<
          ym::ConcentrationFieldReducer,
          ym::IReducer,
          std::shared_ptr<ym::ConcentrationFieldReducer>>(m, "ConcentrationFieldReducer"),
      reducers,
      "concentration_field",
      &make<ym::ConcentrationFieldReducer>
  );

  withFactory(
      py::class_<ym::DensityFieldReducer, ym::IReducer, std::shared_ptr<ym::DensityFieldReducer>>(
          m, "DensityFieldReducer"
      ),
      reducers,
      "density_field",
      &make<ym::DensityFieldReducer>
  );

  withFactory(
      py::class_<ym::MolarQuantityReducer, ym::IReducer, std::shared_ptr<ym::MolarQuantityReducer>>(
          m, "MolarQuantityReducer"
      ),
      reducers,
      "total_molar_quantity",
      &make<ym::MolarQuantityReducer>
  );

  withFactory(
      py::class_<ym::TotalMassReducer, ym::IReducer, std::shared_ptr<ym::TotalMassReducer>>(
          m, "TotalMassReducer"
      ),
      reducers,
      "total_mass",
      &make<ym::TotalMassReducer>
  );

  py::class_<ym::ISink, std::shared_ptr<ym::ISink>>(m, "ISink");

  withFactory(
      py::class_<ym::InMemorySink, ym::ISink, std::shared_ptr<ym::InMemorySink>>(m, "InMemorySink"),
      m,
      "in_memory_sink",
      &make<ym::InMemorySink, std::optional<size_t>>,
      py::arg("capacity") = py::none(),
      "Keeps the first `capacity` frames in memory, all frames if capacity is None"
  )
      .def_readwrite("capacity", &ym::InMemorySink::capacity);

  withFactory(
      py::class_<ym::HDF5Sink, ym::ISink, std::shared_ptr<ym::HDF5Sink>>(m, "HDF5Sink"),
      m,
      "hdf5_sink",
      &make<ym::HDF5Sink, std::string>,
      py::arg("path"),
      "Streams frames into an HDF5 file"
  )
      .def_readwrite("path", &ym::HDF5Sink::path);

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  withFactory(
      py::class_<ym::CaptureConfig>(m, "CaptureConfig"),
      m,
      "capture_config",
      [](uint32_t const channels,
         std::optional<std::shared_ptr<ym::IReducer>> reducer,
         std::optional<std::shared_ptr<ym::ITrigger>> trigger,
         std::optional<std::shared_ptr<ym::ISink>> sink) {
        // Defaults are created per config so configs never share a sink
        ym::CaptureConfig config;
        config.channels = channels;
        if (reducer) {
          config.reducer = std::move(*reducer);
        }
        if (trigger) {
          config.trigger = std::move(*trigger);
        }
        if (sink) {
          config.sink = std::move(*sink);
        }
        return config;
      },
      py::kw_only(),
      py::arg_v("channels", static_cast<uint32_t>(ym::ALL), "ALL"),
      py::arg("reducer") = py::none(),
      py::arg("trigger") = py::none(),
      py::arg("sink") = py::none()
  )
      .def_readwrite("channels", &ym::CaptureConfig::channels)
      .def_readwrite("reducer", &ym::CaptureConfig::reducer)
      .def_readwrite("trigger", &ym::CaptureConfig::trigger)
      .def_readwrite("sink", &ym::CaptureConfig::sink);

  withFactory(
      py::class_<ym::SolverConfig>(m, "SolverConfig"),
      m,
      "solver_config",
      [](std::optional<ym::Discretization> const& discretization,
         std::optional<std::shared_ptr<ym::ITimeStep>> step,
         std::optional<std::shared_ptr<ym::IBrake>> brake,
         std::optional<ym::CaptureConfig> capture,
         std::optional<xt::pyarray<double>> const& stoichiometry) {
        ym::SolverConfig config;
        if (discretization) {
          config.discretization = *discretization;
        }
        if (step) {
          config.step = std::move(*step);
        }
        if (brake) {
          config.brake = std::move(*brake);
        }
        if (capture) {
          config.capture = std::move(*capture);
        }
        if (stoichiometry) {
          config.stoichiometry = *stoichiometry;
        }
        return config;
      },
      py::kw_only(),
      py::arg("discretization") = py::none(),
      py::arg("step") = py::none(),
      py::arg("brake") = py::none(),
      py::arg("capture") = py::none(),
      py::arg("stoichiometry") = py::none()
  )
      .def_readwrite("discretization", &ym::SolverConfig::discretization)
      .def_readwrite("step", &ym::SolverConfig::step)
      .def_readwrite("brake", &ym::SolverConfig::brake)
      .def_readwrite("capture", &ym::SolverConfig::capture)
      .def_property(
          "stoichiometry",
          [](ym::SolverConfig& self) { return xt::pyarray<double>(self.stoichiometry); },
          [](ym::SolverConfig& self, xt::pyarray<double> const& v) { self.stoichiometry = v; }
      );

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  py::class_<ym::ResultMetadata>(m, "ResultMetadata")
      .def_readonly("frame_shape", &ym::ResultMetadata::frame_shape)
      .def_readonly("channels", &ym::ResultMetadata::channels)
      .def_readonly("reducer", &ym::ResultMetadata::reducer)
      .def_readonly("discretization", &ym::ResultMetadata::discretization)
      .def("__repr__", [](ym::ResultMetadata const& self) {
        return py::str("ResultMetadata(frame_shape={}, channels={}, reducer='{}')")
            .format(shapeString(self.frame_shape), self.channels, self.reducer);
      });

  py::class_<ym::ResultBatch>(m, "ResultBatch")
      .def_property_readonly(
          "values",
          [](ym::ResultBatch const& self) {
            return readOnlyView(self.owner(), self.valuesData(), self.shape());
          },
          "Frames, shape (N, frame_shape...), read-only"
      )
      .def_property_readonly(
          "times",
          [](ym::ResultBatch const& self) {
            return readOnlyView(self.owner(), self.timesData(), {self.size()});
          },
          "Capture times, shape (N,), read-only"
      )
      .def("__len__", &ym::ResultBatch::size)
      .def("__iter__", [](py::object const& self) {
        // Allows `values, times = batch`
        return py::iter(py::make_tuple(self.attr("values"), self.attr("times")));
      });

  py::class_<ym::BatchRange>(m, "BatchRange")
      .def("__len__", &ym::BatchRange::size, "Number of batches")
      .def(
          "__iter__",
          [](ym::BatchRange const& self) {
            return py::make_iterator<py::return_value_policy::move>(self.begin(), self.end());
          },
          py::keep_alive<0, 1>()
      );

  py::class_<ym::IResult, std::shared_ptr<ym::IResult>>(m, "IResult")
      .def("__len__", &ym::IResult::size, "Number of captured frames")
      .def_property_readonly("metadata", &ym::IResult::metadata)
      .def_property_readonly(
          "channels",
          [](ym::IResult const& self) { return self.metadata().channels; },
          "Channel mask of the captured frames"
      )
      .def(
          "all",
          &ym::IResult::all,
          py::call_guard<py::gil_scoped_release>(),
          "All frames as a single batch"
      )
      .def(
          "read",
          &ym::IResult::read,
          py::arg("begin"),
          py::arg("end"),
          py::call_guard<py::gil_scoped_release>(),
          "Frames [begin, end) as a single batch"
      )
      .def(
          "batches",
          &ym::IResult::batches,
          py::arg("batch_size"),
          py::keep_alive<0, 1>(),
          "Iterate over frames in batches of at most batch_size"
      )
      .def("__repr__", [](py::object const& self) {
        auto const& result = self.cast<ym::IResult const&>();
        auto const& meta = result.metadata();
        return py::str("<{} frames={} frame_shape={} reducer='{}'>")
            .format(
                self.attr("__class__").attr("__name__"),
                result.size(),
                shapeString(meta.frame_shape),
                meta.reducer
            );
      });

  py::class_<ym::InMemoryResult, ym::IResult, std::shared_ptr<ym::InMemoryResult>>(
      m, "InMemoryResult"
  );

  withFactory(
      py::class_<ym::HDF5Result, ym::IResult, std::shared_ptr<ym::HDF5Result>>(m, "HDF5Result"),
      m,
      "hdf5_result",
      &make<ym::HDF5Result, std::string>,
      py::arg("path"),
      "Opens a result file written by HDF5Sink"
  );

  // ---------------------------------------------------------------------------
  // Solver and utilities
  // ---------------------------------------------------------------------------

  m.def(
      "solve",
      &ym::solve,
      py::arg("config"),
      py::arg("ic"),
      py::arg("params"),
      py::call_guard<py::gil_scoped_release>()
  );

  m.def(
      "checkerboard_initial_condition",
      &ym::buildCheckerboardInitialCondition,
      py::arg("disc"),
      py::arg("c1"),
      py::arg("c2"),
      "2x2 checkerboard of c1 (Al2O3) and c2 (Y2O3)"
  );

  m.def(
      "quantity",
      &ym::quantity,
      py::arg("c"),
      py::arg("disc"),
      "Total molar quantity of a concentration field"
  );

  m.def(
      "reagent_quantity",
      &ym::reagentQuantity,
      py::arg("state"),
      py::arg("disc"),
      "Total molar quantity of the reagents (Al2O3 + Y2O3)"
  );
}
