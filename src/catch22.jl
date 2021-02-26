module catch22
using catch22_jll

include(featureNames.jl)


# t = ccall((:DN_HistogramMode_5, catch22), Float64, (Array{Float64},Cint), a, 100)

"""
    catch1(x::Vector{Union{Float64, Int}}, f::Symbol)

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
catch1(x::Vector{Float64}, f::Symbol) = ccall((f, catch22),
                                                Float64,
                                                (Array{Float64},Cint),
                                                x,
                                                size(a)[1])
catch1(x::Int, f::Symbol) = catch1(Float64.(x), f)


# Give each feature a Julia function, called by its name
for f = featureNames
    eval(quote
        $f(x::Vector{Float64}) = catch1(x, f)
    end)
end

end
