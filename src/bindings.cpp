#define FORCE_IMPORT_ARRAY
#define PY_ARRAY_UNIQUE_SYMBOL yag_model_array_api
#include <pybind11/pybind11.h>

#include <xtensor-python/pyarray.hpp>
#include <xtensor-python/pytensor.hpp>
#include <xtensor/containers/xarray.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/IBrake.h"
#include "Brakes/ReagentQuantityThresholdBrake.h"
#include "Brakes/TimeBrake.h"
#include "CaptureTrigger/LastFrameCaptureTrigger.h"
#include "CaptureTrigger/StrideCaptureTrigger.h"
#include "Captures/InMemoryFrameCapture.h"
#include "Captures/QuantityCapture.h"
#include "Config/ModelParameters.h"
#include "Core/Quantity.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"
#include "TimeStep/ITimeStep.h"

namespace py = pybind11;

PYBIND11_MODULE(yag_model, m) {
    m.doc() = "YAG model bindings";

    xt::import_numpy();

    py::class_<yag_model::Discretization>(m, "Discretization")
        .def(py::init<double, double, size_t, size_t>(),
            py::arg("physical_space_w"),
            py::arg("physical_space_h"),
            py::arg("mesh_res_x"),
            py::arg("mesh_res_y"))
        .def_readonly(
            "physical_space_w", &yag_model::Discretization::physical_space_w)
        .def_readonly(
            "physical_space_h", &yag_model::Discretization::physical_space_h)
        .def_readonly("mesh_res_x", &yag_model::Discretization::mesh_res_x)
        .def_readonly("mesh_res_y", &yag_model::Discretization::mesh_res_y)
        .def_readonly("dx", &yag_model::Discretization::dx)
        .def_readonly("dy", &yag_model::Discretization::dy);

    py::class_<yag_model::ModelParameters>(m, "ModelParameters")
        .def(py::init<const xt::pyarray<double> &,
                 const xt::pyarray<double> &>(),
            py::arg("D"),
            py::arg("K"))
        .def_property(
            "D",
            [](yag_model::ModelParameters &self) {
                return xt::pyarray<double>(self.D);
            },
            [](yag_model::ModelParameters &self, xt::pyarray<double> v) {
                self.D = v;
            })

        .def_property(
            "K",
            [](yag_model::ModelParameters &self) {
                return xt::pyarray<double>(self.K);
            },
            [](yag_model::ModelParameters &self, xt::pyarray<double> v) {
                self.K = v;
            });

    py::class_<yag_model::SolutionState>(m, "SolutionState")
        .def(py::init<size_t, size_t>(), py::arg("rows"), py::arg("cols"))
        .def("__getitem__",
            [](yag_model::SolutionState &self, size_t i) { return self.c[i]; })
        .def("__setitem__",
            [](yag_model::SolutionState &self,
                size_t i,
                xt::pyarray<double> v) { self.c[i] = v; });

    py::class_<yag_model::SolverState>(m, "SolverState")
        .def(py::init<size_t, size_t>(), py::arg("rows"), py::arg("cols"))
        .def_readwrite("solution", &yag_model::SolverState::solution)
        .def_readwrite("time", &yag_model::SolverState::time)
        .def_readwrite("step", &yag_model::SolverState::step);

    py::class_<yag_model::ITimeStep, std::shared_ptr<yag_model::ITimeStep>>(
        m, "ITimeStep")
        .def("getTimestep", &yag_model::ITimeStep::getTimestep)
        .def("advance", &yag_model::ITimeStep::advance, py::arg("state"));

    py::class_<yag_model::FixedTimeStep,
        yag_model::ITimeStep,
        std::shared_ptr<yag_model::FixedTimeStep>>(m, "FixedTimeStep")
        .def(py::init<double>(), py::arg("dt"))
        .def_readwrite("dt", &yag_model::FixedTimeStep::dt)
        .def("getTimestep", &yag_model::FixedTimeStep::getTimestep)
        .def("advance", &yag_model::FixedTimeStep::advance, py::arg("state"));

    py::class_<yag_model::IBrake, std::shared_ptr<yag_model::IBrake>>(
        m, "IBrake");

    py::class_<yag_model::FixedStepBrake,
        yag_model::IBrake,
        std::shared_ptr<yag_model::FixedStepBrake>>(m, "FixedStepBrake")
        .def(py::init<size_t>(), py::arg("steps"))
        .def_readonly("steps", &yag_model::FixedStepBrake::steps);

    py::class_<yag_model::TimeBrake,
        yag_model::IBrake,
        std::shared_ptr<yag_model::TimeBrake>>(m, "TimeBrake")
        .def(py::init<double>(), py::arg("t_end"))
        .def_readonly("t_end", &yag_model::TimeBrake::t_end);

    py::class_<yag_model::ReagentQuantityThresholdBrake,
        yag_model::IBrake,
        std::shared_ptr<yag_model::ReagentQuantityThresholdBrake>>(
        m, "ReagentQuantityThresholdBrake")
        .def(py::init<double,
                 double,
                 size_t,
                 const yag_model::Discretization &>(),
            py::arg("threshold"),
            py::arg("initial_reagent_quantity"),
            py::arg("stride"),
            py::arg("disc"))
        .def_readonly(
            "threshold", &yag_model::ReagentQuantityThresholdBrake::threshold)
        .def_readonly("initial_reagent_quantity",
            &yag_model::ReagentQuantityThresholdBrake::initial_reagent_quantity)
        .def_readonly(
            "stride", &yag_model::ReagentQuantityThresholdBrake::stride)
        .def_readonly("disc", &yag_model::ReagentQuantityThresholdBrake::disc);

    py::class_<yag_model::ICaptureTrigger,
        std::shared_ptr<yag_model::ICaptureTrigger>>(m, "ICaptureTrigger");

    py::class_<yag_model::StrideCaptureTrigger,
        yag_model::ICaptureTrigger,
        std::shared_ptr<yag_model::StrideCaptureTrigger>>(
        m, "StrideCaptureTrigger")
        .def(py::init<size_t>(), py::arg("stride"))
        .def_readwrite("stride", &yag_model::StrideCaptureTrigger::stride)
        .def("shouldCapture",
            &yag_model::StrideCaptureTrigger::shouldCapture,
            py::arg("state"));

    py::class_<yag_model::LastFrameCaptureTrigger,
        yag_model::ICaptureTrigger,
        std::shared_ptr<yag_model::LastFrameCaptureTrigger>>(
        m, "LastFrameCaptureTrigger")
        .def(py::init<std::shared_ptr<yag_model::IBrake>>(), py::arg("brake"))
        .def_readwrite("brake", &yag_model::LastFrameCaptureTrigger::brake)
        .def("shouldCapture",
            &yag_model::LastFrameCaptureTrigger::shouldCapture,
            py::arg("state"));

    py::class_<yag_model::ICapture, std::shared_ptr<yag_model::ICapture>>(
        m, "ICapture");

    py::class_<yag_model::InMemoryFrameCapture,
        yag_model::ICapture,
        std::shared_ptr<yag_model::InMemoryFrameCapture>>(
        m, "InMemoryFrameCapture")
        .def(py::init<size_t, yag_model::Discretization>(),
            py::arg("capacity"),
            py::arg("disc"))
        .def_readonly("size", &yag_model::InMemoryFrameCapture::size)
        .def_readonly("capacity", &yag_model::InMemoryFrameCapture::capacity)
        .def_readonly("t_history", &yag_model::InMemoryFrameCapture::t_history)
        .def_readonly("c_history", &yag_model::InMemoryFrameCapture::c_history);

    py::class_<yag_model::QuantityCapture,
        yag_model::ICapture,
        std::shared_ptr<yag_model::QuantityCapture>>(m, "QuantityCapture")
        .def(py::init<size_t, yag_model::Discretization>(),
            py::arg("capacity"),
            py::arg("disc"))
        .def_readonly("size", &yag_model::QuantityCapture::size)
        .def_readonly("capacity", &yag_model::QuantityCapture::capacity)
        .def_readonly("t_history", &yag_model::QuantityCapture::t_history)
        .def_readonly("q_history", &yag_model::QuantityCapture::q_history);

    m.def(
        "solve",
        [](yag_model::Discretization const &disc,
            yag_model::ModelParameters const &reactionParameters,
            std::shared_ptr<yag_model::ITimeStep> timeStep,
            std::shared_ptr<yag_model::IBrake> brake,
            std::shared_ptr<yag_model::ICaptureTrigger> captureTrigger,
            std::shared_ptr<yag_model::ICapture> capture,
            yag_model::SolutionState const &ic) {

            // Release the Python GIL
            py::gil_scoped_release release;

            return yag_model::solve(disc,
                reactionParameters,
                *timeStep,
                *brake,
                *captureTrigger,
                *capture,
                ic);
        },
        py::arg("disc"),
        py::arg("reactionParameters"),
        py::arg("timeStep"),
        py::arg("brake"),
        py::arg("captureTrigger"),
        py::arg("capture"),
        py::arg("ic"));

    m.def("build_checkerboard_initial_condition",
        &yag_model::buildCheckerboardInitialCondition,
        py::arg("disc"),
        py::arg("c1_initial_concentration"),
        py::arg("c2_initial_concentration"),
        "Creates a checkerboard initial condition");

    m.def("quantity",
        &yag_model::quantity,
        py::arg("c"),
        py::arg("disc"),
        "Compute total quantity from concentration field");

    m.def("reagent_quantity",
        &yag_model::reagentQuantity,
        py::arg("state"),
        py::arg("disc"),
        "Compute reagent quantity from solution state");
}
