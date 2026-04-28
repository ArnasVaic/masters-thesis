//
// Created by arnas on 4/23/2026.
//

#include "SolutionState.h"

namespace yag_model {
SolutionState::SolutionState(size_t rows, size_t cols) {
  for (auto& ci : c) ci = xt::xarray<double>({rows, cols}, 0.0);
}

}  // namespace yag_model