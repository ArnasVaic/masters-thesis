//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_REACTION_PARAMETERS_H
#define YAG_MODEL_REACTION_PARAMETERS_H

#include <xtensor/containers/xarray.hpp>

namespace yag_model {
class ModelParameters {
 public:
  // Diffusion coefficients
  xt::xarray<double> D = {0.0, 0.0, 0.0, 0.0, 0.0};

  // Reaction speed coefficients
  xt::xarray<double> K = {0.0, 0.0, 0.0};
};

}  // namespace yag_model

#endif  // YAG_MODEL_REACTION_PARAMETERS_H
