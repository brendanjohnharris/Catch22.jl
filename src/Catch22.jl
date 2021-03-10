module Catch22
using catch22_jll
using DimensionalData
using Libdl
using Statistics

include("features.jl")
include("testdata.jl")

catch22_jll.__init__() # Initialise the c-library

zscore(x⃗::AbstractVector{Float64}) = (x⃗ .- Statistics.mean(x⃗))./(Statistics.std(x⃗))




"""
    catch22(x⃗::AbstractArray{Float64}, fName::Symbol)
    catch22(fName::Symbol, x⃗::AbstractArray{Float64})
Evaluate the feature 'fName' on the time series 'x⃗'. If an array is supplied, features are calculated for its columns and returned as a Vector. See Catch22.features for a summary of the 22 available time series features.

# Examples
```julia-repl
x⃗ = Catch22.testData[:test]
catch22(x⃗, :DN_HistogramMode_5)
```
"""
function catch22(x⃗::AbstractVector{Float64}, fName::Symbol)::Float64
    if any(isinf.(x⃗)) || any(isnan.(x⃗))
        return NaN
    end
    x⃗ = zscore(x⃗)
    fType = featureTypes[fName]
    if fType <: AbstractFloat
        ccall(dlsym(dlopen(ccatch22), fName), Cdouble, (Ptr{Array{Cdouble}},Cint), x⃗, Int(size(x⃗)[1]))
    elseif fType <: Integer
        ccall(dlsym(dlopen(ccatch22), fName), Cint, (Ptr{Array{Cdouble}},Cint), x⃗, Int(size(x⃗)[1]))
    end
end
catch22(X::AbstractArray, fName::Symbol) = mapslices(x⃗ -> catch22(x⃗, fName), X, dims=[1]) # This is a little slower to run the full feature set on, so only included for completeness.


featureVector(F::Vector{Float64}, fNames::Vector{Symbol}) = DimArray(F, (Dim{:feature}(fNames),))
featureMatrix(F::Array{Float64, 2}, fNames::Vector{Symbol}) = DimArray(F, (Dim{:feature}(fNames), Dim{:timeseries}(1:size(F)[2])))

"""
    catch22(x⃗::Vector)
    catch22(X::Array)
Evaluate all features for a time series vector or the columns of an array.
Features are returned in a Dimensional Array, where array rows are annotated by feature names.

# Examples
```julia-repl
x⃗ = Catch22.testData[:test]
f⃗ = catch22(x⃗)

X = randn(100, 10)
F = catch22(X)
```
"""
catch22(x⃗::AbstractVector) = featureVector(catch22.((x⃗,), featureNames), featureNames)
catch22(X::AbstractArray) = featureMatrix(mapslices(catch22, X, dims=[1]), featureNames)
catch22(x⃗::AbstractVector, fNames::Vector{Symbol}) = featureVector(catch22.((x⃗,), fNames), fNames)
catch22(X::AbstractArray, fNames::Vector{Symbol}) = featureMatrix(mapslices(x->catch22(x, fNames), X, dims=[1]), fNames)

catch22(y, x) = catch22(x, y) # If you accidentally switch the inputs
export catch22



"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to 'catch22(...)'; specific features (such as DN_HistogramMode_5) can be evaluated with functions called by their names.

# Examples
```julia-repl
x⃗ = Catch22.testData[:test]
f = DN_HistogramMode_5(x⃗)
```
"""
DN_HistogramMode_5(x⃗::AbstractVector) = catch22(x⃗, :DN_HistogramMode_5)
# Do a feature manually for example
export DN_HistogramMode_5

# Then generate the rest
for fName = featureNames[2:end]
    eval(quote
        $fName(x⃗::AbstractVector) = catch22(x⃗, $(Meta.quot(fName))); export $fName
    end)
end

end
