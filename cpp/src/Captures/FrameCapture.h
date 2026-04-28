//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_FRAME_CAPTURE_H
#define YAG_MODEL_FRAME_CAPTURE_H

#include <vector>

#include "../SolverState.h"

namespace yag_model {

class FrameCapture {
 public:
  size_t stride;
  size_t capacity;
  std::vector<double> t_history;
  std::array<std::vector<xt::xarray<double>>, 5> c_history;

  FrameCapture(size_t const capacity, size_t const stride);

  void capture(SolverState const& state);
};

}  // namespace yag_model

#endif  // YAG_MODEL_FRAME_CAPTURE_H
