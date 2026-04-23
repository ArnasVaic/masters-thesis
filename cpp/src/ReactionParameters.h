//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_REACTIONPARAMETERS_H
#define YAG_MODEL_REACTIONPARAMETERS_H

#include <array>

namespace yag_model
{

class ReactionParameters {
public:
    // Diffusion coefficients
    std::array<double, 5> D = { 0.0 };

    // Reaction speed coefficients
    std::array<double, 3> K = { 0.0 };
};

}

#endif //YAG_MODEL_REACTIONPARAMETERS_H
