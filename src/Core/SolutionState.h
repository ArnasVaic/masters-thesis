//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_SOLUTION_STATE_H
#define YAG_MODEL_SOLUTION_STATE_H

#include <xtensor/containers/xarray.hpp>

namespace yag_model {

class SolutionState {
 public:
  std::array<xt::xarray<double>, 5> c;

  SolutionState(size_t rows, size_t cols);
};

}  // namespace yag_model

#endif  // YAG_MODEL_SOLUTION_STATE_H
