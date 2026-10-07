#pragma once

#include <xtensor/containers/xarray.hpp>

namespace yag_model {

class SolutionState {
public:
  std::array<xt::xarray<double>, 5> c;

  SolutionState(size_t rows, size_t cols);
};

}  // namespace yag_model
