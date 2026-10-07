#pragma once

#include "Config/Discretization.h"
#include "Core/SolverState.h"
#include "ICapture.h"

namespace yag_model {

class QuantityCapture : public ICapture {
public:
  size_t size;
  size_t capacity;
  xt::xarray<double> t_history;
  xt::xarray<double> q_history;
  Discretization disc;

  QuantityCapture(size_t capacity, Discretization const& disc);

  void capture(SolverState const& state) override;
};

}  // namespace yag_model
