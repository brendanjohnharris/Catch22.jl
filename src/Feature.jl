import Base.:(==)
import Base.show

abstract type AbstractFeature <: Function end
struct Feature <: AbstractFeature
    method::Function
    name::Symbol
    keywords::String
    description::String
    Feature(method::Function, name=Symbol(method), keywords="", description="") = new(method, name, keywords, description)
end
Feature(args...) = Feature{Float64}(args...)
export Feature

getmethod(𝑓::Feature)  = 𝑓.method
getname(𝑓::Feature)  = 𝑓.name
getkeywords(𝑓::Feature)  = 𝑓.keywords
getdescription(𝑓::Feature)  = 𝑓.description
export getmethod, getname, getkeywords, getdescription

(𝑓::Feature)(x::AbstractVector)  = getmethod(𝑓)(x)
(𝑓::Feature)(X::AbstractArray) = mapslices(getmethod(𝑓), X; dims=1)

Base.:(==)(𝑓::Feature, 𝑓′::Feature) = isequal(getname(𝑓), getname(𝑓′)) # We assume that any features with the same name are the same feature

Base.show(io::IO, 𝑓::AbstractFeature) = print(io, ":"*string(getname(𝑓)))
Base.show(io::IO, m::MIME"text/plain", 𝑓::AbstractFeature) = printstyled(io, ":"*string(getname(𝑓)), color=:light_blue)