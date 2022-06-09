module Catch22
using catch22_jll
using DimensionalData
using Libdl
using Requires
using LinearAlgebra
import Statistics: mean, std, cov

function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        @require Clustering="aaaa29a8-35af-508c-8bc3-b662a17a0fe5" begin
            @eval include("CovarianceImage.jl")
        end
    end
end

include("Feature.jl")
include("FeatureSet.jl")
include("FeatureArray.jl")
include("metadata.jl")
include("testdata.jl")
include("TimeseriesFeatures.jl")

catch22_jll.__init__() # Initialise the C library

zscore(𝐱::AbstractVector) = (𝐱 .- mean(𝐱))./(std(𝐱))
nancheck(𝐱::AbstractVector) = any(isinf.(𝐱)) || any(isnan.(𝐱)) || length(𝐱) < 3

function _ccall(fName::Symbol, ::Type{T}) where T<:Integer
    f(𝐱)::T = ccall(dlsym(dlopen(ccatch22), fName), Cint, (Ptr{Array{Cint}},Cint), 𝐱, Int(size(𝐱, 1)))
end
function _ccall(fName::Symbol, ::Type{T}) where T<:AbstractFloat
    f(𝐱)::T = ccall(dlsym(dlopen(ccatch22), fName), Cdouble, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
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
function _catch22(𝐱::AbstractVector, fName::Symbol)
    nancheck(𝐱) && return NaN
    𝐱 = 𝐱 |> zscore |> Vector{Float64}
    fType = featuretypes[fName]
    return _ccall(fName, fType)(𝐱)
end
function _catch22(X::AbstractArray{Float64, 2}, fName::Symbol)::AbstractArray{Float64, 2}
    mapslices(𝐱 -> _catch22(𝐱, fName), X, dims=[1])
end

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
catch22 = FeatureSet([(x -> _catch22(x, f)) for f ∈ featurenames], featurenames, featurekeywords, featuredescriptions)
export catch22


for f ∈ featurenames
    eval(quote
        $f = catch22[$(Meta.quot(f))]; export $f
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
DN_HistogramMode_5;

# Special cases for DN_Mean and DN_Spread_Std, and shouldn't standardize the vector
DN_Mean(𝐱::AbstractVector)::Float64 = nancheck(𝐱) ? NaN : (𝐱 |> _ccall(:DN_Mean, Cdouble))
DN_Spread_Std(𝐱::AbstractVector)::Float64 = nancheck(𝐱) ? NaN : (𝐱 |> _ccall(:DN_Spread_Std, Cdouble))
catch24 = catch22 + FeatureSet( [DN_Mean, DN_Spread_Std],
                                [:DN_Mean, :DN_Spread_Std],
                                [   ["distribution", "location", "raw"],
                                    ["distribution", "spread", "raw"]],
                                [   "Mean of time-series values",
                                    "Sample standard deviation of time-series values"])
export catch24, DN_Mean, DN_Spread_Std

"""
    catch24 isa FeatureSet
A feature set containing all `catch22` features, in addition to the mean (`DN_Mean`) and standard deviation (`DN_Spread_Std`). See `catch22`.
"""
catch24

end
