@reexport module Features
using DimensionalData
import Base: ==, show, hash
export AbstractFeature,
    Feature,
    getmethod,
    getname,
    getkeywords,
    getdescription

abstract type AbstractFeature <: Function end

"""
    𝑓 = Feature([;] method::Function, name=Symbol(method), description="", keywords="")

Construct a `Feature`, which is a function annotated with a `name`, `keywords` and short `description`.
Features can be called as functions while `getname(𝑓)`, `getkeywords(𝑓)` and `getdescription(𝑓)` can be used to access the annotations.
The function should have at minimum a method for `AbstractVector`.
The method on vectors will be applied column-wise to `Matrix` inputs, regardless of the function methods defined for `Matrix`.

# Examples
```julia
𝑓 = Feature(sum, :sum, ["distribution"], "Sum of time-series values")
𝑓(1:10) # == sum(1:10) == 55
getdescription(𝑓) # "Sum of time-series values"
```
"""
Base.@kwdef struct Feature <: AbstractFeature
    method::Function
    name::Symbol = Symbol(method)
    description::String = ""
    keywords::Vector{String} = [""]
end
Feature(method::Function, name=Symbol(method), keywords::Vector{String}=[""], description::String="") = Feature(; method, name, keywords, description)
Feature(method::Function, name, description::String, keywords::Vector{String}=[""]) = Feature(; method, name, keywords, description)


getmethod(𝑓::AbstractFeature) = 𝑓.method
getname(𝑓::AbstractFeature) = 𝑓.name
getnames(𝑓::AbstractFeature) = [𝑓.name]
getkeywords(𝑓::AbstractFeature) = 𝑓.keywords
getdescription(𝑓::AbstractFeature) = 𝑓.description

(𝑓::AbstractFeature)(x::AbstractVector) = getmethod(𝑓)(x)
(𝑓::AbstractFeature)(X::AbstractArray) = mapslices(getmethod(𝑓), X; dims=1)

# We assume that any features with the same name are the same feature
hash(𝑓::AbstractFeature, h::UInt) = hash(𝑓.name, h)
(==)(𝑓::AbstractFeature, 𝑓′::AbstractFeature) = hash(𝑓) == hash(𝑓′)

commasep(x) = (y = fill(", ", 2 * length(x) - 1); y[1:2:end] .= x; y)
formatshort(𝑓::AbstractFeature) = [string(getname(𝑓)), " $(getdescription(𝑓))"]
formatlong(𝑓::AbstractFeature) = [string(typeof(𝑓)) * " ",
    string(getname(𝑓)),
    " with fields:\n",
    "description: ",
    getdescription(𝑓),
    "\n$(repeat(' ', 3))keywords: ",
    "$(commasep(getkeywords(𝑓))...)"]
show(𝑓::AbstractFeature) = print(formatlong(𝑓)...)
show(io::IO, 𝑓::AbstractFeature) = print(io, formatlong(𝑓)...)
function show(io::IO, m::MIME"text/plain", 𝑓::AbstractFeature)
    s = formatlong(𝑓)
    printstyled(io, s[1])
    printstyled(io, s[2], color=:light_blue, bold=true)
    printstyled(io, s[3])
    printstyled(io, s[4], color=:magenta)
    printstyled(io, s[5])
    printstyled(io, s[6], color=:yellow)
    printstyled(io, s[7])
end

end # module
