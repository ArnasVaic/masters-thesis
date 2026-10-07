#pragma once

#include <xtensor/containers/xarray.hpp>

#include "SolutionState.h"

namespace yag_model {
class SolverState {
public:
  SolutionState solution;
  double time;
  size_t step;

  // Set by the solver once the brake has decided this is the last state
  bool is_final;

  SolverState(size_t const rows, size_t const cols);
};

}  // namespace yag_model
