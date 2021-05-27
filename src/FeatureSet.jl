using StatsBase
import Base.size, Base.getindex, Base.setindex!, Base.:+

abstract type AbstractFeatureSet <: AbstractVector{Function} end
export AbstractFeatureSet
struct FeatureSet <: AbstractFeatureSet
    features::Vector{AbstractFeature}
end

FeatureSet( methods::AbstractArray{Function},
            names=Symbol.(methods),
            keywords=fill("", length(methods)),
            descriptions=fill("", length(methods))) =
            FeatureSet(Feature.(methods, names, keywords, descriptions))

FeatureSet( methods::Function,
            names=Symbol(methods),
            keywords="",
            descriptions="") =
            FeatureSet([Feature(methods, names, keywords, descriptions)])

export FeatureSet

getfeatures(𝒇::FeatureSet) = 𝒇.features
getmethods(𝒇::FeatureSet)  = getmethod.(𝒇)
getnames(𝒇::FeatureSet)  = getname.(𝒇)
getkeywords(𝒇::FeatureSet)  = getkeywords.(𝒇)
getdescriptions(𝒇::FeatureSet)  = getdescriptions.(𝒇)
export getfeatures, getmethods, getnames, getkeywords, getdescriptions

size(𝒇::FeatureSet) = size(getfeatures(𝒇))

getindex(𝒇::FeatureSet, i::Int) = getfeatures(𝒇)[i]

function getindex(𝒇::FeatureSet, 𝐟::Vector{Symbol})
    i = [findfirst(x -> x == f, getnames(𝒇)) for f ∈ 𝐟]
    getindex(𝒇, i)
end

getindex(𝒇::FeatureSet, I) = getfeatures(𝒇)[I]

function getindex(𝒇::FeatureSet, f::Symbol)
    i = findfirst(x -> x == f, getnames(𝒇))
    getindex(𝒇, i)
end

function setindex!(𝒇::FeatureSet, f::Feature, i::Int)
    setindex!(𝒇.features, f, i)
    ()
end

function Base.:+(𝒇::FeatureSet, 𝒇′::FeatureSet)
    FeatureSet([vcat(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
end

Base.:\(𝒇::FeatureSet, 𝒇′::FeatureSet) = Base.setdiff(𝒇, 𝒇′)

(𝒇::FeatureSet)(x::AbstractVector) = FeatureVector([𝑓(x) for 𝑓 ∈ 𝒇])
(𝒇::FeatureSet)(X::AbstractArray) = FeatureVector(mapslices(𝒇, X; dims=1))
