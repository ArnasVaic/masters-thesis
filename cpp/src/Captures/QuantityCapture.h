//
// Created by arnas on 4/25/2026.
//

#ifndef YAG_MODEL_QUANTITY_CAPTURE_H
#define YAG_MODEL_QUANTITY_CAPTURE_H

#include <vector>

#include "../Discretization.h"
#include "../SolverState.h"

namespace yag_model {

class QuantityCapture {
 public:
  size_t stride;
  size_t capacity;
  std::vector<double> t_history;
  std::array<std::vector<double>, 5> q_history;
  Discretization disc;

  QuantityCapture(size_t const capacity, size_t const stride,
                  Discretization const& disc);

  void capture(SolverState const& state);
};

}  // namespace yag_model

#endif  // YAG_MODEL_QUANTITY_CAPTURE_H
