#include "ConcentrationFieldReducer.h"

#include <xtensor/views/xview.hpp>

namespace yag_model {

std::string ConcentrationFieldReducer::name() const {
  return "concentration_field";
}

std::vector<size_t> ConcentrationFieldReducer::frameShape(
    size_t const channel_count, Discretization const& disc
) const {
  return {channel_count, disc.mesh_res_y, disc.mesh_res_x};
}

xt::xarray<double> ConcentrationFieldReducer::reduce(
    SolutionState const& solution, std::vector<size_t> const& channels, Discretization const& disc
) const {
  xt::xarray<double> frame = xt::empty<double>(frameShape(channels.size(), disc));

  for (size_t i = 0; i < channels.size(); ++i) {
    xt::view(frame, i, xt::all(), xt::all()) = solution.c[channels[i]];
  }

  return frame;
}

}  // namespace yag_model
