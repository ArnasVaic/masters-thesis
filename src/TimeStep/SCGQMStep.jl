mutable struct SCGQMStep <: TimeStep
    const steps::Int
    const multiplier::Float64
    const initial_dt::Float64
    const upper_bound::Float64
    const lower_bound::Float64
    current_dt::Float64

    function SCGQMStep(
        initial_dt::Float64,
        multiplier,::Float64,
        steps::Int,
        upper_bound::Float64,
        lower_bound::Float64
    )
        return new(
            steps,
            multiplier,
            initial_dt,
            upper_bound,
            lower_bound
            initial_dt
        )
    end

end

dt(ts::SCGQMStep)::Float64 =
    throw(ErrorException("dt not implemented for $(typeof(ts))"))

update_dt!(ts::TimeStep, _::SolverState)::Nothing =
    throw(ErrorException("update! not implemented for $(typeof(ts))"))
