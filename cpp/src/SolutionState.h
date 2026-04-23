//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_SOLUTIONSTATE_H
#define YAG_MODEL_SOLUTIONSTATE_H

#include <xtensor.hpp>

namespace yag_model {

class SolutionState {
    public:
    xt::xarray<double> c1;
    xt::xarray<double> c2;
    xt::xarray<double> c3;
    xt::xarray<double> c4;
    xt::xarray<double> c5;

    SolutionState(size_t rows, size_t cols)
    : c1({rows, cols}, 0.0)
    , c2({rows, cols}, 0.0)
    , c3({rows, cols}, 0.0)
    , c4({rows, cols}, 0.0)
    , c5({rows, cols}, 0.0)
    {

    }
};

} // yag_model

#endif //YAG_MODEL_SOLUTIONSTATE_H
