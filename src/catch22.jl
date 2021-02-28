module catch22
using catch22_jll
using Libdl
using NamedArrays
using Statistics

include("features.jl")
include("testdata.jl")

catch22_jll.__init__() # Initialise the c-library

zscore(x::AbstractVector{Float64}) = (x .- Statistics.mean(x))./(Statistics.std(x))

"""
    catch1(x::AbstractVector{Float64}, f::Symbol)

Evaluate the feature 'f' on the time series 'x'

# Examples
```julia-repl
x = catch22.testData[:test]
catch1(x, ::DN_HistogramMode_5)
```
"""
function catch1(x::AbstractVector{Float64}, fName::Symbol)
    if any(isinf.(x)) || any(isnan.(x))
        return NaN
    end
    x = zscore(x)
    fType = featureTypes[fName]
    if fType <: AbstractFloat
        ccall(dlsym(dlopen(ccatch22), fName), Cdouble, (Ptr{Array{Cdouble}},Cint), x, Int(size(x)[1]))
    elseif fType <: Integer
        ccall(dlsym(dlopen(ccatch22), fName), Cint, (Ptr{Array{Cdouble}},Cint), x, Int(size(x)[1]))
    end
end
catch1(fName::Symbol, x::AbstractVector) = catch1(x, fName)
#catch1(x::Int, f::Symbol) = catch1(Float64.(x), f)
export catch1



"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to 'catch1(...)'; specific features can be evaluated with functions called by their names

# Examples
```julia-repl
x = catch22.testData[:test]
DN_HistogramMode_5(x)
```
"""
DN_HistogramMode_5(x::AbstractVector) = catch1(x, :DN_HistogramMode_5)
# Do a feature manually for example
export DN_HistogramMode_5

# Then generate the rest
for fName = featureNames[2:end]
    eval(quote
        $fName(x::AbstractVector) = catch1(x, $(Meta.quot(fName))); export $fName
    end)
end




"""
    catch22_all(X::Union{Vector, Array})
Evaluate all features for a time series vector or the columns of the time series array.
Features are returned as a NamedArray, which behaves as a base array but has rows labelled with feature names.

# Examples
```julia-repl
x = catch22.testData[:test]
DN_HistogramMode_5(x)
```
"""
function catch22_all(x::AbstractVector)
    f = NamedArray(catch1.((x,), featureNames))
    setnames!(f, String.(featureNames), 1)
    return f
end
function catch22_all(X::AbstractArray)
    F = mapslices(catch22_all, X, dims=[1])
end
export catch22_all


end