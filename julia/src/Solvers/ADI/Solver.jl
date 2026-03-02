using LinearAlgebra

export solve, solve_step!

function solve(
        disc::Discretization,
        rp::ReactionParameters,
        ic::SolutionState,
        ts::TimeStep,
        brake::Brake
    )

    state = init_solver_state(ic)
    cache = SolverCache(disc, rp, dt(ts))
   
    dt_cached = dt(ts)

    # Buffers for intermediate computations
    row_buffer = zeros(w)
    col_buffer = zeros(h)
    half = empty_solution_state(Size(w, h))
    c1c2 = zeros(h, w)

    while !should_brake(brake, state)

        dt_now = dt(ts)
        if !isapprox(dt_now, dt_cached)
            dt_cached = dt_now
            update_cache!(cache, rp, disc, dt_now)
        end

        solve_step!(dt_now, state, mu, Bx_fact, By_fact, half, c1c2, row_buffer, col_buffer)

        update_dt!(ts, state)
    end

    return nothing
end

function solve_step!(
        dt::Float64,
        state::SolverState,
        mu::MuConstants,
        Bx_fact::BandedFactorization,
        By_fact::BandedFactorization,
        half_buffer::SolutionState,
        u1u2::Matrix{Float64},
        row_buffer::Vector{Float64},
        col_buffer::Vector{Float64}
    )::Nothing

    u1, u2, _ = state.curr
    u1_h, u2_h = half_buffer[1], half_buffer[2]
    w, h = last(axes(u1, 2)), last(axes(u1, 1))

    u1u2 .= u1 .* u2

    # use @inbounds to avoid bounds checking
    @inbounds for mat in 1:3
        u, u_h = state.curr[mat], half_buffer[mat]
        mu_y, mu_m = mu.y[mat], mu.m[mat]

        # use @views to avoid allocating temporary storage
        @views for r in 1:h
            rt, rb = min(r + 1, h), max(r - 1, 1)
            @. row_buffer = (1 - 2mu_y) * u[r, :] 
                + mu_y * (u[rt, :] + u[rb, :]) 
                + mu_m * u1u2[r, :]
            ldiv!(Bx_fact[mat], row_buffer)

            # Swap the order of the half u_h shape is [w, h]
            u_h[:, r] .= row_buffer
        end
    end

    u1u2 .= u1_h .* u2_h

    @inbounds for mat in 1:3
        u_new, u_h = state.next[mat], half_buffer[mat]
        mu_y, mu_m = mu.y[mat], mu.m[mat]
        @views for c in 1:w
            cl, cr = min(c + 1, w), max(c - 1, 1)
            @. col_buffer = (1 - 2mu_x) * u_h[:, c] 
                + mu_y * (u_h[:, cl] + u_h[:, cr]) 
                + mu_m * u1u2[:, c]
            ldiv!(By_fact[mat], col_buffer)
            u_new[:, c] .= col_buffer
        end
    end

    state.step += 1
    state.t += dt
    return nothing
end