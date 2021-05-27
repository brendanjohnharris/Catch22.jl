using StatsBase
import Base.:(==)
import Base.:\
import Base.:+
import Base.eltype
import Base.getindex
import Base.IndexStyle
import Base.intersect
import Base.iterate
import Base.IteratorEltype
import Base.IteratorSize
import Base.lastindex
import Base.length
import Base.setdiff
import Base.setindex!
import Base.size
import Base.union
import Base.vcat



abstract type AbstractFeatureSet <: AbstractVector{Function} end

mutable struct FeatureSet <: AbstractFeatureSet
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


# # ! More robust way might be to define iterate for 𝒇, then these will follow automatically and allow ∪(𝒇, 𝒇, 𝒇)

# # function Base.union(𝒇::FeatureSet, 𝒇′::FeatureSet)
# #     FeatureSet([union(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
# # end

# # function Base.intersect(𝒇::FeatureSet, 𝒇′::FeatureSet)
# #     FeatureSet([intersect(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
# # end

# # function Base.setdiff(𝒇::FeatureSet, 𝒇′::FeatureSet)
# #     FeatureSet([setdiff(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
# # end
# #!--------------------------------------------------------------------------------------------------
# function Base.:+(𝒇::FeatureSet, 𝒇′::FeatureSet)
#     FeatureSet([vcat(g(𝒇), g(𝒇′)) for g ∈ [getfeatures, getnames, getkeywords, getdescriptions]]...)
# end

# Base.iterate(𝒇::FeatureSet) = (𝒇[1], 2)
# function Base.iterate(𝒇::FeatureSet, i::Int)
#     if i <= length(𝒇)
#         (𝒇[i], i+1)
#     else
#         nothing
#     end
# end

# Base.:\(𝒇::FeatureSet, 𝒇′::FeatureSet) = Base.setdiff(𝒇, 𝒇′)
# Base.:(==)(𝒇::FeatureSet, 𝒇′::FeatureSet) = begin show(getnames(𝒇),    isequal(getnames(𝒇), getnames(𝒇′)) end

# size(𝒇::FeatureSet) = size(getfeatures(𝒇))
# eltype(::FeatureSet) = FeatureSet
# IteratorEltype(::FeatureSet) = HasEltype()
# IndexStyle(::FeatureSet) = IndexLinear()
# length(𝒇::FeatureSet) = prod(size(𝒇))
# IteratorSize(::FeatureSet) = HasLength()
# lastindex(𝒇::FeatureSet) = length(𝒇)


# # TODO Should probably optimise.
# (𝒇::FeatureSet)(x::AbstractVector) = featureVector(vcat([f(x) for f ∈ getfeatures(𝒇)]...), getnames(𝒇))
# (𝒇::FeatureSet)(X::AbstractArray{T, 2}) where {T} = featureMatrix(mapslices(𝒇, X; dims=1), getnames(𝒇))

# catch2 = FeatureSet([StatsBase.mean, StatsBase.std], [:mean, :SD], ["", ""], ["", ""])
# export catch2

# catch24 = FeatureSet([x -> catch22(x, f) for f ∈ featureNames], featureNames, fill("", length(featureNames)), getindex.((features,), featureNames))
# export catch24


# # TODO Pretty printing