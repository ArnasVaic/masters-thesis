export FixedStep, dt, update!

struct FixedStep <: TimeStep
    dt::Float64
end

dt(ts::FixedStep)::Float64 = ts.dt

update!(_::FixedStep)::Nothing = nothing
