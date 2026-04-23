struct ReactionParameters

    D::NTuple{5, Float64}
    k::NTuple{3, Float64}

    function ReactionParameters(
            D::NTuple{5, Float64},
            k::NTuple{3, Float64}
        )
        all(D .>= 0) || error("All diffusion coefficients must not be negative")
        all(k .>= 0) || error("Reaction speed constant must be non negative")
        new(D, k)
    end
end

# Constructors for parameters according to a paper by A. Kareiva, 
# F. Ivanauskas and M. Mackevičius where they calculated physical
# parameters based on the data points they had for different
# reaction temperatures.
#
# doi.org/10.1007%2Fs10910-012-0031-9
#

ReactionParameters(::Val{1000}) = 
    ReactionParameters((10.5e-6, 10.5e-6, 10.5e-6, 10.5e-6, 0.0), (119.0, 119.0, 119.0))

ReactionParameters(::Val{1200}) = 
    ReactionParameters((15e-6, 15e-6, 15e-6, 15e-6, 0.0), (146.0, 40.0, 40.0))

ReactionParameters(::Val{1600}) = 
    ReactionParameters((28e-6, 28e-6, 14e-6, 14e-6, 0.0), (192.0, 50.0, 50.0))
