module Catch22
using catch22_jll
using DimensionalData
using Libdl
using Statistics

include("metadata.jl")
include("testdata.jl")
include("Feature.jl")
include("FeatureSet.jl")
include("FeatureArray.jl")

catch22_jll.__init__() # Initialise the c-library

zscore(𝐱::AbstractVector) = (𝐱 .- Statistics.mean(𝐱))./(Statistics.std(𝐱))

"""
    catch22(𝐱::AbstractArray{Float64}, fName::Symbol)
    catch22(fName::Symbol, 𝐱::AbstractArray{Float64})
Evaluate the feature 'fName' on the time series '𝐱'. If an array is supplied, features are calculated for its columns and returned as a Vector. See Catch22.features for a summary of the 22 available time series features.

# Examples
```julia-repl
𝐱 = Catch22.testData[:test]
catch22(𝐱, :DN_HistogramMode_5)
```
"""
function catch22(𝐱::AbstractVector, fName::Symbol)::Float64
    if any(isinf.(𝐱)) || any(isnan.(𝐱))
        return NaN
    end
    𝐱 = zscore(𝐱)
    𝐱 = convert(Vector{Float64}, 𝐱)
    fType = featuretypes[fName]
    if fType <: AbstractFloat
        ccall(dlsym(dlopen(ccatch22), fName), Cdouble, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
    elseif fType <: Integer
        ccall(dlsym(dlopen(ccatch22), fName), Cint, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
    end
end
function catch22(X::AbstractArray{Float64, 2}, fName::Symbol)::AbstractArray{Float64, 2}
    mapslices(𝐱 -> catch22(𝐱, fName), X, dims=[1])
end

for f = LinearIndices(featurenames)
    eval(quote
        fname = $(Meta.quot(featurenames[f])); $(featurenames[f]) = Feature(x -> catch22(x, fname), fname, featurekeywords[$f], featuredescriptions[$f]); export $(featurenames[f])
    end)
end

"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to 'catch22(...)'; specific features (such as DN_HistogramMode_5) can be evaluated by calling their names.

# Examples
```julia-repl
𝐱 = Catch22.testData[:test]
f = DN_HistogramMode_5(𝐱)
```
"""
DN_HistogramMode_5;



"""
    catch22(𝐱::Vector)
    catch22(X::Array)
Evaluate all features for a time series vector or the columns of an array.
Features are returned in a FeatureArray, where array rows are annotated by feature names.

# Examples
```julia-repl
𝐱 = Catch22.testData[:test]
𝐟 = catch22(𝐱)

X = randn(100, 10)
F = catch22(X)
```
"""
catch22_a = FeatureSet([(x -> catch22(x, f)) for f ∈ featurenames], featurenames, featurekeywords, featuredescriptions)
export catch22_a

end

