//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_STRIDEDCAPTURE_H
#define YAG_MODEL_STRIDEDCAPTURE_H

#include <xtensor.hpp>
#include <vector>

#include "SolverState.h"

namespace yag_model
{

class StridedCapture {
    size_t stride;
    size_t capacity;
    size_t size;

    std::vector<double> t_history;
    std::vector<xt::xarray<double>> c1_history;
    std::vector<xt::xarray<double>> c2_history;
    std::vector<xt::xarray<double>> c3_history;
    std::vector<xt::xarray<double>> c4_history;
    std::vector<xt::xarray<double>> c5_history;

    StridedCapture(size_t const capacity, size_t const stride)
    : stride(stride)
    , capacity(capacity)
    , size(0)
    , t_history(capacity)
    , c1_history(capacity)
    , c2_history(capacity)
    , c3_history(capacity)
    , c4_history(capacity)
    , c5_history(capacity)
    {

    }

    void capture(SolverState const& state);
};

}

#endif //YAG_MODEL_STRIDEDCAPTURE_H
