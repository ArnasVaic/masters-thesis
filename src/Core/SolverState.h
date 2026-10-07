#pragma once

#include <xtensor/containers/xarray.hpp>

#include "SolutionState.h"

namespace yag_model {
class SolverState {
 public:
  SolutionState solution;
  double time;
  size_t step;

  SolverState(size_t const rows, size_t const cols);
};

}  // namespace yag_model
