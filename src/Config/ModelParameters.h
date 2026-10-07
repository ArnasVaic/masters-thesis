#pragma once

#include <xtensor/containers/xarray.hpp>

namespace yag_model {
class ModelParameters {
   public:
    ModelParameters(xt::xarray<double> const& D, xt::xarray<double> const& k);
    // Diffusion coefficients
    xt::xarray<double> D = {0.0, 0.0, 0.0, 0.0, 0.0};

    // Reaction speed coefficients
    xt::xarray<double> K = {0.0, 0.0, 0.0};
};

}  // namespace yag_model
