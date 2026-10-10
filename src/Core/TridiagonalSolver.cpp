#include "TridiagonalSolver.h"

#include <cmath>
#include <stdexcept>
#include <string>

namespace yag_model {

TridiagonalSolver::TridiagonalSolver(size_t const n)
    : n(n), sub(n > 0 ? n - 1 : 0), inv_pivot(n), upper(n > 0 ? n - 1 : 0) {
  if (n == 0) {
    throw std::invalid_argument("Tridiagonal system must have at least one unknown");
  }
}

void TridiagonalSolver::factor(
    std::span<double const> const sub,
    std::span<double const> const diag,
    std::span<double const> const super
) {
  if (diag.size() != n || sub.size() != n - 1 || super.size() != n - 1) {
    throw std::invalid_argument(
        "Tridiagonal system of size " + std::to_string(n) +
        " needs n - 1 sub, n diagonal and n - 1 super entries"
    );
  }

  factored = false;

  for (size_t i = 0; i < n; ++i) {
    double const pivot = i == 0 ? diag[0] : diag[i] - sub[i - 1] * upper[i - 1];

    if (pivot == 0.0 || !std::isfinite(pivot)) {
      throw std::runtime_error(
          "Tridiagonal elimination broke down at row " + std::to_string(i) +
          ", the matrix must be diagonally dominant"
      );
    }

    inv_pivot[i] = 1.0 / pivot;

    if (i + 1 < n) {
      upper[i] = super[i] * inv_pivot[i];
      this->sub[i] = sub[i];
    }
  }

  factored = true;
}

void TridiagonalSolver::solve(double* const B, size_t const m) const {
  if (!factored) {
    throw std::logic_error("Tridiagonal solver used before factor()");
  }

  // Forward elimination: y_i = (b_i - sub_{i-1} y_{i-1}) / pivot_i
  {
    double const inv = inv_pivot[0];
    for (size_t j = 0; j < m; ++j) {
      B[j] *= inv;
    }
  }

  for (size_t i = 1; i < n; ++i) {
    double* const row = B + i * m;
    double const* const prev = B + (i - 1) * m;
    double const a = sub[i - 1];
    double const inv = inv_pivot[i];

    for (size_t j = 0; j < m; ++j) {
      row[j] = (row[j] - a * prev[j]) * inv;
    }
  }

  // Back substitution: x_i = y_i - upper_i x_{i+1}
  for (size_t i = n - 1; i-- > 0;) {
    double* const row = B + i * m;
    double const* const next = B + (i + 1) * m;
    double const u = upper[i];

    for (size_t j = 0; j < m; ++j) {
      row[j] -= u * next[j];
    }
  }
}

}  // namespace yag_model
