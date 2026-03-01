module YagModel

include("Types/Size.jl")
include("Types/SolutionState.jl")
include("InitialConditions/Checkerboard.jl")
include("Solvers/ADI/Solver.jl")
include("Solvers/ADI/SolverState.jl")
include("TimeStep/TimeStep.jl")
include("TimeStep/FixedStep.jl")

end
