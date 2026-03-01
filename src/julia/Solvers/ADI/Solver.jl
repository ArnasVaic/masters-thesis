struct MuConstants
    x::NTuple{3, Float64}
    y::NTuple{3, Float64}
    m::NTuple{3, Float64}
end

MuConstants(
    phys::PhysicalParameterConfig,
    disc::DiscretizationConfig,
    dt::Float64
) =
    MuConstants(
    map(a -> 0.5 * dt * phys.k * a .* dt, phys.alpha),
    map(d -> 0.5 * dt / disc.dx^2 .* d, phys.D),
    map(d -> 0.5 * dt / disc.dy^2 .* d, phys.D)
)

function init_banded!(
        Bx::NTuple{3, SymTridiagonal},
        By::NTuple{3, SymTridiagonal},
        mu::MuConstants
    )
    for i in 1:3
        Bx[i].dv .= 1 + 2 * mu.x[i]
        Bx[i].dv[1] = 1 + mu.x[i]
        Bx[i].dv[end] = 1 + mu.x[i]

        Bx[i].ev .= -mu.x[i]

        By[i].dv .= 1 + 2 * mu.y[i]
        By[i].dv[1] = 1 + mu.y[i]
        By[i].dv[end] = 1 + mu.y[i]

        By[i].ev .= -mu.y[i]
    end
    return
end

function solve(
        ic::SolutionState,
        ts::TimeStep
    )
    state = init_solver_state(ic)
    current_dt = dt(ts)
    while true
        # Check if dt needs to change and update banded matrices / constants
        if !isapprox(current_dt, dt(ts))

        end


        solve_step!()
    end
    return
end

function solve_step!()
end
