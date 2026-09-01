//
// Created by arnas on 8/31/26.
//

#ifndef YAG_MODEL_CONSTANTS_H
#define YAG_MODEL_CONSTANTS_H
#include <xtensor/containers/xarray.hpp>

namespace yag_model
{
    class Constants
    {
    public:
        inline static const xt::xarray<double> S = {
            {-1, -1, -1},
            {-2, 0, 0},
            {1, -1, 0},
            {0, 4, -3},
            {0, 0, 1}
        };
    };
}

#endif //YAG_MODEL_CONSTANTS_H
