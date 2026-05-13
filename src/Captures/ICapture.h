//
// Created by arnas on 5/2/26.
//

#ifndef YAG_MODEL_ICAPTURE_H
#define YAG_MODEL_ICAPTURE_H
#include "Core/SolverState.h"

namespace yag_model {

class ICapture {
   public:
    virtual ~ICapture() = default;
    virtual void capture(SolverState const& state) = 0;
};

}  // namespace yag_model

#endif  // YAG_MODEL_ICAPTURE_H
