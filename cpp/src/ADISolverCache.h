//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_CACHE_H
#define YAG_MODEL_ADI_SOLVER_CACHE_H
#include <xtensor.hpp>

#include "Discretization.h"
#include "ModelParameters.h"
#include "MuCoefficients.h"
#include "SolutionState.h"
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
      : rhsBuffer({cols, rows}, 0.0),
        reactionCoefficients({5, 3}, 0.0),
        xSweepMats(5, TridiagonalLU(cols)),
        ySweepMats(5, TridiagonalLU(rows)),
        halfBuffer(rows, cols) {}

  void update(ModelParameters const& params, Discretization const& disc,
              double const dt) {
    initializeReactionCoefficients(params, dt);
    mu.initialize(disc, params, dt);
    initializeSweepMats();
  }

 private:
  void initializeReactionCoefficients(ModelParameters const& reactionParameters,
                                      double const dt) {
    reactionCoefficients = {{-1.0, -1.0, -1.0},
                            {-2.0, 0.0, 0.0},
                            {1.0, -1.0, 0.0},
                            {0.0, 4.0, -3.0},
                            {0.0, 0.0, 1.0}};

    for (size_t i = 0; i < reactionParameters.K.size(); ++i) {
      auto col = xt::view(reactionCoefficients, xt::all(), i);
      col *= reactionParameters.K[i];
    }

    reactionCoefficients *= 0.5 * dt;
  }

  static void initializeSweepMat(TridiagonalLU& tri, double const mu) {
    std::ranges::fill(tri.dl, -mu);
    tri.dl.back() = -2 * mu;

    std::ranges::fill(tri.d, 1 + 2 * mu);

    std::ranges::fill(tri.du, -mu);
    tri.du.front() = -2 * mu;
  }

  void initializeSweepMats() {
    for (size_t i = 0; i < xSweepMats.size(); ++i) {
      initializeSweepMat(xSweepMats[i], mu.x[i]);
      xSweepMats[i].factor();
    }

    for (size_t i = 0; i < ySweepMats.size(); ++i) {
      initializeSweepMat(ySweepMats[i], mu.y[i]);
      ySweepMats[i].factor();
    }
  }
};

}  // namespace yag_model

#endif  // YAG_MODEL_ADI_SOLVER_CACHE_H
