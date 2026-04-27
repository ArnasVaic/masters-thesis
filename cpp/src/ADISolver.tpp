//
// Created by arnas on 4/24/2026.
//

#include "ADISolver.h"

namespace yag_model {

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
ADISolver<TimeStepPolicy, BrakePolicy, CapturePolicy>::ADISolver(
    Discretization const& disc, ModelParameters reactionParameters,
    TimeStepPolicy timeStepPolicy, BrakePolicy brakePolicy,
    CapturePolicy& capturePolicy)
    : disc(disc),
      params(std::move(reactionParameters)),
      timeStepPolicy(std::move(timeStepPolicy)),
      brakePolicy(std::move(brakePolicy)),
      capturePolicy(capturePolicy) {}

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
void ADISolver<TimeStepPolicy, BrakePolicy, CapturePolicy>::solve(
    SolutionState const& ic) {
  SolverState state(disc.mesh_res_y, disc.mesh_res_x);
  state.solution = ic;
  capturePolicy.capture(state);

  ADISolverCache cache(disc.mesh_res_y, disc.mesh_res_x);
  double cached_dt = timeStepPolicy.getTimestep();
  cache.update(params, disc, cached_dt);

  while (!brakePolicy.shouldBrake(state)) {
    double const current_dt = timeStepPolicy.getTimestep();

    if (std::abs(current_dt - cached_dt) > 1e-9) {
      cached_dt = current_dt;
      cache.update(params, disc, cached_dt);
    }

    solveStep(state, cache, cached_dt);
    timeStepPolicy.advance(state);
    capturePolicy.capture(state);
  }
}

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
void ADISolver<TimeStepPolicy, BrakePolicy, CapturePolicy>::solveStep(
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

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
void ADISolver<TimeStepPolicy, BrakePolicy, CapturePolicy>::xSweepStep(
    size_t const mat, SolverState const& state, ADISolverCache& cache) const {
  double const mu_y = cache.mu.y[mat];
  double const mu_1 = cache.reactionCoefficients(mat, 0);
  double const mu_2 = cache.reactionCoefficients(mat, 1);
  double const mu_3 = cache.reactionCoefficients(mat, 2);

  const auto& c = state.solution.c[mat];
  const auto& c1 = state.solution.c[0];
  const auto& c2 = state.solution.c[1];
  const auto& c3 = state.solution.c[2];
  const auto& c4 = state.solution.c[3];

  for (int row = 0; row < disc.mesh_res_y; ++row) {
    size_t const top_row = std::min<int>(row + 1, disc.mesh_res_y - 1);
    size_t const bot_row = std::max<int>(row - 1, 0);

    for (int col = 0; col < disc.mesh_res_x; ++col) {
      cache.rhsBuffer(row, col) =
          (1 - 2 * mu_y) * c(row, col) +
          mu_y * (c(top_row, col) + c(bot_row, col)) +
          c(row, col) *
              (mu_1 * c2(row, col) + mu_2 * c3(row, col) + mu_3 * c4(row, col));
    }
  }
  cache.xSweepMats[mat].solve(disc.mesh_res_y, cache.rhsBuffer.data());
  xt::noalias(cache.halfBuffer.c[mat]) = cache.rhsBuffer;
}

template <typename TimeStepPolicy, typename BrakePolicy, typename CapturePolicy>
void ADISolver<TimeStepPolicy, BrakePolicy, CapturePolicy>::ySweepStep(
    size_t const mat, SolverState& state, ADISolverCache& cache) const {
  double const mu_x = cache.mu.x[mat];
  double const mu_1 = cache.reactionCoefficients(mat, 0);
  double const mu_2 = cache.reactionCoefficients(mat, 1);
  double const mu_3 = cache.reactionCoefficients(mat, 2);

  auto const& c = cache.halfBuffer.c[mat];
  auto const& c1 = cache.halfBuffer.c[0];
  auto const& c2 = cache.halfBuffer.c[1];
  auto const& c3 = cache.halfBuffer.c[2];
  auto const& c4 = cache.halfBuffer.c[3];

  for (int col = 0; col < disc.mesh_res_x; ++col) {
    size_t const l_col = std::min<int>(col + 1, disc.mesh_res_x - 1);
    size_t const r_col = std::max<int>(col - 1, 0);

    for (int row = 0; row < disc.mesh_res_y; ++row) {
      cache.rhsBuffer(row, col) =
          (1 - 2 * mu_x) * c(row, col) +
          mu_x * (c(row, l_col) + c(row, r_col)) +
          c(row, col) *
              (mu_1 * c2(row, col) + mu_2 * c3(row, col) + mu_3 * c4(row, col));
    }
  }

  cache.ySweepMats[mat].solve(disc.mesh_res_x, cache.rhsBuffer.data());
  xt::noalias(state.solution.c[mat]) = cache.rhsBuffer;
}

}  // namespace yag_model