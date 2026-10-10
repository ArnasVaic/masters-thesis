#pragma once

#include <span>
#include <vector>

namespace yag_model {

// Solves A x = b for many right-hand sides sharing one tridiagonal matrix A with the Thomas
// algorithm. There is no pivoting, so A must be diagonally dominant (the ADI sweep matrices are).
//
// The right-hand sides are the columns of a row-major n x m block and are solved in place all at
// once: the elimination runs down the rows while the inner loop runs across the independent
// columns, so it has no dependency chain and vectorizes.
class TridiagonalSolver {
public:
  explicit TridiagonalSolver(size_t n);

  // LAPACK convention: sub[i] = A(i+1, i), diag[i] = A(i, i), super[i] = A(i, i+1)
  void factor(
      std::span<double const> sub, std::span<double const> diag, std::span<double const> super
  );

  // B is a row-major n x m block, column j holds the j-th right-hand side and receives its solution
  void solve(double* B, size_t m) const;

  [[nodiscard]]
  size_t size() const {
    return n;
  }

private:
  size_t n;

  // Kept from A: sub[i - 1] multiplies x_{i-1} in row i
  std::vector<double> sub;
  // 1 / pivot_i, pivot_i = diag_i - sub_{i-1} * upper_{i-1}
  std::vector<double> inv_pivot;
  // Upper diagonal of the normalized U factor, upper_i = super_i / pivot_i
  std::vector<double> upper;

  bool factored = false;
};

}  // namespace yag_model
