using Test
using TestItems
using TestItemRunner

@run_package_tests

@testsnippet Setup begin
    using Catch22
    using Catch22.DimensionalData
    import Catch22: testdata, testoutput, testnames, catch22_raw
    using Test
    using StatsBase
    using BenchmarkTools

    function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray; atol = 1.0e-6)
        replace!(a, NaN => 0.0)
        replace!(b, NaN => 0.0)
        all(isapprox.(a, b, atol = atol))
    end
    function isnearlyequalorallnan(a::Real, b::Real; atol = 1.0e-6)
        isapprox(a, b, atol = atol) || (isnan(a) && isnan(b))
    end
    # catch22's expected outputs are masked (a NaN of a valid series replaced by the
    # feature's mask value), which Catch22.jl does not do: mask as the C does for comparison
    maskvalue(name, n) = ccall(
        (:catch22_mask_value, Catch22.libcatch22), Cdouble, (Cint, Cint),
        Catch22.featureindex[name], n
    )
    function masked(f::AbstractVector, x::AbstractVector)
        all(isfinite, x) || return collect(f)
        [isnan(v) ? maskvalue(name, length(x)) : v for (name, v) in zip(getnames(f), f)]
    end
    function testFeatures(t::Symbol)
        x = testdata[t]
        @time f = catch24(x)
        out = testoutput[t]
        isnearlyequalorallnan(masked(f, x), getindex.((out,), getnames(f)))
    end
    # The C pipeline for feature i of x (catch22_compute_feature, z-scoring in C), unmasked
    function cfeature(x::AbstractVector{Float64}, name::Symbol)
        out = Ref{Cdouble}(NaN)
        ccall(
            (:catch22_compute_feature, Catch22.libcatch22), Cint,
            (Ptr{Cdouble}, Cint, Cint, Cint, Ref{Cdouble}, Ptr{Cint}),
            x, length(x), Catch22.featureindex[name], 0, out, C_NULL
        )
        out[]
    end
end

@testitem "Feature index" setup = [Setup] begin
    # metadata.jl lists the features in the C library's order, under its long and short names
    names = Catch22.catch24_featurenames
    @test [Catch22.featureindex[n] for n in names] == 0:23
    cname(i) = Symbol(unsafe_string(ccall((:catch22_feature_name, Catch22.libcatch22), Cstring, (Cint,), i)))
    cshort(i) = Symbol(unsafe_string(ccall((:catch22_short_name, Catch22.libcatch22), Cstring, (Cint,), i)))
    clegacy(i) = Symbol(unsafe_string(ccall((:catch22_legacy_name, Catch22.libcatch22), Cstring, (Cint,), i)))
    @test cname.(0:23) == names
    @test cshort.(0:23) == Catch22.short_catch24_featurenames
    @test clegacy.(0:23) == Catch22.legacy_catch24_featurenames
    @test getnames(catch24) == names
    @test getnames(c24) == Catch22.short_catch24_featurenames
end

@testitem "Legacy names" setup = [Setup] begin
    for (old, new) in zip(Catch22.legacy_catch24_featurenames, Catch22.catch24_featurenames)
        @test getfield(Catch22, old) === getfield(Catch22, new)
    end
    @test Catch22.CO_f1ecac === CO_FirstCrossing_acf_1e_pointOfCrossing
    @test Catch22.DN_Mean === DN_mean
end

@testitem "Matches the C pipeline" setup = [Setup] begin
    # catch22_zscore then catch22_compute_feature_raw by index, as catch22_compute_feature
    # does in C: bit for bit, at any scale (#73's power-of-two scaling comes along)
    for n in [1, 2, 3, 4, 5, 10, 50, 1000], trial in 1:3, scale in [1.0, 1.0e-200, 1.0e200]
        x = scale .* (n == 1000 ? cumsum(randn(n)) : randn(n))
        F = catch24(x)
        for name in getnames(F)
            @test isequal(F[name], cfeature(x, name))
        end
    end
    x = randn(1000)
    @test Catch22.zᶠ(x) == Catch22.z_score(x)
    @test isapprox(mean(Catch22.z_score(x)), 0; atol = 1.0e-12) && std(Catch22.z_score(x)) ≈ 1
    @test Catch22.z_score(fill(1.5, 50)) == fill(1.5, 50) # constant: unchanged, as the C
    @test all(isnan, Catch22.z_score([1.0, Inf, 3.0]))
    @test Catch22.z_score(Int32[1, 2, 3]) == Catch22.z_score([1.0, 2.0, 3.0])
    x = fill(1.5, 50) # constant: NaN for the catch22 features, as the C
    @test all(isnan, catch22(x))
    @test DN_mean(x) == 1.5 && isnan(DN_Spread_std(x)) == false
    @test all(isnan, catch24([1.0, NaN, 3.0]))
end
# Test features one by one
println("Testing individual features")
@testitem "Feature $(getname(f))" setup = [Setup] begin
    for f in catch24
        if f in catch22
            @inferred Catch22._catch22(testdata[:test], getname(f))
            @inferred Catch22._catch22(randn(100, 10), getname(f))
        end
        x = testdata[:test]
        @test isnearlyequalorallnan(f(x), testoutput[:test][getname(f)])
    end
    x = testdata[:test]
    @test DN_mean(x) ≈ mean(x)
    @test DN_Spread_std(x) ≈ std(x)
end

# Test catch22, time series by time series
println("Testing sample datasets")
@testitem "Dataset $f" setup = [Setup] begin
    for f in testnames
        @test testFeatures(f)
    end
end

# Test catch22 on a vector
println("Testing 1000×100 array input")
@testitem "Vector" setup = [Setup] begin
    catch22(randn(100))
    X = randn(1000)
    @test @time catch24(X) isa FeatureVector
    @inferred catch22_raw(X)
    @inferred catch24(X)
end

# Test catch22 on a matrix
println("Testing 1000×100 array input")
@testitem "Matrices" setup = [Setup] begin
    catch22(randn(10, 10))
    X = randn(1000, 100)
    @test @time catch24(X) isa FeatureMatrix
    @inferred catch22_raw(X)
    @inferred catch24(X)
end

# Test short name version is the same as the full version
println("Testing short names, c22")
@testitem "Short names" setup = [Setup] begin
    X = randn(1000, 100)
    @test parent(catch24(X)) == parent(c24(X))
end

println("Testing 1000×20×20 array input")
@testitem "Arrays" setup = [Setup] begin
    X = randn(1000, 20, 20)
    @test @time catch24(X) isa FeatureArray{T, 3} where {T}
end

println("Testing input types")
@testitem "Types" setup = [Setup] begin
    X = rand(Int16, 10, 10, 10)
    _F = catch24(X)
    @test eltype(_F) <: Float64
    for T in [Int, Int32, Float32, Float64]
        F = catch24(convert(Array{T}, X))
        @test eltype(F) <: Float64
        @test isnearlyequalorallnan(F, _F; atol = 1.0e-5)
        @test F[DN_mean] ≈ dropdims(mean(T.(X), dims = 1), dims = 1)
        @test F[DN_Spread_std] ≈ dropdims(std(T.(X), dims = 1), dims = 1)
    end
end

println("Testing FeatureArray indexing")

@testitem "FeatureArray indexing" setup = [Setup] begin
    𝑓s = [:DN_HistogramMode_5, :DN_HistogramMode_10]
    𝑓 = FeatureSet([DN_HistogramMode_10, DN_HistogramMode_5])

    X = randn(1000)
    F = catch22(X)
    @test F[𝑓] == F[𝑓s][end:-1:1]
    @test F[𝑓] == F[[2, 1]]
    @test all(F[𝑓s] .== F[1:2]) # Importantly, F[𝑓s, :] is NOT SUPPORTED

    X = randn(1000, 200)
    F = catch22(X)
    @test F[𝑓] == F[𝑓s][end:-1:1, :]
    @test F[𝑓] == F[𝑓, :] == F[[2, 1], :]
    @test F[𝑓s] == F[𝑓s, :] == F[1:2, :]

    X = randn(1000, 20, 20)
    F = catch22(X)
    @test F[𝑓] == F[𝑓s][end:-1:1, :, :]
    @test F[𝑓] == F[𝑓, :, :] == F[[2, 1], :, :]
    @test F[𝑓s] == F[𝑓s, :, :] == F[1:2, :, :]
end

println("Testing Feature evaluation with DimArrays")
@testitem "DimArrays" setup = [Setup] begin
    x = DimArray(randn(100), (Dim{:x}(1:100),))
    @test first(CO_FirstCrossing_acf_1e_pointOfCrossing(x)) == CO_FirstCrossing_acf_1e_pointOfCrossing(x |> vec)
    @test length(CO_FirstCrossing_acf_1e_pointOfCrossing(x)) == 1
    @test catch22(x) == catch22(x |> vec)
end

println("Testing CovarianceImage")
@testitem "CovarianceImage" setup = [Setup] begin
    using Plots
    using Clustering
    X = hcat(randn(100, 100), cumsum(randn(100))) # a ramp's embedding_dist is NaN (all distances equal)
    F = catch22(X)
    verbose = false
    @test covarianceimage(F; colormode = :top, verbose) isa Plots.Plot
    @test covarianceimage(F; colormode = :all, verbose) isa Plots.Plot
    @test covarianceimage(F; colormode = :raw, verbose, colorbargrad = :viridis) isa
        Plots.Plot
end

println("Testing SuperFeatures")
@testitem "SuperFeatures" setup = [Setup] begin
    𝐱 = rand(1000, 2)
    @test_nowarn Catch22.zᶠ(𝐱)
    μ = SuperFeature(
        Catch22.mean, :μ, "Mean value of the z-scored time series", ["0"],
        Catch22.zᶠ
    )
    σ = SuperFeature(
        Catch22.std, :σ, "Standard deviation of the z-scored time series",
        ["1"], Catch22.zᶠ
    )
    𝒇 = SuperFeatureSet([μ, σ])
    @test all(isapprox.(𝒇(𝐱), [0.0 0.0; 1.0 1.0]; atol = 1.0e-9))
end

println("Testing Catch22 SuperFeatures")
@testitem "Catch22 SuperFeatures" setup = [Setup] begin
    catch22² = vcat(fill(catch22, 22)...)
    catch22_raw² = vcat(fill(Catch22.catch22_raw, 22)...)
    X = rand(1000, 10)
    @test catch22²(X) !== catch22_raw²(X)
    @test catch22_raw²(X) !== catch22_raw²(mapslices(Catch22.z_score, X, dims = 1))
    @test catch22²(X) == catch22_raw²(mapslices(Catch22.z_score, X, dims = 1))
    # @test catch22²[1:10] isa SuperFeatureSet # Ideally
    @test catch22_raw²[1:10](X) == catch22_raw²(X)[1:10, :]

    # @benchmark catch22_raw²(X)
    # @benchmark catch22²(X)
    # @benchmark catch22_raw²(mapslices(Catch22.z_score, X, dims=1))
    # @benchmark mapslices(Catch22.z_score, X, dims=1)
end

println("Testing multithreading")
@testitem "Multithreading" setup = [Setup] begin
    X = randn(10000)
    meths = Catch22.featurenames
    cres = zeros(size(X)[1], length(meths))
    window = 100
    f(X) =
        for j in eachindex(meths)
        Threads.@threads for i in 1:(size(X, 1) - window)
            @inbounds cres[i + window, j] = catch22[meths[j]](X[i:(i + window)])
        end
    end

    g(X) = Threads.@threads for i in 1:(size(X, 1) - window)
        @inbounds cres[i + window, :] = catch22[meths](X[i:(i + window)])
    end

    h(X) = catch22[meths]([X[i:(i + window)] for i in 1:(size(X, 1) - window)])

    i(X) = catch22[meths](@views [X[i:(i + window)] for i in 1:(size(X, 1) - window)])

    # BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5
    @test_nowarn f(X) # @benchmark f(X)
    @test_nowarn g(X) # @benchmark g(X)
    @test_nowarn h(X) # @benchmark h(X)
    @test_nowarn i(X) # @benchmark i(X)
    # using PProf
    # using Profile
    # Profile.clear()
    # @profile i(X)
    # pprof()
    # @profview i(X)
end

println("Testing performance")
@testitem "Performance" setup = [Setup] begin
    @inferred Catch22.catch22(randn(100))

    dataset = randn(10000000)
    fname = :DN_HistogramMode_10
    feature = eval(fname)

    m = Catch22._ccall(fname)
    t = @timed m(dataset)
    t = @timed m(dataset)
    tm = t.time
    @test t.bytes < 500

    t = @timed Catch22._catch22(dataset, fname)
    t = @timed Catch22._catch22(dataset, fname)
    @test t.time ≈ tm rtol = 1 # The nancheck takes some time
    @test t.bytes < 500

    m = getmethod(Catch22.catch22_raw[fname])
    t = @timed m(dataset)
    t = @timed m(dataset)
    @test t.time ≈ tm rtol = 1
    @test t.bytes < 500
    tf = t.time

    m = Catch22.z_score
    ta = @benchmark $m($dataset)
    m = Catch22.zᶠ
    tb = @benchmark $m($dataset)
    # Wall-clock comparisons are noisy on shared CI runners (and under emulation), so use the
    # minimum time (least affected by other load) and a much looser tolerance there
    if get(ENV, "CI", "false") == "true"
        @test minimum(ta).time ≈ minimum(tb).time rtol = 1
    else
        @test median(ta).time ≈ median(tb).time rtol = 0.2
    end
    tz = median(tb).time / 1.0e9

    m = feature |> getmethod
    t = @timed m(dataset)
    t = @timed m(dataset)
    @test t.time ≈ (tm + tz) rtol = 1 # Feature time + zscore time
    @test t.bytes < Base.sizeof(dataset) + 5000 # Just one deepcopy of the dataset, for the zscore
end
