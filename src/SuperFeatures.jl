@reexport module SuperFeatures

import ..getmethod
import ..Features: AbstractFeature, Feature
import ..FeatureSets: AbstractFeatureSet, FeatureSet, getmethods, getnames, getdescriptions, getkeywords
import ..FeatureArrays: FeatureVector, AbstractDimArray, _construct, _setconstruct

export SuperFeature,
    SuperFeatureSet

Base.@kwdef struct SuperFeature <: AbstractFeature
    method::Function
    name::Symbol = Symbol(method)
    description::String = ""
    keywords::Vector{String} = [""]
    super::AbstractFeature
end
SuperFeature(method::Function, name=Symbol(method), keywords::Vector{String}=[""], description::String=""; super::AbstractFeature) = SuperFeature(; super, method, name, keywords, description)
SuperFeature(method::Function, name, description::String, keywords::Vector{String}=[""]; super::AbstractFeature) = SuperFeature(; super, method, name, keywords, description)
getsuper(𝒇::SuperFeature) = 𝒇.super
getsuper(::AbstractFeature) = ()

(𝑓::SuperFeature)(x::AbstractVector) = x |> getsuper(𝑓) |> getmethod(𝑓)
(𝑓::SuperFeature)(X::AbstractDimArray) = _construct(𝑓, mapslices(getmethod(𝑓) ∘ getsuper(𝑓), X; dims=1))

struct SuperFeatureSet <: AbstractFeatureSet
    features::Vector{AbstractFeature}
    SuperFeatureSet(features::Vector{T}) where {T<:AbstractFeature} = new(features)
end

SuperFeatureSet(methods::AbstractVector{<:Function}, names::Vector{Symbol}, descriptions::Vector{String}, keywords, super) = SuperFeature.(methods, names, descriptions, keywords, super) |> SuperFeatureSet
SuperFeatureSet(methods::Function, args...) = [SuperFeature(methods, args...)] |> SuperFeatureSet
SuperFeatureSet(; methods, names, keywords, descriptions, super) = SuperFeatureSet(methods, names, keywords, descriptions, super)
SuperFeatureSet(f::AbstractFeature) = SuperFeatureSet([f])

# SuperFeatureSet(𝒇::Vector{Feature}) = SuperFeatureSet(getmethods(𝒇), getnames(𝒇), getdescriptions(𝒇), getkeywords(𝒇), getsuper(first(𝒇)))
getindex(𝒇::AbstractFeatureSet, I) = SuperFeatureSet(getfeatures(𝒇)[I])
SuperFeatureSet(𝒇::Vector{Feature}) = FeatureSet(𝒇) # Just a regular feature set

function (𝒇::SuperFeatureSet)(x::AbstractVector{<:Number})
    ℱ = getsuper.(𝒇) |> unique |> SuperFeatureSet
    supervals = ℱ(x)
    superloop(f::SuperFeature) = getmethod(f)(supervals[getsuper(f)])
    superloop(f::AbstractFeature) = f(x) # No superval lookup for regular features
    FeatureVector([superloop(𝑓) for 𝑓 ∈ 𝒇], 𝒇)
end

(𝒇::SuperFeatureSet)(X::AbstractDimArray) = _setconstruct(𝒇, X)

end # module
