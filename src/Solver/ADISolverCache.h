//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_ADI_SOLVER_CACHE_H
#define YAG_MODEL_ADI_SOLVER_CACHE_H

#include "../Config/Discretization.h"
#include "../Config/ModelParameters.h"
#include "../Core/SolutionState.h"
#include "../Core/TridiagonalLU.h"

namespace yag_model
{
    class ADISolverCache
    {
    public:
        // X direction sweep matrix (I - mu_x,m L_W) (thesis paper. eq. 15.1)
        std::vector<TridiagonalLU> xSweepMats;
        // Y direction sweep matrix (I - mu_y,m L_H) (thesis paper. eq. 15.2)
        std::vector<TridiagonalLU> ySweepMats;
        // Buffer for the RHS values in x sweep step (thesis paper. eq. 15.1)
        xt::xarray<double, xt::layout_type::column_major> xSweepRHSBuffer;
        // Buffer for the RHS values in x sweep step (thesis paper. eq. 15.2)
        xt::xarray<double, xt::layout_type::column_major> ySweepRHSBuffer;
        // Stoichiometry matrix (thesis paper eq. 8)
        xt::xarray<double> S;
        // Reaction component coefficients (thesis paper eq. 14.x)
        xt::xarray<double> R;
        // mu constants (thesis paper. eq. 14.x)
        xt::xarray<double> mu_x, mu_y;
        // Buffer to store the half step solution c^*
        SolutionState halfBuffer;

        ADISolverCache(
            size_t rows,
            size_t cols,
            xt::xarray<double> const& S
        );

        void update(
            ModelParameters const& ps,
            Discretization const& disc,
            double dt
        );

    private:
        void initializeR(ModelParameters const& ps, double dt);

        void initializeSweepMats(
           double dt,
           ModelParameters const& ps,
           Discretization const& disc
       );

        static void initializeSweepMat(TridiagonalLU& tri, double mu);
    };
} // namespace yag_model

#endif  // YAG_MODEL_ADI_SOLVER_CACHE_H
