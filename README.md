# Catch22
A Julia package wrapping [_catch22_](https://www.github.com/chlubba/catch22), which is a set of 22 minimally redundant time-series features shown by [Lubba et al. (2019)](https://doi.org/10.1007/s10618-019-00647-x) to be performant in a range of time-series classification problems.

The [_catch22_](https://www.github.com/chlubba/catch22) repository provides these 22 features, originally coded in Matlab as part of the [_hctsa_](https://github.com/benfulcher/hctsa) toolbox, as C functions (in addition to Matlab and Python wrappers). This package simply uses Julia's `ccall` to wrap these C functions from a shared library that is accessed through [catch22_jll](https://github.com/JuliaBinaryWrappers/catch22_jll.jl) and compiled by the fantastic [BinaryBuilder](https://github.com/JuliaPackaging/BinaryBuilder.jl) package.

<br>

# Usage
## Installation
```Julia
using Pkg
Pkg.add("https://github.com/brendanjohnharris/Catch22.jl.git")
using Catch22
```

## Input time series
The input time series can be provided as a Vector{Float64} or Array{Float64, 2}. If an array is provided, the time series must occupy its _columns_. For example, this package contains a few test time series from [_catch22_](https://www.github.com/chlubba/catch22):
```Julia
𝐱 = Catch22.testData[:testSinusoid] # a Vector{Float64}
X = randn(1000, 10) # an Array{Float64, 2} with 10 time series
```

## Evaluating a feature
A list of features, as symbols, along with short descriptions is contained in `Catch22.features`. Each feature can be evaluated for a time series array or vector with the `catch22` function. For example, the feature `DN_HistogramMode_5` can be evaluated using:
```Julia
f = catch22(𝐱, :DN_HistogramMode_5) # Returns a scalar Float64
𝐟 = catch22(X, :DN_HistogramMode_5) # Returns a Vector{Float64}
```
All features are returned as Float64's, even though some may be constrained to the integers.

Alternatively, functions that calculate each feature individually are exported. `DN_HistogramMode_5` can be evaluated with:
```Julia
f = DN_HistogramMode_5(𝐱)
```

## Evaluating all features
Calling `catch22` without a feature name will evaluate all features:
```Julia
𝐟 = catch22(𝐱) # Time series vector to feature vector
F = catch22(X) # Set of time series to feature matrix
```

If a vector is provided (a single time series) then a scalar feature value will be returned. If an array is provided, a vector of features will be returned as a [DimArray](https://github.com/rafaqz/DimensionalData.jl). DimArrays inherit all properties and methods of Arrays but also allow feature names to be annotated, which can be accessed by:
```Julia
using DimensionalData
val(𝐟)[1] # Get the feature names
F = set(F, timeseries='a'.+collect(0:9)) # Change the time series labels to a:j
```
Finally, `catch22` can be called with a vector of feature names to calculate a feature matrix for a subset of _catch22_.
