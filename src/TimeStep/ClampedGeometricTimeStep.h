#pragma once
#include "ITimeStep.h"

namespace yag_model {

class ClampedGeometricTimeStep : public ITimeStep {
public:
  double dt_0;
  double r;
  double upper_bound;
  size_t stride;

  ClampedGeometricTimeStep(double dt_0, double r, double upper_bound, size_t stride);

  void begin(SolverContext const& ctx) override;

  double advance(SolverState const& state) override;

private:
  double dt;
};

}  // namespace yag_model
