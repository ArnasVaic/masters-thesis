#include "DensityFieldReducer.h"

#include <xtensor/views/xview.hpp>

#include "Core/Constants.h"

namespace yag_model {

std::string DensityFieldReducer::name() const {
  return "density_field";
}

std::vector<size_t> DensityFieldReducer::frameShape(
    size_t const channel_count, Discretization const& disc
) const {
  return {channel_count, disc.mesh_res_y, disc.mesh_res_x};
}

xt::xarray<double> DensityFieldReducer::reduce(
    SolutionState const& solution, std::vector<size_t> const& channels, Discretization const& disc
) const {
  xt::xarray<double> frame = xt::empty<double>(frameShape(channels.size(), disc));

  for (size_t i = 0; i < channels.size(); ++i) {
    size_t const ch = channels[i];
    xt::view(frame, i, xt::all(), xt::all()) = Constants::M(ch) * solution.c[ch];
  }

  return frame;
}

}  // namespace yag_model
