//
// Created by arnas on 4/26/2026.
//

#include "QuantityCapture.h"

#include <xtensor/views/xview.hpp>

#include "Core/Quantity.h"

namespace yag_model {

QuantityCapture::QuantityCapture(
    size_t const capacity, Discretization const& disc)
    : size(0), capacity(capacity), disc(disc) {
    t_history = xt::xarray<double>({capacity}, 0.0);
    q_history = xt::xarray<double>({5, capacity}, 0.0);
}

void QuantityCapture::capture(SolverState const& state) {
    if (size >= capacity) return;

    t_history[size] = state.time;

    for (size_t mat = 0; mat < state.solution.c.size(); ++mat) {
        double const q = quantity(state.solution.c[mat], disc);
        xt::view(q_history, mat, size) = q;
    }

    size++;
}

}  // namespace yag_model