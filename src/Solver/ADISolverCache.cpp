//
// Created by arnas on 4/24/2026.
//

#include "Solver/ADISolverCache.h"

#include <xtensor/views/xview.hpp>
#include <xtensor-blas/xlinalg.hpp>

namespace yag_model
{
    ADISolverCache::ADISolverCache(
        size_t rows,
        size_t cols,
        xt::xarray<double> const& S)
        : xSweepMats(5, TridiagonalLU(cols)),
          ySweepMats(5, TridiagonalLU(rows)),
          xSweepRHSBuffer({cols, rows}, 0.0),
          ySweepRHSBuffer({rows, cols}, 0.0),
          S(S),
          R({5, 3}, 0.0),
          mu_x({5}, 0.0),
          mu_y({5}, 0.0),
          halfBuffer(rows, cols)
    {
    }

    void ADISolverCache::update(
        ModelParameters const& ps,
        Discretization const& disc,
        double const dt)
    {
        initializeR(ps, dt);
        initializeSweepMats(dt, ps, disc);
    }

    void ADISolverCache::initializeR(ModelParameters const& ps, double const dt)
    {
        R = 0.5 * dt * xt::linalg::dot(S, xt::diag(ps.K));
    }

    void ADISolverCache::initializeSweepMat(TridiagonalLU& tri, double const mu)
    {
        std::ranges::fill(tri.dl, -mu);

        std::ranges::fill(tri.d, 1 + 2 * mu);
        tri.d.front() = 1 + mu;
        tri.d.back() = 1 + mu;

        std::ranges::fill(tri.du, -mu);
    }

    void ADISolverCache::initializeSweepMats(
        double const dt,
        ModelParameters const& ps,
        Discretization const& disc)
    {
        mu_x = 0.5 * dt * ps.D / (disc.dx * disc.dx);
        mu_y = 0.5 * dt * ps.D / (disc.dy * disc.dy);

        for (size_t i = 0; i < xSweepMats.size(); ++i)
        {
            initializeSweepMat(xSweepMats[i], mu_x[i]);
            xSweepMats[i].factor();
        }

        for (size_t i = 0; i < ySweepMats.size(); ++i)
        {
            initializeSweepMat(ySweepMats[i], mu_y[i]);
            ySweepMats[i].factor();
        }
    }
} // namespace yag_model
