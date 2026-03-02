module YagModel

include("Core/Size.jl")
include("Core/SolutionState.jl")

include("InitialConditions/Checkerboard.jl")

include("Core/Discretization.jl")
include("Core/ReactionParameters.jl")

include("Solvers/ADI/MuConstants.jl")
include("Solvers/ADI/SolverState.jl")

include("TimeStep/TimeStep.jl")
include("TimeStep/FixedStep.jl")

include("Brakes/Brake.jl")
include("Brakes/PQTBrake.jl")

include("Solvers/ADI/Cache.jl")

include("Solvers/ADI/Solver.jl")

# include("Test/solver_test.jl")

end
