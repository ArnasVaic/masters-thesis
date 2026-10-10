#include "Solver/ADISolverCache.h"

#include <xtensor-blas/xlinalg.hpp>
#include <xtensor/views/xview.hpp>

namespace yag_model {
ADISolverCache::ADISolverCache(size_t rows, size_t cols, xt::xarray<double> const& S)
    : xSweepMats(5, TridiagonalSolver(cols)),
      ySweepMats(5, TridiagonalSolver(rows)),
      S(S),
      R({5, 3}, 0.0),
      mu_x({5}, 0.0),
      mu_y({5}, 0.0),
      halfBuffer(cols, rows) {}

void ADISolverCache::update(
    ModelParameters const& ps, Discretization const& disc, double const dt
) {
  initializeR(ps, dt);
  initializeSweepMats(dt, ps, disc);
}

void ADISolverCache::initializeR(ModelParameters const& ps, double const dt) {
  R = 0.5 * dt * xt::linalg::dot(S, xt::diag(ps.k));
}

void ADISolverCache::initializeSweepMat(TridiagonalSolver& tri, double const mu) {
  size_t const n = tri.size();

  // Neumann boundaries: the mirrored ghost cell folds into the first and last diagonal entries
  std::vector<double> const off(n - 1, -mu);
  std::vector<double> diag(n, 1 + 2 * mu);
  diag.front() = 1 + mu;
  diag.back() = 1 + mu;

  tri.factor(off, diag, off);
}

void ADISolverCache::initializeSweepMats(
    double const dt, ModelParameters const& ps, Discretization const& disc
) {
  mu_x = 0.5 * dt * ps.D / (disc.dx * disc.dx);
  mu_y = 0.5 * dt * ps.D / (disc.dy * disc.dy);

  for (size_t i = 0; i < xSweepMats.size(); ++i) {
    initializeSweepMat(xSweepMats[i], mu_x[i]);
  }

  for (size_t i = 0; i < ySweepMats.size(); ++i) {
    initializeSweepMat(ySweepMats[i], mu_y[i]);
  }
}
}  // namespace yag_model
