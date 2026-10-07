#pragma once

#include "../Core/SolverState.h"
#include "Config/Discretization.h"
#include "ICapture.h"

namespace yag_model {

class InMemoryFrameCapture : public ICapture {
public:
  size_t size;
  size_t capacity;
  xt::xarray<double> t_history;
  xt::xarray<double> c_history;

  explicit InMemoryFrameCapture(size_t capacity, Discretization const& disc);

  void capture(SolverState const& state) override;
};

}  // namespace yag_model
