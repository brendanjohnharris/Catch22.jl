module Catch22
using catch22_jll
using Libdl
using NamedArrays
using Statistics

include("features.jl")
include("testdata.jl")

catch22_jll.__init__() # Initialise the c-library


zscore(x::AbstractVector{Float64}) = (x .- Statistics.mean(x))./(Statistics.std(x))

"""
    catch22(x::AbstractVector{Float64}, f::Symbol)
    catch22(f::Symbol, x::AbstractVector{Float64})

Evaluate the feature 'f' on the time series 'x'

# Examples
```julia-repl
x = Catch22.testData[:test]
catch22(x, ::DN_HistogramMode_5)
```
"""
function catch22(x::AbstractVector{Float64}, fName::Symbol)
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
catch22(fName::Symbol, x::AbstractVector) = catch22(x, fName)
#catch22(x::Int, f::Symbol) = catch22(Float64.(x), f)



"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to 'catch22(...)'; specific features can be evaluated with functions called by their names

# Examples
```julia-repl
x = Catch22.testData[:test]
DN_HistogramMode_5(x)
```
"""
DN_HistogramMode_5(x::AbstractVector) = catch22(x, :DN_HistogramMode_5)
# Do a feature manually for example
export DN_HistogramMode_5

# Then generate the rest
for fName = featureNames[2:end]
    eval(quote
        $fName(x::AbstractVector) = catch22(x, $(Meta.quot(fName))); export $fName
    end)
end




"""
    catch22(X::Union{Vector, Array})
Evaluate all features for a time series vector or the columns of the time series array.
Features are returned as a NamedArray, which behaves as a base array but has rows labelled with feature names.

# Examples
```julia-repl
x = Catch22.testData[:test]
DN_HistogramMode_5(x)
```
"""
function catch22(x::AbstractVector)
    f = NamedArray(catch22.((x,), featureNames))
    setnames!(f, String.(featureNames), 1)
    return f
end
catch22(X::AbstractArray) = mapslices(catch22, X, dims=[1])
export catch22


end
