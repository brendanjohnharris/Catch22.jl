@reexport module SuperFeatures

import ..getmethod
import ..Features: AbstractFeature, Feature
import ..FeatureSets: AbstractFeatureSet, FeatureSet
import ..FeatureArrays: FeatureVector

export  SuperFeature,
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


struct SuperFeatureSet <: AbstractFeatureSet
    features::Vector{AbstractFeature}
    SuperFeatureSet(features::Vector{T}) where {T <: AbstractFeature} = new(features)
end

SuperFeatureSet(methods::AbstractVector{<:Function}, args...) = SuperFeature.(methods, args...) |> FeatureSet
SuperFeatureSet(methods::Function, args...) = [SuperFeature(methods, args...)] |> SuperFeatureSet
SuperFeatureSet(; methods, names, keywords, descriptions) = SuperFeatureSet(methods, names, keywords, descriptions)
SuperFeatureSet(f::AbstractFeature) = SuperFeatureSet([f])
SuperFeatureSet(𝒇::Vector{Feature}) = FeatureSet(𝒇) # Just a regular feature set


function (𝒇::SuperFeatureSet)(x::AbstractVector)
    ℱ = getsuper.(𝒇) |> unique |> SuperFeatureSet
    supervals = ℱ(x)
    superloop(f::SuperFeature) = getmethod(f)(supervals[getsuper(f)])
    superloop(f::AbstractFeature) = f(x) # No superval lookup for regular features
    FeatureVector([superloop(𝑓) for 𝑓 ∈ 𝒇], 𝒇)
end

end # module
