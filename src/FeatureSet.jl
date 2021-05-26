using StatsBase
import Base.union
import Base.intersect
import Base.setdiff
import Base.:\
import Base.size
import Base.getindex
import Base.setindex!
import Base.IndexStyle

struct FeatureSet <: Function
    features::Vector{Function}
    names::Vector{Symbol}
    keywords::Vector{String}
    descriptions::Vector{String}
end
export FeatureSet

getfeatures(𝒇::FeatureSet) = 𝒇.features
getnames(𝒇::FeatureSet) = 𝒇.names
getkeywords(𝒇::FeatureSet) = 𝒇.keywords
getdescriptions(𝒇::FeatureSet) = 𝒇.descriptions
export getfeatures, getnames, getkeywords, getdescriptions

FeatureSet(;features, names=Symbol.(features), keywords, descriptions) = FeatureSet(features, names, keywords, descriptions)

FeatureSet(features, keywords, descriptions) = FeatureSet(features, Symbol.(features), keywords, descriptions)

function Base.union(𝒇::FeatureSet, 𝒇′::FeatureSet)
    FeatureSet([union(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
end

function Base.intersect(𝒇::FeatureSet, 𝒇′::FeatureSet)
    FeatureSet([intersect(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
end

function Base.setdiff(𝒇::FeatureSet, 𝒇′::FeatureSet)
    FeatureSet([setdiff(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
end

Base.:\(𝒇::FeatureSet, 𝒇′::FeatureSet) = Base.setdiff(𝒇, 𝒇′)

size(𝒇::FeatureSet) = size(getfeatures(𝒇))

getindex(𝒇::FeatureSet, i::Int) = FeatureSet([getfeatures(𝒇)[i]], [getnames(𝒇)[i]], [getkeywords(𝒇)[i]], [getdescriptions(𝒇)[i]])
function getindex(𝒇::FeatureSet, f::Symbol)
    i = findfirst(x -> x == f, getnames(𝒇))
    getindex(𝒇, i)
end
function getindex(𝒇::FeatureSet, 𝐟::Vector{Symbol})
    i = [findfirst(x -> x == f, getnames(𝒇)) for f ∈ 𝐟]
    getindex(𝒇, i)
end
getindex(𝒇::FeatureSet, I) = FeatureSet(getfeatures(𝒇)[I], getnames(𝒇)[I], getkeywords(𝒇)[I], getdescriptions(𝒇)[I])
#getindex(𝒇::FeatureSet, i::Vararg{Int, 1})= FeatureSet(getfeatures(𝒇)[i], getnames(𝒇)[i], getkeywords(𝒇)[i], getdescriptions(𝒇)[i])

function setindex!(𝒇::FeatureSet, f::FeatureSet, i::Int)
    @assert length(f) == 1
    𝒇.features[i] = f.features[1]
    𝒇.featurenames[i] = f.featurenames[1]
    𝒇.keywords[i] = f.keywords[1]
    𝒇.descriptions[i] = f.descriptions[1]
    ()
end
# function setindex!(𝒇::FeatureSet, f::FeatureSet, I::Vararg{Int, N})
# end

IndexStyle(::FeatureSet) = IndexLinear()

# TODO Should probably optimise.
(𝒇::FeatureSet)(x::AbstractVector) = featureVector(vcat([f(x) for f ∈ getfeatures(𝒇)]...), getnames(𝒇))
(𝒇::FeatureSet)(X::AbstractArray{T, 2}) where {T} = featureMatrix(mapslices(𝒇, X; dims=1), getnames(𝒇))

catch2 = FeatureSet([StatsBase.mean, StatsBase.std], [:mean, :SD], ["", ""], ["", ""])
export catch2

catch24 = FeatureSet([x -> catch22.(𝐱, f) for f ∈ featureNames], featureNames, fill("", length(featureNames)), getindex.((features,), featureNames))
export catch24
