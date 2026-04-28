//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_CACHE_H
#define YAG_MODEL_ADI_SOLVER_CACHE_H

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

  ADISolverCache(size_t rows, size_t cols);

  void update(ModelParameters const& params, Discretization const& disc,
              double const dt);

 private:
  void initializeReactionCoefficients(ModelParameters const& reactionParameters,
                                      double const dt);

  static void initializeSweepMat(TridiagonalLU& tri, double const mu);

  void initializeSweepMats();
};

}  // namespace yag_model

#endif  // YAG_MODEL_ADI_SOLVER_CACHE_H
