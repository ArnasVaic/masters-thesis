#define CATCH_CONFIG_MAIN
#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>

extern "C" {
// LAPACK function for solving Ax = b
void dgesv_(int* n, int* nrhs, double* A, int* lda,
            int* ipiv, double* B, int* ldb, int* info);
}

TEST_CASE("LAPACK dgesv solves linear system", "[lapack]") {
    int n = 2;
    int nrhs = 1;
    int lda = 2;
    int ldb = 2;
    int info;

    // A = [3 1; 1 2]
    double A[4] = {
        3.0, 1.0,
        1.0, 2.0
    };

    // b = [9; 8]
    double B[2] = {9.0, 8.0};

    int ipiv[2];

    dgesv_(&n, &nrhs, A, &lda, ipiv, B, &ldb, &info);

    REQUIRE(info == 0);

    // Expected solution: x = [2; 3]

    REQUIRE_THAT(B[0], Catch::Matchers::WithinRel(2.0, 1e-9));
    REQUIRE_THAT(B[1], Catch::Matchers::WithinRel(3.0, 1e-9));
}