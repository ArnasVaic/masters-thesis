//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_H
#define YAG_MODEL_ADI_SOLVER_H

#include "ADISolverCache.h"
#include "Brakes/IBrake.h"
#include "CaptureTrigger/ICaptureTrigger.h"
#include "Captures/ICapture.h"
#include "Config/Discretization.h"
#include "Config/ModelParameters.h"
#include "Core/SolutionState.h"
#include "Core/SolverState.h"
#include "TimeStep/ITimeStep.h"

namespace yag_model {

class ADISolver {
    Discretization disc;
    ModelParameters params;
    std::shared_ptr<ITimeStep> timeStep;
    std::shared_ptr<IBrake> brake;
    std::shared_ptr<ICaptureTrigger> captureTrigger;
    std::unique_ptr<ICapture> capture;

   public:
    ADISolver(Discretization const &disc,
        ModelParameters reactionParameters,
        std::shared_ptr<ITimeStep> timeStep,
        std::shared_ptr<IBrake> brake,
        std::shared_ptr<ICaptureTrigger> captureTrigger,
        std::unique_ptr<ICapture> capture);

    std::unique_ptr<ICapture> solve(SolutionState const &ic);

    void solveStep(SolverState &state, ADISolverCache &cache, double dt) const;

    void xSweepStep(
        size_t mat, SolverState const &state, ADISolverCache &cache) const;

    void ySweepStep(
        size_t mat, SolverState &state, ADISolverCache &cache) const;
};

}  // namespace yag_model

#endif  // YAG_MODEL_ADI_SOLVER_H
