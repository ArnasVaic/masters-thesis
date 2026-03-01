using LinearAlgebra


struct SolverConfig
    disc::DiscretizationConfig
    phys::PhysicalParameterConfig
end

abstract type FrameCapture end

struct EveryNFrames <: FrameCapture
    n::Int
    frames::NTuple{3, Vector{Matrix{Float64}}}
    counter::Int
end

struct ADISolver
    step::ConstantTimeStep
end




function solve_step!(
        cfg::SolverConfig,
        state::SolverState,
        dt::Float64,
        half::NTuple{3, Matrix{Float64}},

        Bx_fact::NTuple{3, LDLt{Float64, SymTridiagonal{Float64, Vector{Float64}}}},
        By_fact::NTuple{3, LDLt{Float64, SymTridiagonal{Float64, Vector{Float64}}}},
        mu::MuConstants
    )

    for material in 1:3

        mu_y = mu.y[material]
        mu_m = mu.m[material]

        c = state.curr[material] # current material
        c1, c2, c3 = state.curr # explicit materials

        for row in 1:state.disc.ny

            # Rows (indexes) directly above and below `row`
            rt, rb = min(row + 1, state.disc.ny - 1), min(row - 1, 1)

            rhs = @view half[material, row, :]
            rhs .= (1 - 2 * mu_y) * c[row, :]
            + mu_y * (c[rt, :] + c[rb, :])
            + mu_m * c1[row, :] * c2[:, row]

            # Store RHS in the place where we will have the solution
            @views half[material][row, :] .=
                (1 - 2 * mu_y) * c[:, row] +
                mu_y * (c[:, row_bot] + c[:, row_top]) +
                mu_m * c1[:, row] * c2[:, row]

            ldiv!(Bx_fact[material], half[material][:, row])

        end
    end

    return
end

function solve(
        cfg::SolverConfig,
        solver::ADISolver,
        ic::Matrix{Float64}
    )

    row_buf = similar(u[1, :])


    state = SolverState(ic, zeros(cfg.disc.nx, cfg.disc.ny), 0)
    half::NTuple{3, Matrix{Float64}}
    mu = MuConstants(cfg.phys, cfg.disc, step.dt)
    current_dt = solver.step.dt

    Bx = (
        SymTridiagonal(zeros(cfg.disc), zeros(cfg.disc.nx - 1)),
        SymTridiagonal(zeros(cfg.disc.nx), zeros(cfg.disc.nx - 1)),
        SymTridiagonal(zeros(cfg.disc.nx), zeros(cfg.disc.nx - 1)),
    )
    By = (
        SymTridiagonal(zeros(cfg.disc.ny), zeros(cfg.disc.ny - 1)),
        SymTridiagonal(zeros(cfg.disc.ny), zeros(cfg.disc.ny - 1)),
        SymTridiagonal(zeros(cfg.disc.ny), zeros(cfg.disc.ny - 1)),
    )

    Bx_fact = map(b -> factorize(b), Bx)
    By_fact = map(b -> factorize(b), By)

    while true

        if !isapprox(solver.step.dt, current_dt)
            mu = MuConstants(cfg.phys, cfg.disc, solver.step.dt)
            init_banded!(Bx, By, mu)
        end

        solve_step!()

        if should_stop()
            #
        end

    end

    return
end
