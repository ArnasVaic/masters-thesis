//
// Created by arnas on 4/25/2026.
//

#ifndef YAG_MODEL_TRIDIAGONAL_LU_H
#define YAG_MODEL_TRIDIAGONAL_LU_H

#include <vector>

extern "C" {

// factorization (ONCE)
void dgttrf_(int* n, double* dl, double* d, double* du, double* du2, int* ipiv,
             int* info);

// solve (MANY TIMES)
void dgttrs_(char* trans, int* n, int* nrhs, double* dl, double* d, double* du,
             double* du2, int* ipiv, double* b, int* ldb, int* info);
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

#endif  // YAG_MODEL_TRIDIAGONAL_LU_H
