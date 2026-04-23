using LinearAlgebra

const BandedFactorization = NTuple{5, LDLt{Float64, SymTridiagonal{Float64, Vector{Float64}}}}

mutable struct SolverCache
    mu::MuConstants
    Bx::NTuple{5, SymTridiagonal}
    By::NTuple{5, SymTridiagonal}
    Bx_fact::BandedFactorization
    By_fact::BandedFactorization
end

function SolverCache(
        disc::Discretization,
        rp::ReactionParameters,
        dt::Float64
    )
    mu = MuConstants(rp, disc, dt)

    w, h = disc.resolution

    Bx = ntuple(_ -> SymTridiagonal(zeros(w), zeros(w - 1)), 5)
    By = ntuple(_ -> SymTridiagonal(zeros(h), zeros(h - 1)), 5)

    update_banded!(Bx, By, mu)

    Bx_fact = ntuple(i -> ldlt!(Bx[i]), 5)
    By_fact = ntuple(i -> ldlt!(By[i]), 5)

    return SolverCache(mu, Bx, By, Bx_fact, By_fact)
end

function update_banded!(
        Bx::NTuple{5, SymTridiagonal},
        By::NTuple{5, SymTridiagonal},
        mu::MuConstants
    )
    @inbounds for (b, mu) in zip(Bx, mu.x)
        set_tridiag!(b, mu)
    end
    return @inbounds for (b, mu) in zip(By, mu.y)
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
    cache.Bx_fact = ntuple(i -> ldlt!(cache.Bx[i]), 5)
    cache.By_fact = ntuple(i -> ldlt!(cache.By[i]), 5)

    @debug "Cache update"

    return nothing
end

function set_tridiag!(T::SymTridiagonal, val::Float64)
    T.dv .= 1 + 2val
    T.dv[1] = 1 + val
    T.dv[end] = 1 + val
    return T.ev .= -val
end
