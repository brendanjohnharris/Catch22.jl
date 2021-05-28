import Base.size, Base.getindex, Base.setindex!, Base.:+

abstract type AbstractFeatureSet <: AbstractVector{Function} end
export AbstractFeatureSet
struct FeatureSet <: AbstractFeatureSet
    features::Vector{AbstractFeature}
    FeatureSet(features::Vector{T}) where {T <: AbstractFeature} = new(features)
end

FeatureSet( methods::AbstractArray,
            names=Symbol.(methods),
            keywords=fill([], length(methods)),
            descriptions=fill("", length(methods))) =
            FeatureSet(Feature.(methods, names, keywords, descriptions))

FeatureSet( methods::Function,
            names=Symbol(methods),
            keywords=[],
            descriptions="") =
            FeatureSet([Feature(methods, names, keywords, descriptions)])

export FeatureSet

getfeatures(𝒇::AbstractFeatureSet) = 𝒇.features
getmethods(𝒇::AbstractFeatureSet)  = getmethod.(𝒇)
getnames(𝒇::AbstractFeatureSet)  = getname.(𝒇)
getkeywords(𝒇::AbstractFeatureSet)  = getkeywords.(𝒇)
getdescriptions(𝒇::AbstractFeatureSet)  = getdescriptions.(𝒇)
export getfeatures, getmethods, getnames, getkeywords, getdescriptions

size(𝒇::AbstractFeatureSet) = size(getfeatures(𝒇))

getindex(𝒇::AbstractFeatureSet, i::Int) = getfeatures(𝒇)[i]

function getindex(𝒇::AbstractFeatureSet, 𝐟::Vector{Symbol})
    i = [findfirst(x -> x == f, getnames(𝒇)) for f ∈ 𝐟]
    getindex(𝒇, i)
end

getindex(𝒇::AbstractFeatureSet, I) = getfeatures(𝒇)[I]

function getindex(𝒇::AbstractFeatureSet, f::Symbol)
    i = findfirst(x -> x == f, getnames(𝒇))
    getindex(𝒇, i)
end

function setindex!(𝒇::AbstractFeatureSet, f::AbstractFeature, i::Int)
    setindex!(𝒇.features, f, i)
    ()
end

function Base.:+(𝒇::AbstractFeatureSet, 𝒇′::AbstractFeatureSet)
    FeatureSet([vcat(g(𝒇), g(𝒇′)) for g ∈ [ getfeatures,
                                            getnames,
                                            getkeywords,
                                            getdescriptions]]...)
end

Base.:\(𝒇::AbstractFeatureSet, 𝒇′::AbstractFeatureSet) = Base.setdiff(𝒇, 𝒇′)

(𝒇::AbstractFeatureSet)(x::AbstractVector) = FeatureVector([𝑓(x) for 𝑓 ∈ 𝒇], 𝒇)
(𝒇::AbstractFeatureSet)(X::AbstractArray) = FeatureVector(mapslices(𝒇, X; dims=1), 𝒇)
