using DimensionalData
import DimensionalData.dims, DimensionalData.refdims, DimensionalData.data, DimensionalData.name, DimensionalData.metadata, DimensionalData.rebuild, DimensionalData.parent
import Base.Array

abstract type AbstractFeatureArray{T,N,D,A} <: AbstractDimArray{T,N,D,A} end
export AbstractFeatureArray

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
        FeatureArray(data, DimensionalData.formatdims(data, dims), refdims, name, NoMetadata())
    else
        @error "Incorrect dimensions for FeatureArray"
    end
end

function FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol}, Vector{Symbol}}, args...)
    FeatureArray(data, (Dim{:feature}(features), fill(AnonDim(), ndims(data)-1)...), args...)
end
function FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol}, Vector{Symbol}}, timeseries::Union{Vector, Tuple}, args...)
    if typeof(data) <: AbstractVector
        FeatureArray(reshape(data, :, 1), (Dim{:feature}(features), Dim{:timeseries}(timeseries)), args...)
    else
        FeatureArray(data, (Dim{:feature}(features), Dim{:timeseries}(timeseries)), args...)
    end
end

dims(A::AbstractFeatureArray) = A.dims
export dims
refdims(A::AbstractFeatureArray) = A.refdims
data(A::AbstractFeatureArray) = A.data
name(A::AbstractFeatureArray) = A.name
metadata(A::AbstractFeatureArray) = A.metadata
parent(A::AbstractFeatureArray) = data(A)
Base.Array(A::AbstractFeatureArray) = Array(parent(A))

@inline function rebuild(A::FeatureArray, data::AbstractArray, dims::Tuple, refdims::Tuple, name, metadata)
    FeatureArray(data, dims, refdims, name, metadata)
end

FeatureMatrix = FeatureArray{T, 2} where {T}
FeatureMatrix(args...) = FeatureArray(args...)
export FeatureMatrix

FeatureVector = FeatureArray{T, 1} where {T}
FeatureVector(args...) = FeatureArray(args...)
export FeatureVector
