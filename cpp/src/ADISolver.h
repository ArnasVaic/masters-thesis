//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_H
#define YAG_MODEL_ADI_SOLVER_H

#include "ADISolverCache.h"
#include "Discretization.h"
#include "YAGModelParameters.h"
#include "SolutionState.h"
#include "SolverState.h"

namespace yag_model {

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
class ADISolver {
    Discretization disc;
    YAGModelParameters reactionParameters;
    TimeStepPolicy timeStepPolicy;
    BrakePolicy brakePolicy;
    CapturePolicy capturePolicy;

public:

    ADISolver(
        Discretization disc,
        YAGModelParameters reactionParameters,
        TimeStepPolicy timeStepPolicy,
        BrakePolicy brakePolicy,
        CapturePolicy capturePolicy)
    : disc(std::move(disc))
    , reactionParameters(std::move(reactionParameters))
    , timeStepPolicy(std::move(timeStepPolicy))
    , brakePolicy(std::move(brakePolicy))
    , capturePolicy(std::move(capturePolicy))
    {

    }

    void solve(SolutionState const& ic) const
    {
        SolverState state(disc.mesh_res_y, disc.mesh_res_x);
        capturePolicy.capture(state);

        ADISolverCache cache(disc.mesh_res_y, disc.mesh_res_x);

        double cached_dt = timeStepPolicy.getTimestep();

        while (!brakePolicy.shouldBrake(state))
        {
            double const current_dt = timeStepPolicy.getTimestep();

            if (std::abs(current_dt - cached_dt) < 1e-9)
            {
                cached_dt = current_dt;
                // Update cache
            }

            solveStep(state, cache);

            timeStepPolicy.advance(state);

            capturePolicy.capture(state);
        }
    }

    void solveStep(
        SolverState& state,
        ADISolverCache const& cache)
    {
        size_t const matCount = state.solution.c.size();
        for (size_t mat = 0; mat < matCount; ++mat)
        {
            xSweepStep(mat, state, cache);
        }

        for (size_t mat = 0; mat < matCount; ++mat)
        {
            ySweepStep(mat, state, cache);
        }
    }

    void xSweepStep(
        size_t mat,
        SolverState &state,
        ADISolverCache &cache)
    {
        const double mu_y = cache.mu.y[mat];
        const auto &mu_m = xt::view(cache.reactionCoefficients, mat, xt::all());

        const auto &c = state.solution.c[mat];
        const auto &c1 = state.solution.c[0];
        const auto &c2 = state.solution.c[1];
        const auto &c3 = state.solution.c[2];
        const auto &c4 = state.solution.c[3];

        for (size_t row = 0; row < disc.mesh_res_y; ++row)
        {
            double const top_row = std::min(row + 1, disc.mesh_res_y - 1);
            double const bot_row = std::max(row - 1, 0zu);

            auto const &c_row = xt::view(c, row, xt::all());
            auto const &c_top_row = xt::view(c, top_row, xt::all());
            auto const &c_bot_row = xt::view(c, bot_row, xt::all());
            auto const &c1_row = xt::view(c1, row, xt::all());
            auto const &c2_row = xt::view(c2, row, xt::all());
            auto const &c3_row = xt::view(c3, row, xt::all());
            auto const &c4_row = xt::view(c4, row, xt::all());

            auto const diffusion_part =
                (1 - 2 * mu_y) * c_row + mu_y * ( c_top_row + c_bot_row);

            auto reaction_part =
                c1_row * (mu_m(0) * c2_row + mu_m(1) * c3_row + mu_m(2) * c4_row);

            auto col = xt::view(cache.rhsBuffer, xt::all(), row);
            col = diffusion_part + reaction_part;
        }

        cache.xSweepMats[mat].solve(disc.mesh_res_y, cache.rhsBuffer.data());
        cache.halfBuffer.c[mat] = cache.rhsBuffer;
    }

    void ySweepStep(
        size_t mat,
        SolverState &state,
        ADISolverCache &cache)
    {
        const double mu_x = cache.mu.x[mat];
        const auto &mu_m = xt::view(cache.reactionCoefficients, mat, xt::all());

        const auto &c = cache.halfBuffer.c[mat];
        const auto &c1 = cache.halfBuffer.c[0];
        const auto &c2 = cache.halfBuffer.c[1];
        const auto &c3 = cache.halfBuffer.c[2];
        const auto &c4 = cache.halfBuffer.c[3];

        for (size_t col = 0; col < disc.mesh_res_x; ++col)
        {
            double const l_col = std::min(col + 1, disc.mesh_res_x - 1);
            double const r_col = std::max(col - 1, 0zu);

            auto const &c_col = xt::view(c, col, xt::all());
            auto const &c_l_col = xt::view(c, l_col, xt::all());
            auto const &c_r_col = xt::view(c, r_col, xt::all());
            auto const &c1_col = xt::view(c1, col, xt::all());
            auto const &c2_col = xt::view(c2, col, xt::all());
            auto const &c3_col = xt::view(c3, col, xt::all());
            auto const &c4_col = xt::view(c4, col, xt::all());

            auto const diffusion_part =
                (1 - 2 * mu_x) * c_col + mu_x * (c_l_col + c_r_col);

            auto reaction_part =
                c1_col * (mu_m(0) * c2_col + mu_m(1) * c3_col + mu_m(2) * c4_col);

            auto rhs_col = xt::view(cache.rhsBuffer, xt::all(), col);
            rhs_col = diffusion_part + reaction_part;
        }

        cache.ySweepMats[mat].solve(disc.mesh_res_x, cache.rhsBuffer.data());
        state.solution.c[mat] = cache.rhsBuffer;
    }

};

} // yag_model

#endif //YAG_MODEL_ADI_SOLVER_H
