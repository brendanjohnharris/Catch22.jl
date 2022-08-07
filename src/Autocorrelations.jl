using .StatsBase

ac_lags = 1:40

ACF = Feature(x->autocor(x, ac_lags; demean=true), :ACF, "Autocorrelation function to lag $(maximum(ac_lags))", ["autocorrelation"])

ac = SuperFeatureSet([x->x[ℓ] for ℓ ∈ eachindex(ac_lags)],
                Symbol.(["ac_$ℓ" for ℓ ∈ ac_lags]),
                ["Autocorrelation at lag $ℓ" for ℓ ∈ ac_lags],
                [["correlation"] for ℓ ∈ ac_lags],
                ACF) # We compute the ACF just once, and pick off results for each feature
export ac

PACF = Feature(x->pacf(x, ac_lags; method=:regression), :ACF, "Partial autocorrelation function to lag $(maximum(ac_lags))", ["autocorrelation"])

partial_ac = SuperFeatureSet([x->x[ℓ] for ℓ ∈ eachindex(ac_lags)],
                Symbol.(["partial_ac_$ℓ" for ℓ ∈ ac_lags]),
                ["Partial autocorrelation at lag $ℓ (regression method)" for ℓ ∈ ac_lags],
                [["correlation"] for ℓ ∈ ac_lags],
                PACF)
export partial_ac
