//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_H
#define YAG_MODEL_ADI_SOLVER_H

#include "ADISolverCache.h"
#include "Discretization.h"
#include "ModelParameters.h"
#include "SolutionState.h"
#include "SolverState.h"

namespace yag_model {

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
class ADISolver {
  Discretization disc;
  ModelParameters params;
  TimeStepPolicy timeStepPolicy;
  BrakePolicy brakePolicy;
  CapturePolicy &capturePolicy;

 public:
  ADISolver(Discretization const &disc, ModelParameters reactionParameters,
            TimeStepPolicy timeStepPolicy, BrakePolicy brakePolicy,
            CapturePolicy &capturePolicy);

  void solve(SolutionState const &ic);

  void solveStep(SolverState &state, ADISolverCache &cache, double dt) const;

  void xSweepStep(size_t mat, SolverState const &state,
                  ADISolverCache &cache) const;

  void ySweepStep(size_t mat, SolverState &state, ADISolverCache &cache) const;
};

}  // namespace yag_model

#include "ADISolver.tpp"

#endif  // YAG_MODEL_ADI_SOLVER_H
