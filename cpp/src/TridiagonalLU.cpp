//
// Created by arnas on 4/25/2026.
//

#include "TridiagonalLU.h"

namespace yag_model
{

TridiagonalLU::TridiagonalLU(size_t const n)
: n(n), dl(n), d(n), du(n), du2(n), ipiv(n)
{
}

inline void TridiagonalLU::factor()
{
    int info;

    dgtrf_(&n,
           dl.data(),
           d.data(),
           du.data(),
           du2.data(),
           ipiv.data(),
           &info);

    if (info != 0) {
        throw std::runtime_error("dgtrf failed with info = " + std::to_string(info));
    }
}

inline void TridiagonalLU::solve(int nrhs, double* B)
{
    char trans = 'N';
    int info;
    int ldb = n;

    dgtrs_(&trans,
           &n,
           &nrhs,
           dl.data(),
           d.data(),
           du.data(),
           du2.data(),
           ipiv.data(),
           B,
           &ldb,
           &info);

    if (info != 0) {
        throw std::runtime_error("dgtrs failed with info = " + std::to_string(info));
    }
}

}
