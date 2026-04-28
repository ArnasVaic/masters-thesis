//
// Created by arnas on 4/24/2026.
//

#include "ADISolverCache.h"

#include <xtensor/views/xview.hpp>

namespace yag_model {

ADISolverCache::ADISolverCache(size_t rows, size_t cols)
    : rhsBuffer({cols, rows}, 0.0),
      reactionCoefficients({5, 3}, 0.0),
      xSweepMats(5, TridiagonalLU(cols)),
      ySweepMats(5, TridiagonalLU(rows)),
      halfBuffer(rows, cols) {}

void ADISolverCache::update(ModelParameters const& params,
                            Discretization const& disc, double const dt) {
  initializeReactionCoefficients(params, dt);
  mu.initialize(disc, params, dt);
  initializeSweepMats();
}

void ADISolverCache::initializeReactionCoefficients(
    ModelParameters const& reactionParameters, double const dt) {
  const double k1 = reactionParameters.K[0];
  const double k2 = reactionParameters.K[1];
  const double k3 = reactionParameters.K[2];

  reactionCoefficients = {{-k1, -k2, -k3},
                          {-2.0 * k1, 0.0, 0.0},
                          {k1, -k2, 0.0},
                          {0.0, 4.0 * k2, -3.0 * k3},
                          {0.0, 0.0, k3}};

  // reactionCoefficients = {{-k1, 0.0, 0.0},
  //                         {-k1, 0.0, 0.0},
  //                         {2.0 * k1, 0.0, 0.0},
  //                         {0.0, 0.0, 0.0},
  //                         {0.0, 0.0, 0.0}};

  reactionCoefficients *= 0.5 * dt;
}

void ADISolverCache::initializeSweepMat(TridiagonalLU& tri, double const mu) {
  std::ranges::fill(tri.dl, -mu);
  tri.dl.back() = -2 * mu;

  std::ranges::fill(tri.d, 1 + 2 * mu);

  std::ranges::fill(tri.du, -mu);
  tri.du.front() = -2 * mu;
}
void ADISolverCache::initializeSweepMats() {
  for (size_t i = 0; i < xSweepMats.size(); ++i) {
    initializeSweepMat(xSweepMats[i], mu.x[i]);
    xSweepMats[i].factor();
  }

  for (size_t i = 0; i < ySweepMats.size(); ++i) {
    initializeSweepMat(ySweepMats[i], mu.y[i]);
    ySweepMats[i].factor();
  }
}

}  // namespace yag_model