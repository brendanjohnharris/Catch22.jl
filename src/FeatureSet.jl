import Base.union
import Base.intersect
import Base.setdiff
import Base.:\
import Base.size

struct FeatureSet<: Function
    features::Vector{Function}
    keywords::Vector{String}
    descriptions::Vector{String}
end
export FeatureSet

getfeatures(𝐟::FeatureSet) = 𝐟.features
getnames(𝐟::FeatureSet) = Symbol.(getfeatures(𝐟))
getkeywords(𝐟::FeatureSet) = 𝐟.keywords
getdescriptions(𝐟::FeatureSet) = 𝐟.descriptions
export getfeatures, getnames, getkeywords, getdescriptions

FeatureSet(;features, keywords, descriptions) = FeatureSet(features, keywords, descriptions)

function Base.union(𝐟::FeatureSet, 𝐟′::FeatureSet)
    FeatureSet([union(g(𝐟), g(𝐟′)) for g ∈ [features, featurenames, keywords, descriptions]]...)
end

function Base.intersect(𝐟::FeatureSet, 𝐟′::FeatureSet)
    FeatureSet([intersect(g(𝐟), g(𝐟′)) for g ∈ [features, featurenames, keywords, descriptions]]...)
end

function Base.setdiff(𝐟::FeatureSet, 𝐟′::FeatureSet)
    FeatureSet([setdiff(g(𝐟), g(𝐟′)) for g ∈ [features, featurenames, keywords, descriptions]]...)
end

Base.:\(𝐟::FeatureSet, 𝐟′::FeatureSet) = Base.setdiff(𝐟, 𝐟′)

size(𝐟::FeatureSet) = size(getfeatures(𝐟))

getindex(𝐟::FeatureSet, i::Int) = FeatureSet(getfeatures(𝐟)[i], getkeywords(𝐟)[i], getdescriptions(𝐟)[i])
#getindex(𝐟::FeatureSet, i::Vararg{Int, 1})= FeatureSet(getfeatures(𝐟)[i], getnames(𝐟)[i], getkeywords(𝐟)[i], getdescriptions(𝐟)[i])

function setindex!(𝐟::FeatureSet, f::FeatureSet, i::Int)
    @assert length(f) == 1
    𝐟.features[i] = f.features[1]
    𝐟.featurenames[i] = f.featurenames[1]
    𝐟.keywords[i] = f.keywords[1]
    𝐟.descriptions[i] = f.descriptions[1]
    ()
end
# function setindex!(𝐟::FeatureSet, f::FeatureSet, I::Vararg{Int, N})
# end

IndexStyle(::FeatureSet) = IndexLinear()

# TODO Should probably optimise.
(𝐟::FeatureSet)(x::AbstractVector) = featureVector(vcat([f(x) for f ∈ getfeatures(𝐟)]...), getnames(𝐟))
(𝐟::FeatureSet)(X::AbstractArray{T, 2}) where {T} = featureMatrix(mapslices(𝐟, X; dims=1), getnames(𝐟))
