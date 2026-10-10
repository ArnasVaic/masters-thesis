#pragma once

#include "../Config/Discretization.h"
#include "../Config/ModelParameters.h"
#include "../Core/SolutionState.h"
#include "../Core/TridiagonalSolver.h"

namespace yag_model {
class ADISolverCache {
public:
  // X direction sweep matrix (I - mu_x,m L_W) (thesis paper. eq. 15.1)
  std::vector<TridiagonalSolver> xSweepMats;
  // Y direction sweep matrix (I - mu_y,m L_H) (thesis paper. eq. 15.2)
  std::vector<TridiagonalSolver> ySweepMats;
  // Stoichiometry matrix (thesis paper eq. 8)
  xt::xarray<double> S;
  // Reaction component coefficients (thesis paper eq. 14.x)
  xt::xarray<double> R;
  // mu constants (thesis paper. eq. 14.x)
  xt::xarray<double> mu_x, mu_y;
  // Half step solution c^*, stored transposed (cols x rows) so the x sweep solves its lines in
  // place and the y sweep reads it without a copy
  SolutionState halfBuffer;

  ADISolverCache(size_t rows, size_t cols, xt::xarray<double> const& S);

  void update(ModelParameters const& ps, Discretization const& disc, double dt);

private:
  void initializeR(ModelParameters const& ps, double dt);

  void initializeSweepMats(double dt, ModelParameters const& ps, Discretization const& disc);

  static void initializeSweepMat(TridiagonalSolver& tri, double mu);
};
}  // namespace yag_model
