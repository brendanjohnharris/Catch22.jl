import Base.size, Base.getindex, Base.setindex!, Base.:+

abstract type AbstractFeatureSet <: AbstractVector{Function} end
export AbstractFeatureSet

"""
    FeatureSet(methods, [names, keywords, descriptions])
    FeatureSet(features::Vector{T}) where {T <: AbstractFeature}

Construct a `FeatureSet` from `methods` (a vector of functions) and optionally provide `names` as a vector of symbols, `keywords` as a vector of vectors of strings and `descriptions` as a vector of strings.
A `FeatureSet` can be called on time series vector or matrix `X` (with time series occupying columns) to return a `FeatureArray` of feature values.
Subsets of a `FeatureSet` `𝒇` can be obtained by indexing with feature names as symbols.
`FeatureSet`s also support set operations defined for arrays, such as unions and intersections, as well as convenient syntax for concatenation (`+`) and set differencing (`\\`).
Note that two features are considered the same if and only if their names are equal.

# Examples
```julia-repl
𝒇 = FeatureSet([sum, length], [:sum, :length], [["distribution"], ["sampling"]], ["∑x¹", "∑x⁰"])
X = randn(100, 2) # 2 time series, 100 samples long
F = 𝒇(X)

# Joining feature sets
𝒇₁ = FeatureSet([x->min(x...), x->max(x...)], [:min, :max], [["distribution"], ["distribution"]], ["minimum", "maximum"])
𝒈₁ = 𝒇 + 𝒇₁
G = 𝒈₁(X)

# Intersecting feature sets, where feature names are used exclusively to identify features
𝒇₂ = FeatureSet(x->prod, :sum, ["distributions"], "∏x")
𝒈₂ = 𝒇 ∪ 𝒇₂
G = 𝒈₂(X)
```
"""
struct FeatureSet <: AbstractFeatureSet
    features::Vector{AbstractFeature}
    FeatureSet(features::Vector{T}) where {T <: AbstractFeature} = new(features)
end

FeatureSet( methods::AbstractVector,
            names=Symbol.(methods),
            keywords=fill([], length(methods)),
            descriptions=fill("", length(methods))) =
            FeatureSet(Feature.(methods, names, keywords, descriptions))

FeatureSet( methods::Function,
            names=Symbol(methods),
            keywords=[],
            descriptions="") =
            FeatureSet([Feature(methods, names, keywords, descriptions)])

FeatureSet(f::AbstractFeature) = FeatureSet([f])

export FeatureSet

getfeatures(𝒇::AbstractFeatureSet) = 𝒇.features
getmethods(𝒇::AbstractFeatureSet)  = getmethod.(𝒇)
getnames(𝒇::AbstractFeatureSet)  = getname.(𝒇)
getkeywords(𝒇::AbstractFeatureSet)  = getkeywords.(𝒇)
getdescriptions(𝒇::AbstractFeatureSet)  = getdescription.(𝒇)
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
(𝒇::AbstractFeatureSet)(X::AbstractArray) = FeatureMatrix(mapslices(𝒇, X; dims=1), 𝒇)
(𝒇::AbstractFeatureSet)(x, f::Symbol) = 𝒇[f](x)
