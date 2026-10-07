#pragma once

#include "IReducer.h"

namespace yag_model {

// Mass density field of each channel (concentration times molar mass), shape (C, H, W)
class DensityFieldReducer : public IReducer {
public:
  [[nodiscard]]
  std::string name() const override;

  [[nodiscard]]
  std::vector<size_t> frameShape(size_t channel_count, Discretization const& disc) const override;

  [[nodiscard]]
  xt::xarray<double> reduce(
      SolutionState const& solution, std::vector<size_t> const& channels, Discretization const& disc
  ) const override;
};

}  // namespace yag_model
