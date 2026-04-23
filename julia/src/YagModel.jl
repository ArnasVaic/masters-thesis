module YagModel

include("Core/SolutionState.jl")
export SolutionState, empty_solution_state

include("Core/Discretization.jl")
export Discretization

include("Core/Quantity.jl")
export quantity, reagent_quantity

include("InitialConditions/Checkerboard.jl")
export build_checkerboard_ic

include("Core/ReactionParameters.jl")
export ReactionParameters

include("Core/SimpleFileLogger.jl")
export SimpleFileLogger

include("Solvers/ADI/MuConstants.jl")
export MuConstants

include("Solvers/ADI/SolverState.jl")
export SolverState, init_solver_state

include("Capture/Capture.jl")
export Capture, StrideCapture, NoCapture, capture!

include("TimeStep/TimeStep.jl")
export TimeStep, dt, update_dt!

include("TimeStep/FixedStep.jl")
export FixedStep

include("TimeStep/SCGQMStep.jl")
export SCGQMStep

include("Brakes/Brake.jl")
export Brake, should_brake

include("Brakes/RQTBrake.jl")
export RQTBrake, should_brake

include("Solvers/ADI/Cache.jl")
export BandedFactorization, SolverCache, update_cache!

include("Solvers/ADI/Solver.jl")
export solve, solve_step!, ADISolver

end
