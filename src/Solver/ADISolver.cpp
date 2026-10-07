#include "ADISolver.h"

#include <limits>
#include <stdexcept>
#include <xtensor/core/xnoalias.hpp>

#include "ADISolverCache.h"

namespace yag_model {

void xSweepStep(size_t mat, SolverState& state, ADISolverCache& cache, int rows, int cols);

void ySweepStep(size_t mat, SolverState& state, ADISolverCache& cache, int rows, int cols);

void solveStep(Discretization const& disc, SolverState& state, ADISolverCache& cache, double dt);

static void validate(SolverConfig const& config, SolutionState const& ic) {
  Discretization const& disc = config.discretization;

  for (auto const& c : ic.c) {
    if (c.dimension() != 2 || c.shape(0) != disc.mesh_res_y || c.shape(1) != disc.mesh_res_x) {
      throw std::invalid_argument("Initial condition shape does not match discretization");
    }
  }

  auto const& S = config.stoichiometry;
  if (S.dimension() != 2 || S.shape(0) != 5 || S.shape(1) != 3) {
    throw std::invalid_argument("Stoichiometry matrix must have shape (5, 3)");
  }

  if (config.capture.channels == 0 || (config.capture.channels & ~ALL) != 0) {
    throw std::invalid_argument("Capture channels must be a non-empty subset of ALL");
  }

  if (!config.step || !config.brake || !config.capture.reducer || !config.capture.trigger ||
      !config.capture.sink) {
    throw std::invalid_argument("Solver config components must not be None");
  }
}

std::shared_ptr<IResult> solve(
    SolverConfig const& config, SolutionState const& ic, ModelParameters const& params
) {
  validate(config, ic);

  Discretization const& disc = config.discretization;
  ITimeStep& timeStep = *config.step;
  IBrake& brake = *config.brake;
  IReducer const& reducer = *config.capture.reducer;
  ITrigger& trigger = *config.capture.trigger;
  ISink& sink = *config.capture.sink;

  SolverState state(disc.mesh_res_y, disc.mesh_res_x);
  state.solution = ic;

  SolverContext const ctx{disc, ic};
  timeStep.begin(ctx);
  brake.begin(ctx);
  trigger.begin(ctx);

  std::vector<size_t> const channels = channelIndices(config.capture.channels);
  sink.begin({
      .frame_shape = reducer.frameShape(channels.size(), disc),
      .channels = config.capture.channels,
      .reducer = reducer.name(),
      .discretization = disc,
  });

  auto const capture = [&] {
    if (trigger.shouldCapture(state)) {
      sink.write(reducer.reduce(state.solution, channels, disc), state.time);
    }
  };

  state.is_final = brake.shouldBrake(state);
  capture();

  ADISolverCache cache(disc.mesh_res_y, disc.mesh_res_x, config.stoichiometry);

  // NaN compares unequal to everything, forces a cache update on the first step
  double cached_dt = std::numeric_limits<double>::quiet_NaN();

  while (!state.is_final) {
    double const dt = timeStep.advance(state);

    if (dt != cached_dt) {
      cached_dt = dt;
      cache.update(params, disc, cached_dt);
    }

    solveStep(disc, state, cache, cached_dt);

    state.is_final = brake.shouldBrake(state);
    capture();
  }

  return sink.finish();
}

void solveStep(
    Discretization const& disc, SolverState& state, ADISolverCache& cache, double const dt
) {
  size_t const matCount = state.solution.c.size();
  for (size_t mat = 0; mat < matCount; ++mat) {
    xSweepStep(
        mat, state, cache, static_cast<int>(disc.mesh_res_y), static_cast<int>(disc.mesh_res_x)
    );
  }

  for (size_t mat = 0; mat < matCount; ++mat) {
    ySweepStep(
        mat, state, cache, static_cast<int>(disc.mesh_res_y), static_cast<int>(disc.mesh_res_x)
    );
  }

  state.time += dt;
  state.step++;
}

void xSweepStep(
    size_t const mat, SolverState& state, ADISolverCache& cache, int const rows, int const cols
) {
  double const mu_y = cache.mu_y[mat];
  double const mu_1 = cache.R(mat, 0);
  double const mu_2 = cache.R(mat, 1);
  double const mu_3 = cache.R(mat, 2);

  auto const& c = state.solution.c[mat];
  auto const& c1 = state.solution.c[0];
  auto const& c2 = state.solution.c[1];
  auto const& c3 = state.solution.c[2];
  auto const& c4 = state.solution.c[3];

  for (int row = 0; row < rows; ++row) {
    size_t const top_row = std::min<int>(row + 1, rows - 1);
    size_t const bot_row = std::max<int>(row - 1, 0);

    for (int col = 0; col < cols; ++col) {
      // LAPACK can batch solve all lines at once but expects them
      // to be given as column vectors so even if were going line by
      // line we must write column by column to the rhsBuffer
      cache.xSweepRHSBuffer(col, row) =
          (1 - 2 * mu_y) * c(row, col) + mu_y * (c(top_row, col) + c(bot_row, col)) +
          c1(row, col) * (mu_1 * c2(row, col) + mu_2 * c3(row, col) + mu_3 * c4(row, col));
    }
  }
  cache.xSweepMats[mat].solve(rows, cache.xSweepRHSBuffer.data());
  xt::noalias(cache.halfBuffer.c[mat]) = xt::transpose(cache.xSweepRHSBuffer);
}

void ySweepStep(
    size_t const mat, SolverState& state, ADISolverCache& cache, int const rows, int const cols
) {
  double const mu_x = cache.mu_x[mat];
  double const mu_1 = cache.R(mat, 0);
  double const mu_2 = cache.R(mat, 1);
  double const mu_3 = cache.R(mat, 2);

  auto const& c = cache.halfBuffer.c[mat];
  auto const& c1 = cache.halfBuffer.c[0];
  auto const& c2 = cache.halfBuffer.c[1];
  auto const& c3 = cache.halfBuffer.c[2];
  auto const& c4 = cache.halfBuffer.c[3];

  for (int col = 0; col < cols; ++col) {
    size_t const l_col = std::max<int>(col - 1, 0);
    size_t const r_col = std::min<int>(col + 1, cols - 1);

    for (int row = 0; row < rows; ++row) {
      cache.ySweepRHSBuffer(row, col) =
          (1 - 2 * mu_x) * c(row, col) + mu_x * (c(row, l_col) + c(row, r_col)) +
          c1(row, col) * (mu_1 * c2(row, col) + mu_2 * c3(row, col) + mu_3 * c4(row, col));
    }
  }

  cache.ySweepMats[mat].solve(cols, cache.ySweepRHSBuffer.data());
  xt::noalias(state.solution.c[mat]) = cache.ySweepRHSBuffer;
}

}  // namespace yag_model