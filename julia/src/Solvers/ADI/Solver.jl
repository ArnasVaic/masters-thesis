using LinearAlgebra
using Logging

struct ADISolver{TS<:TimeStep, B<:Brake, L<:AbstractLogger, C<:Capture}
    disc::Discretization
    rp::ReactionParameters
    ts::TS
    brake::B
    capture::C
    logger::L
end

ADISolver(disc, rp, ts, brake, capture; logger=current_logger()) =
    ADISolver(disc, rp, ts, brake, capture, logger)

function solve(solver::ADISolver, ic::SolutionState)

    with_logger(solver.logger) do
        @debug solver.brake

        state = init_solver_state(ic)

        capture!(solver.capture, state)

        cache = SolverCache(
            solver.disc,
            solver.rp,
            dt(solver.ts)
        )

        dt_cached = dt(solver.ts)

        w, h = solver.disc.resolution
        
        row_buffer = zeros(w)
        col_buffer = zeros(h)
        half = empty_solution_state(solver.disc.resolution)
        c1c2 = zeros(h, w)
        c1c3 = zeros(h, w)
        c1c4 = zeros(h, w)

        while !should_brake(solver.brake, state)

            dt_now = dt(solver.ts)

            if !isapprox(dt_now, dt_cached)
                dt_cached = dt_now
                update_cache!(cache, solver.rp, solver.disc, dt_now)
            end

            solve_step!(dt_now, state, cache, half, c1c2, c1c3, c1c4, row_buffer, col_buffer)

            update_dt!(solver.ts, state)

            capture!(solver.capture, state)

        end
    end

    return nothing
end

function solve_step!(
        dt::Float64,
        state::SolverState,
        cache::SolverCache,
        half_buffer::SolutionState,
        u1u2::Matrix{Float64},
        u1u3::Matrix{Float64},
        u1u4::Matrix{Float64},
        row_buffer::Vector{Float64},
        col_buffer::Vector{Float64}
    )::Nothing

    # use u because c is used for column index
    u1, u2, u3, u4, _ = state.c
    u1_h, u2_h, u3_h, u4_h, _ = half_buffer
    h, w = size(u1)

    u1u2 .= u1 .* u2
    u1u3 .= u1 .* u3
    u1u4 .= u1 .* u4

    mu_m = cache.mu.mat

    @inbounds for mat in 1:5

        # u - current timestep solution
        u = state.c[mat]

        # u_h - solution after half step 
        u_h = half_buffer[mat]

        # precomputed diffusion term coeficients 
        mu_y = cache.mu.y[mat]

        # x sweep
        @views for r in 1:h
            rt, rb = min(r + 1, h), max(r - 1, 1)

            @inbounds for j in 1:w
                row_buffer[j] =
                    # Diffusion term
                    (1 - 2 * mu_y) * u[r, j] + mu_y * (u[rt, j] + u[rb, j]) +
                    # Reaction term
                    mu_m[mat, 1] * u1[r, j] * u2[r, j] +
                    mu_m[mat, 2] * u1[r, j] * u3[r, j] +
                    mu_m[mat, 3] * u1[r, j] * u4[r, j]
            end

            ldiv!(cache.Bx_fact[mat], row_buffer)

            u_h[r, :] .= row_buffer
        end
    end

    # use u as storage for next step solution
    u1u2 .= u1_h .* u2_h
    u1u3 .= u1_h .* u3_h
    u1u4 .= u1_h .* u4_h

    for mat in 1:5

        # u_h - solution after half step 
        u_h = half_buffer[mat]

        # u - next timestep solution
        u = state.c[mat]

        # precomputed diffusion term coeficients 
        mu_x = cache.mu.x[mat]

        # y sweep
        @views for c in 1:w 
            cl, cr = min(c + 1, w), max(c - 1, 1)

            @inbounds for i in 1:h
                col_buffer[j] =
                    # Diffusion term
                    (1 - 2mu_x) * u_h[i, c] + mu_x * (u_h[i, cl] + u_h[i, cr])
                    # Reaction term
                    + mu_m[mat, 1] * u1[i, c] * u2[i, c]
                    + mu_m[mat, 2] * u1[i, c] * u3[i, c]
                    + mu_m[mat, 3] * u1[i, c] * u4[i, c]
            end
        
            ldiv!(cache.By_fact[mat], col_buffer)

            u[:, c] .= col_buffer
        end
    end

    state.step += 1
    state.time += dt
    return nothing
end
