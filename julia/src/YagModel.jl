module YagModel

export Size
include("Types/Size.jl")
include("Types/SolutionState.jl")

include("InitialConditions/Checkerboard.jl")

include("Config/Discretization.jl")
include("Config/ReactionParameters.jl")

include("Solvers/ADI/MuConstants.jl")
include("Solvers/ADI/SolverState.jl")

include("TimeStep/TimeStep.jl")
include("TimeStep/FixedStep.jl")

include("Brakes/Brake.jl")
include("Brakes/PQTBrake.jl")

include("Solvers/ADI/Cache.jl")

include("Solvers/ADI/Solver.jl")

end
