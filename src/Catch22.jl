module Catch22
using catch22_jll
using DimensionalData
using Libdl
using Requires
using Reexport
using LinearAlgebra
import Statistics: mean, std, cov

function __init__()
    catch22_jll.__init__() # Initialise the C library
    lib = dlopen(ccatch22)
    # macro dlsym(lib, func)
    #     z = Ref{Ptr{Cvoid}}(C_NULL)
    #     quote
    #         let zlocal = $z[]
    #             if zlocal == C_NULL
    #                 zlocal = dlsym($(esc(lib))::Ptr{Cvoid}, $(esc(func)))::Ptr{Cvoid}
    #                 $z[] = zlocal
    #             end
    #             zlocal
    #         end
    #     end
    # end
    global fbindings = Dict{Symbol, Ptr{Cvoid}}(f => dlsym(lib, f) for f ∈ catch24_featurenames)

    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        @require Clustering="aaaa29a8-35af-508c-8bc3-b662a17a0fe5" begin
            @eval include("CovarianceImage.jl")
        end
    end
    @require StatsBase="2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91" begin
        @eval include("Autocorrelations.jl")
    end
end

include("Features.jl")
include("FeatureSets.jl")
include("FeatureArrays.jl")
include("SuperFeatures.jl")
include("metadata.jl")
include("testdata.jl")

z_score(𝐱::AbstractVector) = (𝐱 .- mean(𝐱))./(std(𝐱))
nancheck(𝐱::AbstractVector) = any(isinf.(𝐱)) || any(isnan.(𝐱)) || length(𝐱) < 3

function _ccall(fName::Symbol, ::Type{T}) where T<:Integer
    f(𝐱)::T = ccall(fbindings[fName], Cint, (Ptr{Array{Cint}},Cint), 𝐱, Int(size(𝐱, 1)))
end
function _ccall(fName::Symbol, ::Type{T}) where T<:AbstractFloat
    f(𝐱)::T = ccall(fbindings[fName], Cdouble, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
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
    𝐱 = 𝐱 |> Vector{Float64}
    fType = featuretypes[fName]
    return _ccall(fName, fType)(𝐱)
end
function _catch22(X::AbstractArray{Float64, 2}, fName::Symbol)::AbstractArray{Float64, 2}
    mapslices(𝐱 -> _catch22(𝐱, fName), X, dims=[1])
end

"""
The set of Catch22 features without a preliminary z-score
"""
catch22_raw = FeatureSet([(x -> _catch22(x, f)) for f ∈ featurenames], featurenames, featurekeywords, featuredescriptions)

zᶠ = Feature(Catch22.z_score, :z_score, ["normalization"], "𝐱 → (𝐱 - μ(𝐱))/σ(𝐱)")

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
catch22 = SuperFeatureSet([(x -> _catch22(x, f)) for f ∈ featurenames], featurenames, featuredescriptions, featurekeywords, zᶠ)
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

# Special cases for DN_Mean and DN_Spread_Std, and shouldn't z_score the vector
_DN_Mean(𝐱::AbstractVector)::Float64 = nancheck(𝐱) ? NaN : (𝐱 |> _ccall(:DN_Mean, Cdouble))
_DN_Spread_Std(𝐱::AbstractVector)::Float64 = nancheck(𝐱) ? NaN : (𝐱 |> _ccall(:DN_Spread_Std, Cdouble))
DN_Mean = Feature(_DN_Mean, :DN_Mean, ["distribution", "location", "raw"], "Arithmetic mean of time-series values")
DN_Spread_Std = Feature(_DN_Spread_Std, :DN_Spread_Std, ["distribution", "spread", "raw"], "Sample standard deviation of time-series values")

"""
    catch24 isa FeatureSet
A feature set containing the mean (`DN_Mean`) and standard deviation (`DN_Spread_Std`) in addition to all `catch22` features. See [`catch22`](@ref).
"""
catch24 = catch22 + DN_Mean + DN_Spread_Std
export catch24, DN_Mean, DN_Spread_Std


end
