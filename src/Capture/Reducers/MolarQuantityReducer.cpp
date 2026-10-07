#include "MolarQuantityReducer.h"

#include "Core/Quantity.h"

namespace yag_model {

std::string MolarQuantityReducer::name() const {
  return "total_molar_quantity";
}

std::vector<size_t> MolarQuantityReducer::frameShape(
    size_t const channel_count, Discretization const& disc
) const {
  return {channel_count};
}

xt::xarray<double> MolarQuantityReducer::reduce(
    SolutionState const& solution, std::vector<size_t> const& channels, Discretization const& disc
) const {
  xt::xarray<double> frame = xt::empty<double>(frameShape(channels.size(), disc));

  for (size_t i = 0; i < channels.size(); ++i) {
    frame(i) = quantity(solution.c[channels[i]], disc);
  }

  return frame;
}

}  // namespace yag_model
