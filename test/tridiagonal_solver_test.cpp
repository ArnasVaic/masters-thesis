#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <cmath>
#include <limits>
#include <numeric>
#include <random>
#include <stdexcept>
#include <vector>

#include "Core/TridiagonalLU.h"
#include "Core/TridiagonalSolver.h"

extern "C" {
// Dense LU with partial pivoting, an independent reference for the tridiagonal solves
void dgesv_(int* n, int* nrhs, double* A, int* lda, int* ipiv, double* B, int* ldb, int* info);
}

namespace {

using Vec = std::vector<double>;

struct Tridiagonal {
  Vec sub, diag, super;

  [[nodiscard]]
  size_t size() const {
    return diag.size();
  }
};

// Strictly diagonally dominant, non-symmetric, with mixed signs
Tridiagonal randomDominant(size_t const n, std::mt19937& rng) {
  std::uniform_real_distribution<double> off(-1.0, 1.0);
  std::uniform_real_distribution<double> margin(0.1, 2.0);
  std::bernoulli_distribution negative(0.5);

  Tridiagonal A{Vec(n - 1), Vec(n), Vec(n - 1)};
  for (size_t i = 0; i + 1 < n; ++i) {
    A.sub[i] = off(rng);
    A.super[i] = off(rng);
  }
  for (size_t i = 0; i < n; ++i) {
    double const left = i > 0 ? std::abs(A.sub[i - 1]) : 0.0;
    double const right = i + 1 < n ? std::abs(A.super[i]) : 0.0;
    double const d = left + right + margin(rng);
    A.diag[i] = negative(rng) ? -d : d;
  }
  return A;
}

// ADI sweep matrix I - mu L with Neumann boundaries, as built by ADISolverCache
Tridiagonal sweepMatrix(size_t const n, double const mu) {
  Tridiagonal A{Vec(n - 1, -mu), Vec(n, 1 + 2 * mu), Vec(n - 1, -mu)};
  A.diag.front() = 1 + mu;
  A.diag.back() = 1 + mu;
  return A;
}

yag_model::TridiagonalSolver factored(Tridiagonal const& A) {
  yag_model::TridiagonalSolver solver(A.size());
  solver.factor(A.sub, A.diag, A.super);
  return solver;
}

// Row-major n x m block of right-hand sides
Vec randomBlock(size_t const n, size_t const m, std::mt19937& rng) {
  std::uniform_real_distribution<double> value(-10.0, 10.0);
  Vec B(n * m);
  for (auto& b : B) {
    b = value(rng);
  }
  return B;
}

// Column j of a row-major n x m block
Vec column(Vec const& B, size_t const n, size_t const m, size_t const j) {
  Vec x(n);
  for (size_t i = 0; i < n; ++i) {
    x[i] = B[i * m + j];
  }
  return x;
}

Vec multiply(Tridiagonal const& A, Vec const& x) {
  size_t const n = A.size();
  Vec b(n);
  for (size_t i = 0; i < n; ++i) {
    b[i] = A.diag[i] * x[i];
    if (i > 0) {
      b[i] += A.sub[i - 1] * x[i - 1];
    }
    if (i + 1 < n) {
      b[i] += A.super[i] * x[i + 1];
    }
  }
  return b;
}

Vec denseSolve(Tridiagonal const& A, Vec b) {
  int n = static_cast<int>(A.size());
  Vec dense(A.size() * A.size(), 0.0);  // column-major
  for (size_t i = 0; i < A.size(); ++i) {
    dense[i * A.size() + i] = A.diag[i];
    if (i + 1 < A.size()) {
      dense[i * A.size() + i + 1] = A.sub[i];      // A(i+1, i)
      dense[(i + 1) * A.size() + i] = A.super[i];  // A(i, i+1)
    }
  }

  int nrhs = 1;
  int info = 0;
  std::vector<int> ipiv(A.size());
  dgesv_(&n, &nrhs, dense.data(), &n, ipiv.data(), b.data(), &n, &info);
  REQUIRE(info == 0);
  return b;
}

// Forward error a correct solver can promise for I - mu L: its condition number 1 + 4 mu times the
// machine epsilon, never below 1e-12. Only the unrealistically stiff mu go above the floor.
double sweepTolerance(double const mu) {
  return std::max(1e-12, (1 + 4 * mu) * std::numeric_limits<double>::epsilon());
}

double maxAbs(Vec const& v) {
  double m = 0.0;
  for (double const x : v) {
    m = std::max(m, std::abs(x));
  }
  return m;
}

double maxAbsDiff(Vec const& a, Vec const& b) {
  REQUIRE(a.size() == b.size());
  double m = 0.0;
  for (size_t i = 0; i < a.size(); ++i) {
    m = std::max(m, std::abs(a[i] - b[i]));
  }
  return m;
}

}  // namespace

TEST_CASE("Tridiagonal solver: hand-computed system", "[tridiagonal]") {
  // [4 1 0; 2 5 1; 0 3 6] x = b with x = (1, 2, 3)
  Tridiagonal const A{{2.0, 3.0}, {4.0, 5.0, 6.0}, {1.0, 1.0}};
  Vec B = multiply(A, {1.0, 2.0, 3.0});
  REQUIRE(B == Vec{6.0, 15.0, 24.0});

  factored(A).solve(B.data(), 1);

  REQUIRE(maxAbsDiff(B, {1.0, 2.0, 3.0}) < 1e-14);
}

TEST_CASE("Tridiagonal solver: one and two unknowns", "[tridiagonal]") {
  Vec one{6.0};
  factored({{}, {4.0}, {}}).solve(one.data(), 1);
  REQUIRE(one[0] == 1.5);

  // [2 1; 1 3] x = (5, 10) with x = (1, 3)
  Vec two{5.0, 10.0};
  factored({{1.0}, {2.0, 3.0}, {1.0}}).solve(two.data(), 1);
  REQUIRE(maxAbsDiff(two, {1.0, 3.0}) < 1e-14);
}

TEST_CASE("Tridiagonal solver: random dominant systems match dense LAPACK", "[tridiagonal]") {
  size_t const n = GENERATE(1, 2, 3, 7, 64, 257);
  size_t const m = GENERATE(1, 3, 8, 33);
  std::mt19937 rng(static_cast<unsigned>(1000 * n + m));

  Tridiagonal const A = randomDominant(n, rng);
  Vec const B = randomBlock(n, m, rng);

  Vec X = B;
  factored(A).solve(X.data(), m);

  for (size_t j = 0; j < m; ++j) {
    Vec const x = column(X, n, m, j);
    Vec const b = column(B, n, m, j);
    double const scale = std::max(1.0, maxAbs(x));

    INFO("n = " << n << ", m = " << m << ", column " << j);
    // Agrees with an independent solver...
    REQUIRE(maxAbsDiff(x, denseSolve(A, b)) < 1e-12 * scale);
    // ...and actually solves the system
    REQUIRE(maxAbsDiff(multiply(A, x), b) < 1e-12 * std::max(1.0, maxAbs(b)));
  }
}

TEST_CASE("Tridiagonal solver: columns are solved independently", "[tridiagonal]") {
  size_t const n = 50;
  size_t const m = 13;
  std::mt19937 rng(7);

  auto const solver = factored(randomDominant(n, rng));
  Vec const B = randomBlock(n, m, rng);

  Vec X = B;
  solver.solve(X.data(), m);

  // Solving the block at once must give exactly what solving each column alone gives
  for (size_t j = 0; j < m; ++j) {
    Vec x = column(B, n, m, j);
    solver.solve(x.data(), 1);
    REQUIRE(x == column(X, n, m, j));
  }
}

TEST_CASE("Tridiagonal solver: ADI sweep matrices match LAPACK dgttrs", "[tridiagonal]") {
  // From negligible to the extremely stiff mu of a mesh in metres with dimensionless D
  double const mu = GENERATE(1e-8, 1e-3, 0.5, 1.0, 37.5, 1e4, 1e7);
  size_t const n = GENERATE(2, 3, 40, 401);
  size_t const m = 17;
  std::mt19937 rng(static_cast<unsigned>(n));

  Tridiagonal const A = sweepMatrix(n, mu);
  Vec const B = randomBlock(n, m, rng);

  Vec X = B;
  factored(A).solve(X.data(), m);

  // dgttrs wants the right-hand sides as contiguous columns (column-major n x m)
  yag_model::TridiagonalLU lu(n);
  lu.dl = A.sub;
  lu.d = A.diag;
  lu.du = A.super;
  lu.factor();

  Vec Y(n * m);
  for (size_t i = 0; i < n; ++i) {
    for (size_t j = 0; j < m; ++j) {
      Y[j * n + i] = B[i * m + j];
    }
  }
  lu.solve(static_cast<int>(m), Y.data());

  INFO("n = " << n << ", mu = " << mu);
  for (size_t j = 0; j < m; ++j) {
    Vec const b = column(B, n, m, j);
    Vec const x = column(X, n, m, j);
    Vec const y(Y.begin() + static_cast<long>(j * n), Y.begin() + static_cast<long>((j + 1) * n));

    REQUIRE(maxAbsDiff(x, y) < sweepTolerance(mu) * std::max(1.0, maxAbs(y)));

    // Backward error stays at rounding level however stiff the matrix: x solves a system within
    // a few ulps of the given one, ||A x - b|| <= c eps (||A|| ||x|| + ||b||) with ||A|| = 1 + 4 mu
    double const backward = 1e-14 * ((1 + 4 * mu) * maxAbs(x) + maxAbs(b));
    REQUIRE(maxAbsDiff(multiply(A, x), b) < backward);
  }
}

TEST_CASE("Tridiagonal solver: ADI sweep matrices conserve the total", "[tridiagonal]") {
  // Rows and columns of I - mu L sum to one, so constants are fixed points and sums are kept,
  // which is what makes diffusion conserve mass
  double const mu = GENERATE(1e-3, 1.0, 1e3, 1e7);
  size_t const n = 101;
  size_t const m = 9;
  std::mt19937 rng(3);

  auto const solver = factored(sweepMatrix(n, mu));

  Vec constant(n * m, 2.5);
  solver.solve(constant.data(), m);
  REQUIRE(maxAbsDiff(constant, Vec(n * m, 2.5)) < sweepTolerance(mu) * 2.5);

  Vec const B = randomBlock(n, m, rng);
  Vec X = B;
  solver.solve(X.data(), m);

  INFO("mu = " << mu);
  for (size_t j = 0; j < m; ++j) {
    Vec const b = column(B, n, m, j);
    Vec const x = column(X, n, m, j);
    double const sum_b = std::accumulate(b.begin(), b.end(), 0.0);
    double const sum_x = std::accumulate(x.begin(), x.end(), 0.0);
    REQUIRE(std::abs(sum_x - sum_b) < 1e-11 * n * maxAbs(b));
  }
}

TEST_CASE("Tridiagonal solver: refactoring replaces the matrix", "[tridiagonal]") {
  std::mt19937 rng(11);
  Tridiagonal const first = randomDominant(30, rng);
  Tridiagonal const second = sweepMatrix(30, 4.0);
  Vec const B = randomBlock(30, 1, rng);

  yag_model::TridiagonalSolver solver(30);
  solver.factor(first.sub, first.diag, first.super);
  solver.factor(second.sub, second.diag, second.super);

  Vec x = B;
  solver.solve(x.data(), 1);
  REQUIRE(maxAbsDiff(x, denseSolve(second, B)) < 1e-12 * std::max(1.0, maxAbs(x)));
}

TEST_CASE("Tridiagonal solver: rejects invalid use", "[tridiagonal]") {
  REQUIRE_THROWS_AS(yag_model::TridiagonalSolver(0), std::invalid_argument);

  yag_model::TridiagonalSolver solver(3);
  Vec b{1.0, 2.0, 3.0};

  SECTION("solving before factoring") {
    REQUIRE_THROWS_AS(solver.solve(b.data(), 1), std::logic_error);
  }

  SECTION("wrong diagonal lengths") {
    REQUIRE_THROWS_AS(solver.factor(Vec(2), Vec(2), Vec(2)), std::invalid_argument);
    REQUIRE_THROWS_AS(solver.factor(Vec(3), Vec(3), Vec(2)), std::invalid_argument);
    REQUIRE_THROWS_AS(solver.factor(Vec(2), Vec(3), Vec(1)), std::invalid_argument);
  }

  SECTION("zero pivot") {
    // [1 1 0; 1 1 1; 0 1 1], second pivot is 1 - 1 * 1 = 0
    REQUIRE_THROWS_AS(
        solver.factor(Vec{1.0, 1.0}, Vec{1.0, 1.0, 1.0}, Vec{1.0, 1.0}), std::runtime_error
    );
    // A failed factorization leaves the solver unusable rather than half updated
    REQUIRE_THROWS_AS(solver.solve(b.data(), 1), std::logic_error);
  }

  SECTION("non-finite coefficients") {
    REQUIRE_THROWS_AS(
        solver.factor(Vec{1.0, 1.0}, Vec{NAN, 4.0, 4.0}, Vec{1.0, 1.0}), std::runtime_error
    );
  }
}
