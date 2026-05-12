#include "ADISolver.h"

#include <xtensor/core/xnoalias.hpp>

namespace yag_model {

ADISolver::ADISolver(Discretization const& disc,
    ModelParameters reactionParameters,
    std::shared_ptr<ITimeStep> timeStep,
    std::shared_ptr<IBrake> brake,
    std::shared_ptr<ICaptureTrigger> captureTrigger,
    std::unique_ptr<ICapture> capture)
    : disc(disc),
      params(std::move(reactionParameters)),
      timeStep(std::move(timeStep)),
      brake(std::move(brake)),
      captureTrigger(std::move(captureTrigger)),
      capture(std::move(capture)) {}

std::unique_ptr<ICapture> ADISolver::solve(SolutionState const& ic) {
    SolverState state(disc.mesh_res_y, disc.mesh_res_x);
    state.solution = ic;

    if (captureTrigger->shouldCapture(state)) {
        capture->capture(state);
    }

    ADISolverCache cache(disc.mesh_res_y, disc.mesh_res_x);
    double cached_dt = timeStep->getTimestep();
    cache.update(params, disc, cached_dt);

    while (!brake->shouldBrake(state)) {
        double const current_dt = timeStep->getTimestep();

        if (std::abs(current_dt - cached_dt) > 1e-9) {
            cached_dt = current_dt;
            cache.update(params, disc, cached_dt);
        }

        solveStep(state, cache, cached_dt);

        timeStep->advance(state);

        if (captureTrigger->shouldCapture(state)) {
            capture->capture(state);
        }
    }

    return std::move(capture);
}

void ADISolver::solveStep(
    SolverState& state, ADISolverCache& cache, double const dt) const {
    size_t const matCount = state.solution.c.size();
    for (size_t mat = 0; mat < matCount; ++mat) {
        xSweepStep(mat, state, cache);
    }

    for (size_t mat = 0; mat < matCount; ++mat) {
        ySweepStep(mat, state, cache);
    }

    state.time += dt;
    state.step++;
}

void ADISolver::xSweepStep(
    size_t const mat, SolverState const& state, ADISolverCache& cache) const {
    double const mu_y = cache.mu_y[mat];
    double const mu_1 = cache.reactionCoefficients(mat, 0);
    double const mu_2 = cache.reactionCoefficients(mat, 1);
    double const mu_3 = cache.reactionCoefficients(mat, 2);

    auto const& c = state.solution.c[mat];
    auto const& c1 = state.solution.c[0];
    auto const& c2 = state.solution.c[1];
    auto const& c3 = state.solution.c[2];
    auto const& c4 = state.solution.c[3];

    for (int row = 0; row < disc.mesh_res_y; ++row) {
        size_t const top_row = std::min<int>(row + 1, disc.mesh_res_y - 1);
        size_t const bot_row = std::max<int>(row - 1, 0);

        for (int col = 0; col < disc.mesh_res_x; ++col) {
            // LAPACK can batch solve all lines at once but expects them
            // to be given as column vectors so even if were going line by
            // line we must write column by column to the rhsBuffer
            cache.xSweepRHSBuffer(col, row) =
                (1 - 2 * mu_y) * c(row, col) +
                mu_y * (c(top_row, col) + c(bot_row, col)) +
                c1(row, col) * (mu_1 * c2(row, col) + mu_2 * c3(row, col) +
                                   mu_3 * c4(row, col));
        }
    }
    cache.xSweepMats[mat].solve(disc.mesh_res_y, cache.xSweepRHSBuffer.data());
    xt::noalias(cache.halfBuffer.c[mat]) = xt::transpose(cache.xSweepRHSBuffer);
}

void ADISolver::ySweepStep(
    size_t const mat, SolverState& state, ADISolverCache& cache) const {
    double const mu_x = cache.mu_x[mat];
    double const mu_1 = cache.reactionCoefficients(mat, 0);
    double const mu_2 = cache.reactionCoefficients(mat, 1);
    double const mu_3 = cache.reactionCoefficients(mat, 2);

    auto const& c = cache.halfBuffer.c[mat];
    auto const& c1 = cache.halfBuffer.c[0];
    auto const& c2 = cache.halfBuffer.c[1];
    auto const& c3 = cache.halfBuffer.c[2];
    auto const& c4 = cache.halfBuffer.c[3];

    for (int col = 0; col < disc.mesh_res_x; ++col) {
        size_t const l_col = std::max<int>(col - 1, 0);
        size_t const r_col = std::min<int>(col + 1, disc.mesh_res_x - 1);

        for (int row = 0; row < disc.mesh_res_y; ++row) {
            cache.ySweepRHSBuffer(row, col) =
                (1 - 2 * mu_x) * c(row, col) +
                mu_x * (c(row, l_col) + c(row, r_col)) +
                c1(row, col) * (mu_1 * c2(row, col) + mu_2 * c3(row, col) +
                                   mu_3 * c4(row, col));
        }
    }

    cache.ySweepMats[mat].solve(disc.mesh_res_x, cache.ySweepRHSBuffer.data());
    xt::noalias(state.solution.c[mat]) = cache.ySweepRHSBuffer;
}

}  // namespace yag_model