using .StatsBase

ac_lags = 1:40

ACF = Feature(x -> autocor(x, ac_lags; demean=true), :ACF, "Autocorrelation function to lag $(maximum(ac_lags))", ["autocorrelation"])

ac = SuperFeatureSet([x -> x[ℓ] for ℓ ∈ eachindex(ac_lags)],
    Symbol.(["ac_$ℓ" for ℓ ∈ ac_lags]),
    ["Autocorrelation at lag $ℓ" for ℓ ∈ ac_lags],
    [["correlation"] for ℓ ∈ ac_lags],
    ACF) # We compute the ACF just once, and pick off results for each feature
export ac

PACF = Feature(x -> pacf(x, ac_lags; method=:regression), :ACF, "Partial autocorrelation function to lag $(maximum(ac_lags))", ["autocorrelation"])

partial_ac = SuperFeatureSet([x -> x[ℓ] for ℓ ∈ eachindex(ac_lags)],
    Symbol.(["partial_ac_$ℓ" for ℓ ∈ ac_lags]),
    ["Partial autocorrelation at lag $ℓ (regression method)" for ℓ ∈ ac_lags],
    [["correlation"] for ℓ ∈ ac_lags],
    PACF)
export partial_ac


function firstcrossing(x, threshold=0)
    lagchunks = min(100, length(x) - 1)
    lags = 1:lagchunks
    i = 1
    r1 = sign(autocor(x, [1]; demean=true) |> first) # If the time series is anticorrelated with itself, we look for the first upward crossing over the threshold
    threshold = threshold * r1
    while i * lagchunks < length(x)
        r = autocor(x, lags; demean=true) .* r1
        lastr = r[end]
        if any(r .< threshold)
            idx = findfirst(r .< threshold)
            b = r[idx]
            a = idx == 1 ? lastr : r[idx-1]
            idx += (i - 1) * lagchunks
            return idx - 1 + (threshold - a) / (b - a)
        else
            lags = lags .+ lagchunks
            i += 1
        end
    end
end


"""
    CR_RAD(x, τ=1, doAbs=true)
Compute the rescaled auto-density, a metric for inferring the
distance to criticality that is insensitive to uncertainty in the noise strength.
Calibrated to experiments on the Hopf bifurcation with variable and unknown
measurement noise.

Inputs:
    x:      The input time series (vector).
    doAbs:  Whether to centre the time series at 0 then take absolute values (logical flag)
    τ:      The embedding and differencing delay in units of the timestep (integer), or :τ

Outputs:
    f:      The RAD feature value
"""
function RAD(z, τ=1, doAbs=true)
    if doAbs
        z = z .- median(z)
        z = abs.(z)
    end
    if τ === :τ
        # Make τ the first zero crossing of the autocorrelation function
        τ = firstcrossing(z, 0)
    end

    y = @view z[τ+1:end]
    x = @view z[1:end-τ]

    # Median split
    subMedians = x .< median(x)
    superMedianSD = std(x[.!subMedians])
    subMedianSD = std(x[subMedians])

    # Properties of the auto-density
    sigma_dx = std(y - x)
    densityDifference = 1 / superMedianSD - 1 / subMedianSD

    f = sigma_dx * densityDifference
end

CR_RAD = Feature(x -> RAD(x), :CR_RAD, "Rescaled Auto-Density criticality metric", ["criticality"])
export RAD, CR_RAD, firstcrossing
