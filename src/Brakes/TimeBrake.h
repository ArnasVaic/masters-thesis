//
// Created by arnas on 5/2/26.
//

#ifndef YAG_MODEL_TIME_BRAKE_H
#define YAG_MODEL_TIME_BRAKE_H
#include "IBrake.h"

namespace yag_model {

class TimeBrake : public IBrake {
   public:
    double t_end;

    explicit TimeBrake(double t_end);

    [[nodiscard]]
    bool shouldBrake(SolverState const& state) const override;
};

}  // namespace yag_model

#endif  // YAG_MODEL_TIME_BRAKE_H
