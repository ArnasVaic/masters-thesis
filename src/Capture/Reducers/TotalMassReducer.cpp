#include "TotalMassReducer.h"

#include "Core/Constants.h"
#include "Core/Quantity.h"

namespace yag_model {

std::string TotalMassReducer::name() const {
  return "total_mass";
}

std::vector<size_t> TotalMassReducer::frameShape(
    size_t const channel_count, Discretization const& disc
) const {
  return {channel_count};
}

xt::xarray<double> TotalMassReducer::reduce(
    SolutionState const& solution, std::vector<size_t> const& channels, Discretization const& disc
) const {
  xt::xarray<double> frame = xt::empty<double>(frameShape(channels.size(), disc));

  for (size_t i = 0; i < channels.size(); ++i) {
    size_t const ch = channels[i];
    frame(i) = Constants::M(ch) * quantity(solution.c[ch], disc);
  }

  return frame;
}

}  // namespace yag_model
