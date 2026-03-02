export BandedFactorization, SolverCache, update_cache!

const BandedFactorization = NTuple{3, LDLt{Float64, SymTridiagonal{Float64, Vector{Float64}}}}

mutable struct SolverCache
    mu::MuConstants,
    Bx::NTuple{3, SymTridiagonal}
    By::NTuple{3, SymTridiagonal}
    Bx_fact::BandedFactorization
    By_fact::BandedFactorization
end

function SolverCache(
    disc::Discretization, 
    rp::ReactionParameters, 
    dt::Float64)
    mu = MuConstants(rp, disc, dt)

    w, h = disc.grid.width, disc.grid.height

    Bx = ntuple(_ -> SymTridiagonal(zeros(w), zeros(w-1)), 3)
    By = ntuple(_ -> SymTridiagonal(zeros(h), zeros(h-1)), 3)

    update_banded!(Bx, By, mu)

    Bx_fact = ntuple(i -> ldlt!(Bx[i]), 3)
    By_fact = ntuple(i -> ldlt!(By[i]), 3)

    return new(mu, Bx, By, Bx_fact, By_fact)
end

function update_banded!(
        Bx::NTuple{3, SymTridiagonal},
        By::NTuple{3, SymTridiagonal},
        mu::MuConstants
    )
    @inbounds for (b, mu) in zip(Bx, mu.x)
        set_tridiag!(b, mu)
    end
    @inbounds for (b, mu) in zip(By, mu.y)
        set_tridiag!(b, mu)
    end
end

function update_cache!(
    cache::SolverCache,
    rp::ReactionParameters,
    disc::Discretization,
    dt::Float64
)
    cache.mu = MuConstants(rp, disc, dt)

    update_banded!(cache.Bx, cache.By, cache.mu)

    # MUST replace factorizations
    cache.Bx_fact = ntuple(i -> ldlt!(cache.Bx[i]), 3)
    cache.By_fact = ntuple(i -> ldlt!(cache.By[i]), 3)

    return nothing
end

function set_tridiag!(T::SymTridiagonal, val::Float64)
    T.dv .= 1 + 2val
    T.dv[1] = 1 + val
    T.dv[end] = 1 + val
    return T.ev .= -val
end