//
// Created by arnas on 4/23/2026.
//

#ifndef TEST_XTENSOR_SOLVER_STATE_H
#define TEST_XTENSOR_SOLVER_STATE_H

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

#endif  // TEST_XTENSOR_SOLVER_STATE_H
