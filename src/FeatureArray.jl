using DimensionalData
import DimensionalData: dims, refdims, data, name, metadata, rebuild, parent, formatdims, AbstractDimArray
import Base.Array

abstract type AbstractFeatureArray{T,N,D,A} <: AbstractDimArray{T,N,D,A} end
export AbstractFeatureArray

AbstractFeatureVector = AbstractFeatureArray{T, 1} where {T}
AbstractFeatureMatrix = AbstractFeatureArray{T, 2} where {T}
export AbstractFeatureVector, AbstractFeatureMatrix


"""
    F = FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol},Vector{Symbol}}, [timeseries::Union{Vector, Tuple}], args...)

Construct a `FeatureArray`, which annotates the array `data` with names of `features` along rows and, optionally, `timeseries` along columns.
Since `FeatureArray <: AbstractFeatureArray <: AbstractDimArray`, further arguments to the `FeatureArray` constructor are passed to the `DimArray` constructor.
To access feature names, use `getnames(F)`.

# Examples
```julia
data = rand(Int, 2, 10) # Some feature matrix with 2 features and 10 timeseries
F = FeatureArray(data, [:sum, :length])
```
"""
struct FeatureArray{T,N,D<:Tuple,R<:Tuple,A<:AbstractArray{T,N},Na,Me} <: AbstractFeatureArray{T,N,D,A}
    data::A
    dims::D
    refdims::R
    name::Na
    metadata::Me
end
export FeatureArray

function FeatureArray(data::A, dims::D, refdims::R=(), name::Na=NoName()) where {D,R,A,Na}
    if typeof(dims[1]) <: Dim{:feature, Vector{Symbol}, A, B} where {A, B}
        FeatureArray(data, formatdims(data, dims), refdims, name, NoMetadata())
    else
        @error "Incorrect dimensions for FeatureArray"
    end
end

function FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol}, Vector{Symbol}}, args...)
    FeatureArray(data, (Dim{:feature}(features), fill(AnonDim(), ndims(data)-1)...), args...)
end
function FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol}, Vector{Symbol}}, timeseries::Union{Vector, Tuple}, args...)
    if data isa AbstractVector
        FeatureArray(reshape(data, :, 1), (Dim{:feature}(features), Dim{:timeseries}(timeseries)), args...)
    else
        FeatureArray(data, (Dim{:feature}(features), Dim{:timeseries}(timeseries)), args...)
    end
end
function FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol}, Vector{Symbol}}, otherdims::Union{Pair, Tuple{Pair}, Vector{Pair}}, args...)
    if otherdims isa Pair
        otherdims = [otherdims]
    end
    FeatureArray(data, (Dim{:feature}(features), [Dim{x.first}(x.second[:]) for x ∈ otherdims]...), args...)
end

FeatureArray(D::DimArray) = FeatureArray(D.data, D.dims, D.refdims, D.name, D.metadata)
# DimensionalData.DimArray(D::FeatureArray) = DimArray(D.data, D.dims, D.refdims, D.name, D.metadata)

dims(A::AbstractFeatureArray) = A.dims
refdims(A::AbstractFeatureArray) = A.refdims
data(A::AbstractFeatureArray) = A.data
name(A::AbstractFeatureArray) = A.name
metadata(A::AbstractFeatureArray) = A.metadata
parent(A::AbstractFeatureArray) = data(A)
Base.Array(A::AbstractFeatureArray) = Array(parent(A))

@inline function rebuild(A::AbstractFeatureArray, data::AbstractArray, dims::Tuple, refdims::Tuple, name, metadata)
    FeatureArray(data, dims, refdims, name, metadata)
end

getindex(A::AbstractFeatureArray, 𝑓::AbstractFeature, I...) = getindex(A, getname(𝑓), I...)

getindex(A::AbstractFeatureArray, 𝒇::AbstractFeatureSet, I...) = getindex(A, getnames(𝒇), I...)



"""
    FeatureArray{T, 2} where {T}

An alias to construct a `FeatureArray` for a flat set of timeseries.

# Examples
```julia
data = rand(Int, 2, 3) # Some feature matrix with 2 features and 3 timeseries
F = FeatureMatrix(data, [:sum, :length], [1, 2, 3])
```
"""
FeatureMatrix = FeatureArray{T, 2} where {T}
featureMatrix = FeatureMatrix
export FeatureMatrix, featureMatrix


"""
    FeatureArray{T, 1} where {T}

An alias to construct a `FeatureArray` for a single time series.

# Examples
```julia
data = randn(2) # Feature values for 1 time series
𝐟 = FeatureVector(data, [:sum, :length])
```
"""
FeatureVector = FeatureArray{T, 1} where {T}
featureVector = FeatureVector
export FeatureVector, featureVector

FeatureArray(X::AbstractArray, 𝒇::AbstractFeatureSet) = FeatureArray(X::AbstractArray, getnames(𝒇))

(FeatureArray{T,N} where {T})(x::AbstractArray{S,N}, args...) where {S,N} = FeatureArray(x, args...)


getdim(X::AbstractDimArray, dim) = dims(X, dim).val
export getdim

"""
    getnames(𝒇::FeatureArray)
Get the names of features represented in the feature vector or array 𝒇 as a vector of symbols.
"""
featureDims(A::AbstractDimArray) = getdim(A, :feature)
getnames(A::AbstractFeatureArray) = featureDims(A)
export getnames

timeseriesDims(A::AbstractDimArray) = getdim(A, :timeseries)

function setdim(F::DimArray, dim, vals...)::DimArray
    dimvec = Vector{Dimension}(undef, length(dims(F)))
    [(dimvec[i] = dims(F)[i]) for i ∈ 1:length(dims(F)) if !∈(i, dim)]
    [(dimvec[dim[d]] = Dim{vals[d].first}(vals[d].second)) for d ∈ 1:lastindex(dim)]
    DimArray(F, Tuple(dimvec)) # * Much faster to leave F as a DimArray rather than Array(F)
end
setdim(F::AbstractFeatureArray, args...) = FeatureArray(setdim(DimArray(F), args...))
export setdim

function sortbydim(F::AbstractDimArray, dim; rev=false)
    sdim = Catch22.getdim(F, dim)
    idxs = sortperm(sdim; rev)
    indx = [collect(1:size(F, i)) for i ∈ 1:ndims(F)]
    indx[dim] = idxs
    return F[indx...]
end
