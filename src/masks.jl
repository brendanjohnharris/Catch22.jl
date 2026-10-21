# catch22's C pipeline can replace a NaN that a feature gives for a valid series (short or
# constant, say) by a per-feature mask value, which may depend on the series length
# (catch22_mask_value). Catch22.jl computes without masks and instead flags such a NaN:
# the quiet NaN's payload carries a flag bit and the series length, so the mask can be
# applied later, to any array holding the value, with no need for the series. The payload
# survives storage, slicing, arithmetic and binary IO, but not conversion to text
# (nor Float32, which keeps the flag but not the length).
const MASKBIT = 0x0004_0000_0000_0000 # payload bit 50; bits 0 to 49 hold the length
const MASKLENGTH = 0x0003_ffff_ffff_ffff
const QUIETNAN = 0x7ff8_0000_0000_0000

maskednan(n::Integer) = reinterpret(Float64, QUIETNAN | MASKBIT | (UInt64(n) & MASKLENGTH))

"""
    ismasked(x)
Whether `x` is a NaN that catch22's C pipeline would have replaced by the feature's mask
value: a feature value of a valid (finite) series that the feature could not compute, as
opposed to the NaN that a series containing NaN or Inf gives. See [`applymask`](@ref).
"""
ismasked(x::Float64) = isnan(x) && (reinterpret(UInt64, x) & MASKBIT) != 0
ismasked(::Real) = false

"""
    masklength(x)
The length of the series that gave the flagged NaN `x` (see [`ismasked`](@ref)).
"""
masklength(x::Float64) = Int(reinterpret(UInt64, x) & MASKLENGTH)

"""
    maskvalue(name::Symbol, n::Integer)
The value catch22 gives feature `name` (long or short) when it cannot be computed for a
series of length `n` (`catch22_mask_value`); NaN for the mean and standard deviation.
"""
maskvalue(name::Symbol, n::Integer) = ccall(
    (:catch22_mask_value, libcatch22), Cdouble, (Cint, Cint), featureindex[name], n
)

"""
    applymask(F::AbstractFeatureArray)
    applymask(x::Real, name::Symbol)
`F` with each flagged NaN (see [`ismasked`](@ref)) replaced by its feature's mask value, as
`catch22_compute` would have returned it. Works on any slice or combination of feature
arrays, as the flag carries the series length.
"""
function applymask(F::AbstractFeatureArray)
    names = getnames(F)
    G = copy(F)
    for I in CartesianIndices(G)
        x = G[I]
        ismasked(x) && (G[I] = maskvalue(names[I[1]], masklength(x)))
    end
    return G
end
applymask(x::Real, name::Symbol) = ismasked(x) ? maskvalue(name, masklength(x)) : x

export ismasked, masklength, applymask
