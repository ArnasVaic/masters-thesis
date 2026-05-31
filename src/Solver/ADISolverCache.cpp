//
// Created by arnas on 4/24/2026.
//

#include "Solver/ADISolverCache.h"

#include <xtensor/views/xview.hpp>

namespace yag_model {
ADISolverCache::ADISolverCache(size_t rows, size_t cols)
    : xSweepRHSBuffer({cols, rows}, 0.0),
      ySweepRHSBuffer({rows, cols}, 0.0),
      reactionCoefficients({5, 3}, 0.0),
      xSweepMats(5, TridiagonalLU(cols)),
      ySweepMats(5, TridiagonalLU(rows)),
      mu_x({5}, 0.0),
      mu_y({5}, 0.0),
      halfBuffer(rows, cols) {}

void ADISolverCache::update(ModelParameters const &params,
    Discretization const &disc,
    double const dt) {
    initializeReactionCoefficients(params, dt);
    initializeSweepMats(dt, params, disc);
}

void ADISolverCache::initializeReactionCoefficients(
    ModelParameters const &reactionParameters, double const dt) {
    const double k1 = reactionParameters.K[0];
    const double k2 = reactionParameters.K[1];
    const double k3 = reactionParameters.K[2];

    reactionCoefficients = {{-k1, -k2, -k3},
        {-2.0 * k1, 0.0, 0.0},
        {k1, -k2, 0.0},
        {0.0, 4.0 * k2, -3.0 * k3},
        {0.0, 0.0, k3}};

    // reactionCoefficients = {
    //   {-3.0 * k1, 0.0, 0.0},
    //   {-5.0 * k1, 0.0, 0.0},
    //   {2.0 * k1, 0.0, 0.0},
    //   {0.0, 0.0, 0.0},
    //   {0.0, 0.0, 0.0}
    // };

    reactionCoefficients *= 0.5 * dt;
}

void ADISolverCache::initializeSweepMat(TridiagonalLU &tri, double const mu) {
    // std::ranges::fill(tri.dl, -mu);
    // tri.dl.back() = -2.0 * mu;
    //
    // std::ranges::fill(tri.d, 1 + 2 * mu);
    // std::ranges::fill(tri.du, -mu);
    // tri.du.front() = -2.0 * mu;

    // Old tridiagonal structure with bad boundary
    std::ranges::fill(tri.dl, -mu);

    tri.d.front() = 1 + mu;
    tri.d.back() = 1 + mu;
    std::ranges::fill(tri.d, 1 + 2 * mu);

    std::ranges::fill(tri.du, -mu);
}

void ADISolverCache::initializeSweepMats(double const dt,
    ModelParameters const &params,
    Discretization const &disc) {
    mu_x = 0.5 * dt * params.D / (disc.dx * disc.dx);
    mu_y = 0.5 * dt * params.D / (disc.dy * disc.dy);

    for (size_t i = 0; i < xSweepMats.size(); ++i) {
        initializeSweepMat(xSweepMats[i], mu_x[i]);
        xSweepMats[i].factor();
    }

    for (size_t i = 0; i < ySweepMats.size(); ++i) {
        initializeSweepMat(ySweepMats[i], mu_y[i]);
        ySweepMats[i].factor();
    }
}
}  // namespace yag_model
