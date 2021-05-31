import Base.size, Base.getindex, Base.setindex!, Base.similar, Base.eltype, Base.deleteat!, Base.filter, Base.union, Base.intersect, Base.convert, Base.promote_rule, Base.:+, Base.:\

abstract type AbstractFeatureSet <: AbstractVector{Function} end
export AbstractFeatureSet

"""
    FeatureSet(methods, [names, keywords, descriptions])
    FeatureSet(features::Vector{T}) where {T <: AbstractFeature}

Construct a `FeatureSet` from `methods` (a vector of functions) and optionally provide `names` as a vector of symbols, `keywords` as a vector of vectors of strings and `descriptions` as a vector of strings.
A `FeatureSet` can be called on a time series vector or matrix `X` (with time series occupying columns) to return a `FeatureArray` of feature values.
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

# Intersecting feature sets, where feature are identified exclusively by their names
𝒇₂ = FeatureSet(x->prod, :sum, ["distributions"], "∏x")
𝒈₂ = 𝒇 ∩ 𝒇₂ # The intersection of two feature sets, both with their own :sum
G = 𝒈₂(X) # The intersection contains the :sum of the first argument to ∩; 𝒇
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
getindex(𝒇::AbstractFeatureSet, I) = FeatureSet(getfeatures(𝒇)[I])

function getindex(𝒇::AbstractFeatureSet, 𝐟::Vector{Symbol})
    i = [findfirst(x -> x == f, getnames(𝒇)) for f ∈ 𝐟]
    getindex(𝒇, i)
end

function getindex(𝒇::AbstractFeatureSet, f::Symbol)
    i = findfirst(x -> x == f, getnames(𝒇))
    getindex(𝒇, i)
end

function setindex!(𝒇::AbstractFeatureSet, f, i::Int)
    setindex!(𝒇.features, f, i)
    ()
end

IndexStyle(::AbstractFeatureSet) = IndexLinear()
eltype(::AbstractFeatureSet) = AbstractFeature

Base.similar(::AbstractFeatureSet, ::Type{S}, dims::Dims) where {S} = FeatureSet(Vector{AbstractFeature}(undef, dims[1]))

Base.deleteat!(𝒇::AbstractFeatureSet, args...) = deleteat!(𝒇.features, args...)

Base.filter(f, 𝒇::AbstractFeatureSet) = FeatureSet(Base.filter(f, getfeatures(𝒇)))

Base.:+(𝒇::AbstractFeatureSet, 𝒇′::AbstractFeatureSet) = FeatureSet(
                    [vcat(g(𝒇), g(𝒇′)) for g ∈ [getfeatures,
                                                getnames,
                                                getkeywords,
                                                getdescriptions]]...)
Base.:\(𝒇::AbstractFeatureSet, 𝒇′::AbstractFeatureSet) = Base.setdiff(𝒇, 𝒇′)

# Allow operations between FeatureSet and Feature by converting the Feature
for p ∈ [:+, :\, :union, :intersect]
    eval(quote
        ($p)(𝒇::AbstractFeatureSet, f::AbstractFeature) = ($p)(𝒇, FeatureSet(f))
        ($p)(f::AbstractFeature, 𝒇::AbstractFeatureSet) = ($p)(FeatureSet(f), 𝒇)
    end)
end

(𝒇::AbstractFeatureSet)(x::AbstractVector) = FeatureVector([𝑓(x) for 𝑓 ∈ 𝒇], 𝒇)
(𝒇::AbstractFeatureSet)(X::AbstractArray) = FeatureMatrix(mapslices(𝒇, X; dims=1), 𝒇)
(𝒇::AbstractFeatureSet)(x, f::Symbol) = 𝒇[f](x)
