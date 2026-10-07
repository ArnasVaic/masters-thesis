#pragma once

#include <vector>

extern "C" {

// factorization (ONCE)
void dgttrf_(int const* n, double* dl, double* d, double* du, double* du2, int* ipiv, int* info);

// solve (MANY TIMES)
void dgttrs_(
    char const* trans,
    int const* n,
    int const* nrhs,
    double const* dl,
    double const* d,
    double const* du,
    double const* du2,
    int const* ipiv,
    double* b,
    int const* ldb,
    int* info
);
}

namespace yag_model {

struct TridiagonalLU {
  int n;

  std::vector<double> dl;   // n-1
  std::vector<double> d;    // n
  std::vector<double> du;   // n-1
  std::vector<double> du2;  // n-2
  std::vector<int> ipiv;

  TridiagonalLU(size_t n);

  void factor();
  void solve(int nrhs, double* B);
};

}  // namespace yag_model
