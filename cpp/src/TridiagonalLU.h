//
// Created by arnas on 4/25/2026.
//

#ifndef YAG_MODEL_TRIDIAGONALLU_H
#define YAG_MODEL_TRIDIAGONALLU_H

#include <vector>
#include <stdexcept>

extern "C" {

// LAPACK tridiagonal factorization
void dgtrf_(int* n,
            double* dl,
            double* d,
            double* du,
            double* du2,
            int* ipiv,
            int* info);

// LAPACK tridiagonal solve
void dgtrs_(char* trans,
            int* n,
            int* nrhs,
            double* dl,
            double* d,
            double* du,
            double* du2,
            int* ipiv,
            double* b,
            int* ldb,
            int* info);
}

namespace yag_model
{

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

}

#endif //YAG_MODEL_TRIDIAGONALLU_H
