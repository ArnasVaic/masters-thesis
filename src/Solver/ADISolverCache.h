//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_CACHE_H
#define YAG_MODEL_ADI_SOLVER_CACHE_H

#include "../Config/Discretization.h"
#include "../Config/ModelParameters.h"
#include "../Core/SolutionState.h"
#include "../Core/TridiagonalLU.h"

namespace yag_model {

class ADISolverCache {
   public:
    xt::xarray<double, xt::layout_type::column_major> xSweepRHSBuffer;
    xt::xarray<double, xt::layout_type::column_major> ySweepRHSBuffer;
    xt::xarray<double> reactionCoefficients;
    std::vector<TridiagonalLU> xSweepMats;
    std::vector<TridiagonalLU> ySweepMats;
    xt::xarray<double> mu_x;
    xt::xarray<double> mu_y;
    SolutionState halfBuffer;

    ADISolverCache(size_t rows, size_t cols);

    void update(
        ModelParameters const& params, Discretization const& disc, double dt);

   private:
    void initializeReactionCoefficients(
        ModelParameters const& reactionParameters, double dt);

    static void initializeSweepMat(TridiagonalLU& tri, double mu);

    void initializeSweepMats(
        double dt, ModelParameters const& params, Discretization const& disc);
};

}  // namespace yag_model

#endif  // YAG_MODEL_ADI_SOLVER_CACHE_H
