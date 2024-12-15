module Catch22
using catch22_jll
using DimensionalData
using Libdl
using Requires
using Reexport
using TimeseriesFeatures
using LinearAlgebra
import Statistics: mean, std, cov

function __init__()
    catch22_jll.__init__()
    lib = dlopen(libcatch22)
    global fbindings = Dict{Symbol, Ptr{Cvoid}}(f => dlsym(lib, f)
                                                for f in catch24_featurenames)

    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        @require Clustering="aaaa29a8-35af-508c-8bc3-b662a17a0fe5" begin
            @eval include("CovarianceImage.jl")
        end
    end
end

@reexport using TimeseriesFeatures
import TimeseriesFeatures: zᶠ, z_score

include("metadata.jl")
include("testdata.jl")

nancheck(𝐱::AbstractVector) = length(𝐱) < 3 || any(isnan, 𝐱) || any(isinf, 𝐱)

function _ccall(fName::Symbol, ::Type{T}) where {T <: Integer}
    f(𝐱)::T = ccall(fbindings[fName], Cint, (Ptr{Cint}, Cint), 𝐱, length(𝐱))
end
function _ccall(fName::Symbol, ::Type{T}) where {T <: AbstractFloat}
    f(𝐱)::T = ccall(fbindings[fName], Cdouble, (Ptr{Cdouble}, Cint), 𝐱, length(𝐱))
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
    nancheck(𝐱) && return NaN
    # 𝐱 = 𝐱 |> Vector{Float64}
    fType = featuretypes[fName]
    return _ccall(fName, fType)(𝐱)
end
function _catch22(X::AbstractMatrix, fName::Symbol)::Matrix{Float64}
    mapslices(𝐱 -> _catch22(𝐱, fName), X, dims = [1])
end

const features = map(featurenames) do name
    T = featuretypes[name]
    function feature(𝐱::AbstractVector{<:Real})::Float64
        nancheck(𝐱) && return NaN
        _ccall(name, T)(convert(Vector{Float64}, 𝐱))
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
const catch22 = SuperFeatureSet(features, featurenames, featuredescriptions,
                                featurekeywords, zᶠ)
export catch22

for f in featurenames
    eval(quote
             const $f = catch22[$(Meta.quot(f))]
             export $f
         end)
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

# Special cases for DN_Mean and DN_Spread_Std, and shouldn't z_score the vector
_DN_Mean(𝐱::AbstractVector{<:Real})::Float64 = nancheck(𝐱) ? NaN :
                                               (convert(Vector{Float64}, 𝐱) |>
                                                _ccall(:DN_Mean, Cdouble))
_DN_Spread_Std(𝐱::AbstractVector{<:Real})::Float64 = nancheck(𝐱) ? NaN :
                                                     (convert(Vector{Float64}, 𝐱) |>
                                                      _ccall(:DN_Spread_Std, Cdouble))
const DN_Mean = Feature(_DN_Mean, :DN_Mean, "Arithmetic mean of time-series values",
                        ["distribution", "location", "raw"])
const DN_Spread_Std = Feature(_DN_Spread_Std, :DN_Spread_Std,
                              "Sample standard deviation of time-series values",
                              ["distribution", "spread", "raw"])

"""
    catch24 isa FeatureSet
A feature set containing the mean (`DN_Mean`) and standard deviation (`DN_Spread_Std`) in addition to all `catch22` features. See [`catch22`](@ref).
"""
catch24 = catch22 + DN_Mean + DN_Spread_Std
export catch24, DN_Mean, DN_Spread_Std

"""
    c22
The Catch22 feature set with shortened names; see [`catch22`](@ref).
"""
c22 = SuperFeatureSet(features, short_featurenames,
                      featuredescriptions, featurekeywords, zᶠ)

"""
    c24
The Catch24 feature set with shortened names; see [`catch24`](@ref).
"""
c24 = c22 + Feature(_DN_Mean, :mean, DN_Mean.description, DN_Mean.keywords) +
      Feature(_DN_Spread_Std, :std, DN_Spread_Std.description, DN_Spread_Std.keywords)
export c22, c24

end
