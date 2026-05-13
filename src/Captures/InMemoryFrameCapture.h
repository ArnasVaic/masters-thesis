//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_FRAME_CAPTURE_H
#define YAG_MODEL_FRAME_CAPTURE_H

#include "../Core/SolverState.h"
#include "Config/Discretization.h"
#include "ICapture.h"

namespace yag_model {

class InMemoryFrameCapture : public ICapture {
   public:
    size_t size;
    size_t capacity;
    xt::xarray<double> t_history;
    xt::xarray<double> c_history;

    explicit InMemoryFrameCapture(size_t capacity, Discretization const& disc);

    void capture(SolverState const& state) override;
};

}  // namespace yag_model

#endif  // YAG_MODEL_FRAME_CAPTURE_H
