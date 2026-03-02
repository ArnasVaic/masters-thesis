using LinearAlgebra

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
    half = empty_solution_state(disc.grid)
    c1c2 = zeros(w, h)

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
    u1_half, u2_half = half_buffer[1], half_buffer[2]
    w, h = last(axes(u1, 2)), last(axes(u1, 1))

    u1u2 .= u1 .* u2

    @inbounds for mat in 1:3
        
        mu_y, mu_m = mu.y[mat], mu.m[mat]
        Ay, Ax = 1 - 2mu_y, 1 - 2mu_x

        u = state.curr[mat]
        u_half = half_buffer[mat]
        u_new = state.next[mat]

        @views begin
            for r in 1:h
                rt, rb = min(r + 1, h), max(r - 1, 1)
                @. row_buffer = Ay * u[r, :] + mu_y * (u[rt, :] + u[rb, :]) + mu_m * u1u2[r, :]
                ldiv!(Bx_fact[mat], row_buffer)
                u_half[:, r] .= row_buffer
            end

            for c in 1:w
                cl, cr = min(c + 1, w), max(c - 1, 1)
                @. col_buffer = Ax * u_half[:, c] + mu_y * (u_half[:, cl] + u_half[:, cr]) + mu_m * u_half[:, c]
                ldiv!(By_fact[mat], col_buffer)
                u_new[:, c] .= col_buffer
            end
        end
    end

    state.step += 1
    state.t += dt
    return nothing
end