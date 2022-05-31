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
    if any(isinf.(𝐱)) || any(isnan.(𝐱)) || length(𝐱) < 3
        return NaN
    end
    𝐱 = 𝐱 |> zscore |> Vector{Float64}
    fType = featuretypes[fName]
    if fType <: AbstractFloat
        ccall(dlsym(dlopen(ccatch22), fName), Cdouble, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
    elseif fType <: Integer
        ccall(dlsym(dlopen(ccatch22), fName), Cint, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
    end
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

end
