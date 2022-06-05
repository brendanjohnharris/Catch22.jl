import Base: ==, show, hash

abstract type AbstractFeature <: Function end
export AbstractFeature

"""
    𝑓 = Feature(method::Function, name=Symbol(method), keywords="", description="")

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
struct Feature <: AbstractFeature
    method::Function
    name::Symbol
    keywords::Vector{String}
    description::String
    Feature(method::Function, name=Symbol(method), keywords=[""], description="") = new(method, name, keywords, description)
end
Feature(args...) = Feature{Float64}(args...)
export Feature

getmethod(𝑓::AbstractFeature) = 𝑓.method
getname(𝑓::AbstractFeature) = 𝑓.name
getnames(𝑓::AbstractFeature) = [𝑓.name]
getkeywords(𝑓::AbstractFeature) = 𝑓.keywords
getdescription(𝑓::AbstractFeature) = 𝑓.description
export getmethod, getname, getkeywords, getdescription

(𝑓::AbstractFeature)(x::AbstractVector)  = getmethod(𝑓)(x)
(𝑓::AbstractFeature)(X::AbstractArray) = mapslices(getmethod(𝑓), X; dims=1)
(𝑓::AbstractFeature)(X::AbstractDimArray) = FeatureArray(mapslices(getmethod(𝑓), X; dims=1), (Dim{:feature}([getname(𝑓)]), dims(X)[2:end]...))

# We assume that any features with the same name are the same feature
hash(𝑓::AbstractFeature, h::UInt) = hash(𝑓.name, h)
(==)(𝑓::AbstractFeature, 𝑓′::AbstractFeature) = hash(𝑓) == hash(𝑓′)

formatshort(𝑓::AbstractFeature) = ":"*string(getname(𝑓))*" "
show(𝑓::AbstractFeature) = print(formatshort(𝑓))
show(io::IO, 𝑓::AbstractFeature) = print(io, formatshort(𝑓))
show(io::IO, m::MIME"text/plain", 𝑓::AbstractFeature) = printstyled(io, formatshort(𝑓), color=:light_blue)
