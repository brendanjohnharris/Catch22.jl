# Catch22.jl
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://brendanjohnharris.github.io/Catch22.jl/dev)
[![Build Status](https://github.com/brendanjohnharris/Catch22.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/brendanjohnharris/Catch22.jl/actions/workflows/CI.yml?query=branch%3Amain)

[![Coverage](https://codecov.io/gh/brendanjohnharris/catch22.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/brendanjohnharris/Catch22.jl)
[![DOI](https://zenodo.org/badge/342070622.svg)](https://zenodo.org/badge/latestdoi/342070622)
<!-- ![build](https://github.com/brendanjohnharris/Catch22.jl/actions/workflows/CI.yml/badge.svg) -->

A Julia package wrapping [_catch22_](https://www.github.com/chlubba/catch22), which is a set of 22 time-series features shown by [Lubba et al. (2019)](https://doi.org/10.1007/s10618-019-00647-x) to be performant in a range of time-series classification problems.

The [_catch22_](https://www.github.com/chlubba/catch22) repository provides these 22 features, originally coded in Matlab as part of the [_hctsa_](https://github.com/benfulcher/hctsa) toolbox, as C functions (in addition to Matlab and Python wrappers). This package simply uses Julia's `ccall` to wrap these C functions from a shared library that is accessed through [catch22_jll](https://github.com/JuliaBinaryWrappers/catch22_jll.jl) and compiled by the fantastic [BinaryBuilder](https://github.com/JuliaPackaging/BinaryBuilder.jl) package.

<br>

# Usage
## Installation
```Julia
using Pkg
Pkg.add("Catch22")
using Catch22
```

## Input time series
The input time series can be provided as a `Vector{Float64}` or `Array{Float64, 2}`. If an array is provided, the time series must occupy its _columns_. For example, this package contains a few test time series from [_catch22_](https://www.github.com/chlubba/catch22):
```Julia
𝐱 = Catch22.testdata[:testSinusoid] # a Vector{Float64}
X = randn(1000, 10) # an Array{Float64, 2} with 10 time series
```

## Evaluating a feature
A list of features (as symbols) can be obtained with `getnames(catch22)` and their short descriptions with `getdescriptions(catch22)`. Each feature can be evaluated for a time series array or vector with the `catch22` `FeatureSet`. For example, the feature `DN_HistogramMode_5` can be evaluated using:
```Julia
f = catch22[:DN_HistogramMode_5](𝐱) # Returns a scalar Float64
𝐟 = catch22[1](X) # Returns a 1×10 Matrix{Float64}
```
All features are returned as Float64's, even though some may be constrained to the integers.

Alternatively, functions that calculate each feature individually are exported. `DN_HistogramMode_5` can be evaluated with:
```Julia
f = DN_HistogramMode_5(𝐱)
```

## Evaluating a feature set
All _catch22_ features can be evaluated with:
```Julia
𝐟 = catch22(𝐱)
F = catch22(X)
```
If an array is provided, containing one time series in each of N columns, then a 22×N `FeatureArray` of feature values will be returned (a subtype of [AbstractDimArray](https://github.com/rafaqz/DimensionalData.jl)).
A `FeatureArray` has most of the properties and methods of an Array but is annotated with feature names that can be accessed with `getnames(F)`.
If a vector is provided (a single time series) then a vector of feature values will be returned as a `FeatureVector`, a one-dimensional `FeatureArray`.

Finally, note that since `catch22` is a `FeatureSet` it can be indexed with a vector of feature names as symbols to calculate a `FeatureArray` for a subset of _catch22_. For details on the `Feature`, `FeatureSet` and `FeatureArray` types check out the package docs.

<br>

# Single-threaded performance
Calculating features for a single time series of a given length:
![scaling](scaling.png)
# Multithreaded performance
Calculating features for 100 time series of a given length:
![multithread_scaling](multithread_scaling.png)
