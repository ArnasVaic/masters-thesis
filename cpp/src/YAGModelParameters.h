//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_REACTION_PARAMETERS_H
#define YAG_MODEL_REACTION_PARAMETERS_H

#include <array>
#include <xtensor.hpp>

namespace yag_model
{

class YAGModelParameters {
public:
    // Diffusion coefficients
    xt::xarray<double> D = {
        0.0, 0.0, 0.0, 0.0, 0.0
    };

    // Reaction speed coefficients
    xt::xarray<double> K = {
        0.0, 0.0, 0.0
    };
};

}

#endif //YAG_MODEL_REACTION_PARAMETERS_H
