module catch22
using NamedArrays

include("features.jl")


"""
    catch1(x::AbstractVector{Float64}, f::Symbol)

Evaluate the feature 'f' on the time series 'x'

# Examples
```@repl
x = catch22.testData[:test]
catch1(x, ::DN_HistogramMode_5)
```
```@eval
x = catch22.testData[:test]
catch1(x, ::DN_HistogramMode_5)
```
"""
catch1(x::AbstractVector{Float64}, f::Symbol) = ccall(featurePointers[f],
                                                    Cdouble,
                                                    (Ptr{Array{Cdouble}},Cint),
                                                    x,
                                                    Int(size(x)[1]))
#catch1(x::Int, f::Symbol) = catch1(Float64.(x), f)



"""
    DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to 'catch1()'; specific features can be evaluated with functions called by their names

# Examples
```@repl
x = catch22.testData[:test]
CO_trev_1_num(x)
```
```@eval
x = catch22.testData[:test]
CO_trev_1_num(x)
```
"""

for f = featureNames
    eval(quote
        $f(x::AbstractVector{Float64}) = catch1(x, $(Meta.quot(f)))
    end)
end




function catch22_all(x::AbstractVector{Float64})
    f = NamedArray(catch1.((x,), featureNames))
    setnames!(f, String.(featureNames), 1)
    return f
end



function catch22_all(X::AbstractArray{Float64})
    F = mapslices(catch22_all, X, dims=[1])
end


end