module Catch22
using catch22_jll
using DimensionalData
using Libdl
using Statistics

include("features.jl")
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
    fType = featureTypes[fName]
    if fType <: AbstractFloat
        ccall(dlsym(dlopen(ccatch22), fName), Cdouble, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
    elseif fType <: Integer
        ccall(dlsym(dlopen(ccatch22), fName), Cint, (Ptr{Array{Cdouble}},Cint), 𝐱, Int(size(𝐱, 1)))
    end
end
function catch22(X::AbstractArray{Float64, 2}, fName::Symbol)::AbstractArray{Float64, 2}
    mapslices(𝐱 -> catch22(𝐱, fName), X, dims=[1])
end


"""
    catch22(𝐱::Vector)
    catch22(X::Array)
Evaluate all features for a time series vector or the columns of an array.
Features are returned in a Dimensional Array, where array rows are annotated by feature names.

# Examples
```julia-repl
𝐱 = Catch22.testData[:test]
𝐟 = catch22(𝐱)

X = randn(100, 10)
F = catch22(X)
```
"""
catch22(𝐱::AbstractVector) = featureVector(catch22.((𝐱,), featureNames), featureNames)
catch22(X::AbstractMatrix) = featureMatrix(mapslices(catch22, X, dims=[1]), featureNames)
catch22(𝐱::AbstractVector, fNames::Vector{Symbol}) = featureVector(catch22.((𝐱,), fNames), fNames)
catch22(X::AbstractMatrix, fNames::Vector{Symbol}) = featureMatrix(mapslices(x->catch22(x, fNames), X, dims=[1]), fNames)

catch22(y, x) = catch22(x, y) # If you accidentally switch the inputs
export catch22



"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to 'catch22(...)'; specific features (such as DN_HistogramMode_5) can be evaluated with functions called by their names.

# Examples
```julia-repl
𝐱 = Catch22.testData[:test]
f = DN_HistogramMode_5(𝐱)
```
"""
DN_HistogramMode_5(𝐱::AbstractVector) = catch22(𝐱, :DN_HistogramMode_5)
# Do a feature manually for example
export DN_HistogramMode_5

# Then generate the rest
for fName = featureNames[2:end]
    eval(quote
        $fName(𝐱::AbstractVector) = catch22(𝐱, $(Meta.quot(fName))); export $fName
    end)
end

end

