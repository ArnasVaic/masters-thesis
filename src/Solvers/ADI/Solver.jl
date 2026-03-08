using LinearAlgebra
using Logging

export solve, solve_step!

struct SimpleFileLogger <: AbstractLogger
    io::IO
end

Logging.shouldlog(logger::SimpleFileLogger, level, _module, group, id) = true
Logging.min_enabled_level(::SimpleFileLogger) = Logging.Debug
Logging.handle_message(logger::SimpleFileLogger, level, message, _module, group, id, file, line; kwargs...) =
    println(logger.io, message)

io = open("solver_debug.log", "w")
logger = SimpleFileLogger(io)
global_logger(logger)

function solve(
        disc::Discretization,
        rp::ReactionParameters,
        ic::SolutionState,
        ts::TimeStepType,
        brake::BrakeType
    ) where {TimeStepType <: TimeStep, BrakeType <: Brake}

    

    state = init_solver_state(ic)
    cache = SolverCache(disc, rp, dt(ts))

    dt_cached = dt(ts)
    w, h = disc.grid.width, disc.grid.height

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

        solve_step!(dt_now, state, cache, half, c1c2, row_buffer, col_buffer)

        update_dt!(ts, state)
        @debug "dt=$(dt), step=$(state.step)"

        if state.step == 7683
            println("a")
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
    w, h = last(axes(u1, 2)), last(axes(u1, 1))

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
