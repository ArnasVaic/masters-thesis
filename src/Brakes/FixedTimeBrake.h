#pragma once

#include "IBrake.h"

namespace yag_model {

class FixedTimeBrake : public IBrake {
public:
  double final_time;

  explicit FixedTimeBrake(double final_time);

  [[nodiscard]]
  bool shouldBrake(SolverState const& state) const override;
};

}  // namespace yag_model
