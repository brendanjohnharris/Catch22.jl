@reexport module FeatureSets
import ..Features: AbstractFeature, Feature, getname, getkeywords, getdescription, formatshort
using DimensionalData
import Base: show, size, getindex, setindex!, similar, eltype, deleteat!, filter, union, intersect, convert, promote_rule, +, \

export AbstractFeatureSet, FeatureSet,
    getfeatures, getmethods, getnames, getkeywords, getdescriptions


abstract type AbstractFeatureSet <: AbstractVector{Function} end

"""
    FeatureSet(methods, [names, keywords, descriptions])
    FeatureSet(features::Vector{T}) where {T <: AbstractFeature}

Construct a `FeatureSet` from `methods` (a vector of functions) and optionally provide `names` as a vector of symbols, `keywords` as a vector of vectors of strings, and `descriptions` as a vector of strings.
A `FeatureSet` can be called on a time-series vector or matrix `X` (with time series occupying columns) to return a `FeatureArray` of feature values.
Subsets of a `FeatureSet` `𝒇` can be obtained by indexing with feature names (as symbols) or the regular linear and logical indices.
`FeatureSet`s also support simple set operations defined for arrays, such as unions and intersections, as well as convenient syntax for concatenation (`+`) and set differencing (`\\`).
Note that two features are considered the same if and only if their names are equal.

# Examples
```julia
𝒇 = FeatureSet([sum, length], [:sum, :length], [["distribution"], ["sampling"]], ["∑x¹", "∑x⁰"])
X = randn(100, 2) # 2 time series, 100 samples long
F = 𝒇(X)

# Joining feature sets
𝒇₁ = FeatureSet([x->min(x...), x->max(x...)], [:min, :max], [["distribution"], ["distribution"]], ["minimum", "maximum"])
𝒈₁ = 𝒇 + 𝒇₁
G = 𝒈₁(X)

# Intersecting feature sets, where features are identified exclusively by their names
𝒇₂ = FeatureSet(x->prod, :sum, ["distributions"], "∏x")
𝒈₂ = 𝒇 ∩ 𝒇₂ # The intersection of two feature sets, both with their own :sum
G = 𝒈₂(X) # The intersection contains the :sum of the first argument to ∩; 𝒇
```
"""
struct FeatureSet <: AbstractFeatureSet
    features::Vector{AbstractFeature}
    FeatureSet(features::Vector{T}) where {T<:AbstractFeature} = new(features)
end

FeatureSet(methods::AbstractVector{<:Function}, args...) = Feature.(methods, args...) |> FeatureSet
FeatureSet(methods::Function, args...) = [Feature(methods, args...)] |> FeatureSet
FeatureSet(; methods, names, keywords, descriptions) = FeatureSet(methods, names, keywords, descriptions)
FeatureSet(f::AbstractFeature) = FeatureSet([f])

getfeatures(𝒇::AbstractFeatureSet) = 𝒇.features
getmethods(𝒇::AbstractFeatureSet) = getmethod.(𝒇)
getnames(𝒇::AbstractFeatureSet) = getname.(𝒇)
getkeywords(𝒇::AbstractFeatureSet) = getkeywords.(𝒇)
getdescriptions(𝒇::AbstractFeatureSet) = getdescription.(𝒇)

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

similar(::AbstractFeatureSet, ::Type{S}, dims::Dims) where {S} = FeatureSet(Vector{AbstractFeature}(undef, dims[1]))

deleteat!(𝒇::AbstractFeatureSet, args...) = deleteat!(𝒇.features, args...)

filter(f, 𝒇::AbstractFeatureSet) = FeatureSet(filter(f, getfeatures(𝒇)))

(+)(𝒇::AbstractFeatureSet, 𝒇′::AbstractFeatureSet) = FeatureSet(
    [vcat(g(𝒇), g(𝒇′)) for g ∈ [getfeatures,
        getnames,
        getkeywords,
        getdescriptions]]...)
(\)(𝒇::AbstractFeatureSet, 𝒇′::AbstractFeatureSet) = setdiff(𝒇, 𝒇′)

# Allow operations between FeatureSet and Feature by converting the Feature
for p ∈ [:+, :\, :union, :intersect]
    eval(quote
        ($p)(𝒇::AbstractFeatureSet, f::AbstractFeature) = ($p)(𝒇, FeatureSet(f))
        ($p)(f::AbstractFeature, 𝒇::AbstractFeatureSet) = ($p)(FeatureSet(f), 𝒇)
    end)
end

(𝒇::AbstractFeatureSet)(x, f::Symbol) = 𝒇[f](x)

format(𝒇::AbstractFeatureSet) = "$(typeof(𝒇)) with features: $(getnames(𝒇))"
show(𝒇::AbstractFeatureSet) = 𝒇 |> format |> show
show(io::IO, 𝒇::AbstractFeatureSet) = show((io,), 𝒇 |> format)
function show(io::IO, m::MIME"text/plain", 𝒇::AbstractFeatureSet)
    print("$(typeof(𝒇)) with features:\n")
    for 𝑓 in 𝒇[1:end-1]
        s = formatshort(𝑓)
        print("    ")
        printstyled(io, s[1], color=:light_blue, bold=true)
        printstyled(io, s[2])
        print("\n")
    end
    s = formatshort(𝒇[end])
    print("    ")
    printstyled(io, s[1], color=:light_blue, bold=true)
    printstyled(io, s[2])
end

end # module
