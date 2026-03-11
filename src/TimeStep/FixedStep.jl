struct FixedStep <: TimeStep
    dt::Float64
end

dt(ts::FixedStep)::Float64 = ts.dt

update_dt!(_::FixedStep, _::SolverState)::Nothing = nothing
