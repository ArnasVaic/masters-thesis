#pragma once

#include <string>
#include <vector>
#include <xtensor/containers/xarray.hpp>

#include "Config/Discretization.h"
#include "Core/SolutionState.h"

namespace yag_model {

// Turns the selected channels of a solution into a single captured frame
class IReducer {
public:
  virtual ~IReducer() = default;

  // Identifies the reducer in result metadata
  [[nodiscard]]
  virtual std::string name() const = 0;

  // Shape of a frame produced from `channel_count` channels
  [[nodiscard]]
  virtual std::vector<size_t> frameShape(
      size_t channel_count, Discretization const& disc
  ) const = 0;

  [[nodiscard]]
  virtual xt::xarray<double> reduce(
      SolutionState const& solution, std::vector<size_t> const& channels, Discretization const& disc
  ) const = 0;
};

}  // namespace yag_model
