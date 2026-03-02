export TimeStep, dt, update_dt!

abstract type TimeStep end

dt(ts::TimeStep)::Float64 =
    throw(ErrorException("dt not implemented for $(typeof(ts))"))

update_dt!(ts::TimeStep, _::SolverState)::Nothing =
    throw(ErrorException("update! not implemented for $(typeof(ts))"))
