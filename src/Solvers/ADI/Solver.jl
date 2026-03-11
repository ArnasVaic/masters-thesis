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

        w = solver.disc.grid.width
        h = solver.disc.grid.height

        row_buffer = zeros(w)
        col_buffer = zeros(h)
        half = empty_solution_state(Size(w, h))
        c1c2 = zeros(h, w)

        while !should_brake(solver.brake, state)

            dt_now = dt(solver.ts)

            if !isapprox(dt_now, dt_cached)
                dt_cached = dt_now
                update_cache!(cache, solver.rp, solver.disc, dt_now)
            end

            solve_step!(dt_now, state, cache, half, c1c2, row_buffer, col_buffer)

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
        row_buffer::Vector{Float64},
        col_buffer::Vector{Float64}
    )::Nothing

    # use u because c is used for column index
    u1, u2, _ = state.c
    u1_h, u2_h = half_buffer[1], half_buffer[2]
    h, w = size(u1)

    u1u2 .= u1 .* u2

    # use @inbounds to avoid bounds checking
    for mat in 1:3
        u, u_h = state.c[mat], half_buffer[mat]
        mu_y, mu_m = cache.mu.y[mat], cache.mu.m[mat]

        # use @views to avoid allocating temporary storage
        @views for r in 1:h
            rt, rb = min(r + 1, h), max(r - 1, 1)
            @. row_buffer = (1 - 2mu_y) * u[r, :]
            + mu_y * (u[rt, :] + u[rb, :])
            + mu_m * u1u2[r, :]
            ldiv!(cache.Bx_fact[mat], row_buffer)

            # Swap the order of the half u_h shape is [w, h]
            u_h[:, r] .= row_buffer
        end
    end

    u1u2 .= u1_h .* u2_h

    for mat in 1:3
        u_new, u_h = state.c[mat], half_buffer[mat]
        mu_x, mu_m = cache.mu.x[mat], cache.mu.m[mat]
        @views for c in 1:w
            cl, cr = min(c + 1, w), max(c - 1, 1)
            @. col_buffer = (1 - 2mu_x) * u_h[:, c]
            + mu_x * (u_h[:, cl] + u_h[:, cr])
            + mu_m * u1u2[:, c]
            ldiv!(cache.By_fact[mat], col_buffer)
            u_new[:, c] .= col_buffer
        end
    end

    state.step += 1
    state.time += dt
    return nothing
end
