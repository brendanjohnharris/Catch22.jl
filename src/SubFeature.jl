"""
𝑓 = Feature(method::Function, name=Symbol(method), keywords="", description="")

Construct a `SubFeature`, which represents one component from another `Feature`` that outputs a vector (annotated with a `name`, `keywords` and short `description`).
This is to a `Feature` as _hctsa_'s 'operation' is to a 'master operation'.
"""
struct SubFeature <: AbstractFeature
    superfeature::Feature
    superidx::Int
    name::Symbol
    keywords::Vector{String}
    description::String
    SubFeature(superfeature::Feature, superidx::Int, name=Symbol(method), keywords=[""], description="") = new(superfeature, superidx, name, keywords, description)
end
export SubFeature

getmethod(𝑓::SubFeature) = x -> 𝑓.superfeature(x)[𝑓.superidx]

# * Now, whenever we encounter a FeatureSet we check to see if there are any SubFeatures. if there are, we create a list of the Features that need to be evaluated for those SubFeatures, evaluate those Features, then distribute components of their outputs to the relevant SubFeatures.

function subloop(𝒇, x, subidxs)
    !any(subidxs) && return FeatureVector([𝑓(x) for 𝑓 ∈ 𝒇], 𝒇)
    F = Vector{Float64}(undef, length(𝒇))
    if !all(subidxs)
        F[.!subidxs] .= 𝒇[.!subidxs](x)
    end
    subf = 𝒇[subidxs]
    superfeatures = getfield.(subf[subidxs], (:superfeature))
    superlinks = [findfirst((s,) .== unique(superfeatures)) for s ∈ superfeatures]
    superidxs = getfield.(subf[subidxs], (:superidx))
    supervals = [f(x) for f ∈ unique(superfeatures)]
    F[subidxs, :] .= [supervals[superlinks[i]][v] for (i, v) ∈ enumerate(superidxs)]
    return F
end
