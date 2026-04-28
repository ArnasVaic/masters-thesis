//
// Created by arnas on 4/26/2026.
//

#include "Captures/QuantityCapture.h"

#include "../Quantity.h"

namespace yag_model {

QuantityCapture::QuantityCapture(size_t const capacity, size_t const stride,
                                 Discretization const& disc)
    : stride(stride), capacity(capacity), disc(disc) {
  assert(stride > 0);
  t_history.reserve(capacity);
  for (auto& species_quantity_history : q_history) {
    species_quantity_history.reserve(capacity);
  }
}

void QuantityCapture::capture(SolverState const& state) {
  if (state.step % stride != 0) return;

  if (t_history.size() >= capacity) return;

  t_history.push_back(state.time);

  for (size_t mat = 0; mat < state.solution.c.size(); ++mat) {
    double const q = quantity(state.solution.c[mat], disc);
    q_history[mat].push_back(q);
  }
}

}  // namespace yag_model