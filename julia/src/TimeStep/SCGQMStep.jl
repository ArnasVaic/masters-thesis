mutable struct SCGQMStep <: TimeStep
    const steps::Int
    const multiplier::Float64
    const initial_dt::Float64
    const upper_bound::Float64
    const lower_bound::Float64
    const initial_q::Float64
    const threshold::Float64
    const disc::Discretization
    current_dt::Float64

    function SCGQMStep(
        initial_dt::Float64,
        multiplier::Float64,
        steps::Int,
        upper_bound::Float64,
        lower_bound::Float64,
        initial_q::Float64,
        threshold::Float64,
        disc::Discretization
    )
        return new(
            steps,
            multiplier,
            initial_dt,
            upper_bound,
            lower_bound,
            initial_q,
            threshold,
            disc,
            initial_dt
        )
    end

end

dt(ts::SCGQMStep)::Float64 = ts.current_dt

function update_dt!(ts::SCGQMStep, state::SolverState)::Nothing 
    if state.step % ts.steps != 0
        return
    end

    ts.current_dt = min(
        ts.current_dt * ts.multiplier, 
        ts.upper_bound
    )

    q = reagent_quantity(state.c, ts.disc)
    if q / ts.initial_q <= ts.threshold
        ts.current_dt = ts.lower_bound
    end
end