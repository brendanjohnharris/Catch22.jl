module Catch22
using catch22_jll
using DimensionalData
using Requires
using Reexport
using TimeseriesFeatures
using LinearAlgebra
import Statistics: mean, std, cov

@reexport using TimeseriesFeatures

include("metadata.jl")
include("testdata.jl")

# Each feature's index in the C library (catch22_feature_index), filled at load so a
# library whose names disagree with metadata.jl fails loudly instead of binding wrongly
const featureindex = Dict{Symbol, Cint}()

function __init__()
    catch22_jll.__init__()
    for names in (catch24_featurenames, short_catch24_featurenames), name in names
        i = ccall((:catch22_feature_index, libcatch22), Cint, (Cstring,), String(name))
        i < 0 && error("catch22_jll's libcatch22 has no feature named $name")
        featureindex[name] = i
    end

    return @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        @require Clustering = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5" begin
            @eval include("CovarianceImage.jl")
        end
    end
end

"""
    z_score(𝐱::AbstractVector{<:Real})
The z-score of `𝐱` as the C pipeline computes it (`catch22_zscore`), so that features of
the result are bit for bit those of `catch22_compute`. A constant series is returned
unchanged (the catch22 features are then NaN), and a series with NaN or Inf gives all NaN.
"""
function z_score(𝐱::AbstractVector{<:Real})
    z = Vector{Float64}(𝐱) # one copy, z-scored in place
    ccall(
        (:catch22_zscore, libcatch22), Cint, (Ptr{Cdouble}, Cint, Ptr{Cdouble}),
        z, length(z), z
    )
    return z
end
const zᶠ = Feature(z_score, :z_score, "𝐱 → (𝐱 - μ(𝐱))/σ(𝐱), as catch22_zscore", ["normalization"])

include("masks.jl")

# Feature `fName` of a series as given: no z-scoring and no masking
# (catch22_compute_feature_raw, which checks the input itself: NaN for NaN/Inf input and
# for a constant series). A NaN that the C pipeline would mask is flagged (masks.jl).
function _ccall(fName::Symbol)
    i = featureindex[fName]
    return function f(𝐱::AbstractVector{Float64})::Float64
        out = Ref{Cdouble}(NaN)
        status = ccall(
            (:catch22_compute_feature_raw, libcatch22), Cint,
            (Ptr{Cdouble}, Cint, Cint, Ref{Cdouble}), 𝐱, length(𝐱), i, out
        )
        v = out[]
        if status == 0 && isnan(v) && !isnan(maskvalue(fName, length(𝐱)))
            return maskednan(length(𝐱))
        end
        return v
    end
end

"""
    _catch22(𝐱::AbstractArray{Float64}, fName::Symbol)
    _catch22(fName::Symbol, 𝐱::AbstractArray{Float64})
Evaluate the feature `fName` on the single time series `𝐱`. See `Catch22.featuredescriptions` for a summary of the 22 available time series features. Time series with NaN or Inf values will produce NaN feature values.

# Examples
```julia
𝐱 = Catch22.testdata[:test]
Catch22._catch22(𝐱, :DN_HistogramMode_5)
```
"""
function _catch22(𝐱::AbstractVector, fName::Symbol)::Float64
    return _ccall(fName)(convert(Vector{Float64}, 𝐱))
end
function _catch22(X::AbstractMatrix, fName::Symbol)::Matrix{Float64}
    return mapslices(𝐱 -> _catch22(𝐱, fName), X, dims = [1])
end

const features = map(featurenames) do name
    function feature(𝐱::AbstractVector{<:Real})::Float64
        return _ccall(name)(convert(Vector{Float64}, 𝐱))
    end
end

"""
The set of Catch22 features without a preliminary z-score
"""
const catch22_raw = FeatureSet(features, featurenames, featuredescriptions, featurekeywords)

"""
    catch22(𝐱::Vector)
    catch22(X::Array)
    catch22[featurename::Symbol](X::Array)
Evaluate all features for a time series vector `𝐱` or the columns of an array `X`.
`catch22` is a FeatureSet, which means it can be indexed by feature names (as symbols) to return a subset of the available features.
`getnames(catch22)`, `getkeywords(catch22)` and `getdescriptions(catch22)` will also return feature names, keywords and descriptions respectively.
Features are returned in a `FeatureArray`, in which array rows are annotated by feature names. A `FeatureArray` can be converted to a regular array with `Array(F)`.

# Examples
```julia
𝐱 = Catch22.testdata[:test]
𝐟 = catch22(𝐱)

X = randn(100, 10)
F = catch22(X)
F = catch22[:DN_HistogramMode_5](X)
```
"""
const catch22 = SuperFeatureSet(
    features, featurenames, featuredescriptions,
    featurekeywords, zᶠ
)
export catch22

for f in featurenames
    eval(
        quote
            $f = catch22[$(Meta.quot(f))]
            export $f
        end
    )
end

"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to `catch22(:DN_HistogramMode_5](x)`.
All features, such as `DN_HistogramMode_5`, are exported as Features and can be evaluated by calling their names.

# Examples
```julia
𝐱 = Catch22.testdata[:test]
f = DN_HistogramMode_5(𝐱)
```
"""
DN_HistogramMode_5

# Special cases for DN_mean and DN_Spread_std, which shouldn't z_score the vector
_DN_mean(𝐱::AbstractVector{<:Real})::Float64 = convert(Vector{Float64}, 𝐱) |> _ccall(:DN_mean)
_DN_Spread_std(𝐱::AbstractVector{<:Real})::Float64 = convert(Vector{Float64}, 𝐱) |> _ccall(:DN_Spread_std)
const DN_mean = Feature(
    _DN_mean, :DN_mean, "Arithmetic mean of time-series values",
    ["distribution", "location", "raw"]
)
const DN_Spread_std = Feature(
    _DN_Spread_std, :DN_Spread_std,
    "Sample standard deviation of time-series values",
    ["distribution", "spread", "raw"]
)

"""
    catch24 isa FeatureSet
A feature set containing the mean (`DN_mean`) and standard deviation (`DN_Spread_std`) in addition to all `catch22` features. See [`catch22`](@ref).
"""
catch24 = catch22 + DN_mean + DN_Spread_std
export catch24, DN_mean, DN_Spread_std

# The catch22 v0.x names, as deprecated aliases of the renamed features
for (old, new) in zip(legacy_catch24_featurenames, catch24_featurenames)
    old == new && continue
    @eval Base.@deprecate_binding $old $new
end

"""
    c22
The Catch22 feature set with shortened names; see [`catch22`](@ref).
"""
c22 = SuperFeatureSet(
    features, short_featurenames,
    featuredescriptions, featurekeywords, zᶠ
)

"""
    c24
The Catch24 feature set with shortened names; see [`catch24`](@ref).
"""
c24 = c22 + Feature(_DN_mean, :mean, DN_mean.description, DN_mean.keywords) +
    Feature(_DN_Spread_std, :std, DN_Spread_std.description, DN_Spread_std.keywords)
export c22, c24

end
