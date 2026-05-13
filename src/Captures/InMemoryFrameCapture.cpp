//
// Created by arnas on 4/23/2026.
//

#include "InMemoryFrameCapture.h"

#include <xtensor/views/xview.hpp>
using namespace xt::placeholders;

namespace yag_model {
InMemoryFrameCapture::InMemoryFrameCapture(
    size_t const capacity, Discretization const& disc)
    : size(0), capacity(capacity) {
    t_history = xt::xarray<double>({capacity}, 0.0);
    c_history = xt::xarray<double>(
        {5, capacity, disc.mesh_res_x, disc.mesh_res_y}, 0.0);
}

inline void InMemoryFrameCapture::capture(SolverState const& state) {
    if (size >= capacity) return;

    t_history[size] = state.time;

    for (size_t mat = 0; mat < state.solution.c.size(); ++mat) {
        xt::view(c_history, mat, size, xt::all(), xt::all()) =
            state.solution.c[mat];
    }

    size++;
}
}  // namespace yag_model
