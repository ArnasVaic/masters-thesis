#define FORCE_IMPORT_ARRAY
#define PY_ARRAY_UNIQUE_SYMBOL yag_model_array_api
#include <pybind11/pybind11.h>

#include <xtensor-python/pyarray.hpp>
#include <xtensor-python/pytensor.hpp>

#include "InitialCondition/CheckerboardInitialCondition.h"

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

    py::class_<yag_model::SolutionState>(m, "SolutionState")
        .def(py::init<size_t, size_t>(), py::arg("rows"), py::arg("cols"))
        .def(
            "__getitem__",
            [](yag_model::SolutionState &self, size_t i) {
                return xt::pyarray<double>(self.c[i]);
            },
            py::return_value_policy::move)
        .def("__setitem__",
            [](yag_model::SolutionState &self,
                size_t i,
                xt::pyarray<double> v) { self.c[i] = v; });

    m.def("build_checkerboard_initial_condition",
        &yag_model::buildCheckerboardInitialCondition,
        py::arg("disc"),
        py::arg("c1_initial_concentration"),
        py::arg("c2_initial_concentration"),
        "Creates a checkerboard initial condition");
}