//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_FRAME_CAPTURE_H
#define YAG_MODEL_FRAME_CAPTURE_H

#include <vector>

#include "../Core/SolverState.h"
#include "ICapture.h"

namespace yag_model {

class FrameCapture : public ICapture {
   public:
    size_t stride;
    size_t capacity;
    std::vector<double> t_history;
    std::array<std::vector<xt::xarray<double>>, 5> c_history;

    explicit FrameCapture(size_t capacity);

    void capture(SolverState const& state) override;
};

}  // namespace yag_model

#endif  // YAG_MODEL_FRAME_CAPTURE_H
