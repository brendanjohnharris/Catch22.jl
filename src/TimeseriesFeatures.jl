using StatsBase

lags = 1:40
# ! A bit of overhead here...
AC = FeatureSet([x->autocor(x, [ℓ]; demean=true)[1]::Float64 for ℓ ∈ lags],
                Symbol.(["AC_$ℓ" for ℓ ∈ lags]),
                [["correlation"] for ℓ ∈ lags],
                ["Autocorrelation at lag $ℓ" for ℓ ∈ lags])
export AC

# ! Lots of overhead here; the pacf function has to recalculate for all smaller lags.
# ! Time to think about SuperFeatures...
AC_partial = FeatureSet([x->pacf(x, [ℓ]; method=:regression)[1]::Float64 for ℓ ∈ lags],
                Symbol.(["AC_partial_$ℓ" for ℓ ∈ lags]),
                [["correlation"] for ℓ ∈ lags],
                ["Partial autocorrelation at lag $ℓ (regression method)" for ℓ ∈ lags])
export AC_partial
