using StaticArrays

struct Discretization
    dx::Float64
    dy::Float64 
    size::SVector{2, Float64}
    resolution::SVector{2, Int}
    particle_count::SVector{2, Int}
    particle_resolution::SVector{2, Int}

    function Discretization(
        particle_count::SVector{2, Int},
        particle_resolution::SVector{2, Int}
    )
        # Compute total resolution
        resolution = particle_count .* particle_resolution

        # Single particle size should be 10 ^ (1/3) μm for a solid state 
        # reaction according to a paper by A. Kareiva, F. Ivanauskas and 
        # M. Mackevičius where they calculated physical parameters based 
        # on the data points they had for different reaction temperatures.
        #
        # doi.org/10.1007%2Fs10910-012-0031-9
        #
        # Based on this we can construct a discretization of the grid
        # based on how many particles there are and the resolution of a single particle
        size = 10^(1/3) .* particle_count

        sx, sy = size
        nx, ny = resolution

        @assert nx > 1 && ny > 1 "resolution must be > 1"
        dx = sx / (nx - 1)
        dy = sy / (ny - 1)

        @assert dx > 0 "dx must be > 0"
        @assert dy > 0 "dy must be > 0"

        return new(dx, dy, size, resolution, particle_count, particle_resolution)
    end

    Discretization(
        particle_count::Int,
        particle_resolution::Int
    ) = Discretization(
        SVector(particle_count, particle_count),
        SVector(particle_resolution, particle_resolution)
    )
end