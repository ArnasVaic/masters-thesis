//
// Created by arnas on 4/25/2026.
//

#include "Core/TridiagonalLU.h"

#include <stdexcept>
#include <string>

namespace yag_model {
  TridiagonalLU::TridiagonalLU(size_t const n)
    : n(n), dl(n - 1), d(n), du(n - 1), du2(n - 2), ipiv(n) {
  }

  void TridiagonalLU::factor() {
    int info;

    dgttrf_(&n, dl.data(), d.data(), du.data(), du2.data(), ipiv.data(), &info);

    if (info != 0) {
      throw std::runtime_error("dgttrf failed with info = " +
                               std::to_string(info));
    }
  }

  void TridiagonalLU::solve(int nrhs, double *B) {
    char trans = 'N';
    int info;
    int ldb = n;

    dgttrs_(&trans, &n, &nrhs, dl.data(), d.data(), du.data(), du2.data(),
            ipiv.data(), B, &ldb, &info);

    if (info != 0) {
      throw std::runtime_error("dgttrs failed with info = " +
                               std::to_string(info));
    }
  }
} // namespace yag_model
