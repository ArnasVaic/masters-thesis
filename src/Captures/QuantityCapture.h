//
// Created by arnas on 4/25/2026.
//

#ifndef YAG_MODEL_QUANTITY_CAPTURE_H
#define YAG_MODEL_QUANTITY_CAPTURE_H

#include "Config/Discretization.h"
#include "Core/SolverState.h"
#include "ICapture.h"

namespace yag_model {

class QuantityCapture : public ICapture {
   public:
    size_t size;
    size_t capacity;
    xt::xarray<double> t_history;
    xt::xarray<double> q_history;
    Discretization disc;

    QuantityCapture(size_t capacity, Discretization const& disc);

    void capture(SolverState const& state) override;
};

}  // namespace yag_model

#endif  // YAG_MODEL_QUANTITY_CAPTURE_H
