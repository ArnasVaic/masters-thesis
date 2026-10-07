#pragma once

#include "IReducer.h"

namespace yag_model {

// Molar concentration field of each channel, as solved, shape (C, H, W)
class ConcentrationFieldReducer : public IReducer {
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
