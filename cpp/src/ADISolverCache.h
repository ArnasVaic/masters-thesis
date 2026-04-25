//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_CACHE_H
#define YAG_MODEL_ADI_SOLVER_CACHE_H
#include <xtensor.hpp>

#include "Discretization.h"
#include "MuCoefficients.h"
#include "SolutionState.h"
#include "YAGModelParameters.h"
#include "TridiagonalLU.h"

namespace yag_model {

class ADISolverCache {
public:

    xt::xarray<double, xt::layout_type::column_major> rhsBuffer;
    xt::xarray<double> reactionCoefficients;
    std::vector<TridiagonalLU> xSweepMats;
    std::vector<TridiagonalLU> ySweepMats;
    MuCoefficients mu;
    SolutionState halfBuffer;

    ADISolverCache(size_t rows, size_t cols)
    : rhsBuffer({cols, rows}, 0.0)
    , reactionCoefficients({5, 3}, 0.0)
    , xSweepMats(5, TridiagonalLU(cols))
    , ySweepMats(5, TridiagonalLU(rows))
    , halfBuffer(rows, cols)
    {

    }

    void update(
        YAGModelParameters const& params,
        Discretization const& disc,
        double const dt)
    {
        initializeReactionCoefficients(params, reactionCoefficients, dt);
        initializeSweepMats(xSweepMats, ySweepMats, mu);
        mu.initialize(disc, params, dt);
    }

private:

    static void initializeReactionCoefficients(
        YAGModelParameters const& reactionParameters,
        xt::xarray<double> &reactionCoefficients,
        double const dt)
    {
        reactionCoefficients = {
            { -1.0, -1.0, -1.0 },
            { -2.0, 0.0, 0.0 },
            { 1.0, -1.0, 0.0 },
            { 0.0, 4.0, -3.0 },
            { 0.0, 0.0, 1.0 }
        };

        for (size_t i = 0; i < reactionParameters.K.size(); ++i)
        {
            auto col = xt::view(reactionCoefficients, xt::all(), i);
            col *= reactionParameters.K[i];
        }

        reactionCoefficients *= 0.5 * dt;
    }

    static void initializeSweepMats(
        std::vector<TridiagonalLU> & xSweepMats,
        std::vector<TridiagonalLU> & ySweepMats,
        MuCoefficients const& mu)
    {
        for (size_t i = 0; i < xSweepMats.size(); ++i)
        {
            auto &main_diag = xSweepMats[i].d;
            std::ranges::fill(main_diag, 1 + 2 * mu.x[i]);

            auto &lower_diag = xSweepMats[i].dl;
            std::ranges::fill(lower_diag, -mu.x[i]);
            lower_diag.back() = -2 * mu.x[i];

            auto &upper_diag = xSweepMats[i].du;
            std::ranges::fill(upper_diag, -mu.x[i]);
            upper_diag.front() = -2 * mu.x[i];
        }
    }

};

} // yag_model

#endif //YAG_MODEL_ADI_SOLVER_CACHE_H
