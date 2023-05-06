using SafeTestsets

@safetestset "Catch22" begin
using Catch22
using Catch22.DimensionalData
import Catch22.testdata, Catch22.testoutput, Catch22.testnames
using Test
using StatsBase
# using BenchmarkTools

function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray)
    replace!(a, NaN=>0.0)
    replace!(b, NaN=>0.0)
    all(isapprox.(a, b, atol=1e-6))
end
function isnearlyequalorallnan(a::Real, b::Real)
    isapprox(a, b, atol=1e-6) || (isnan(a) && isnan(b))
end

# Test features one by one
println("Testing individual features")
@testset "Feature $(getname(f))" for f ∈ catch24
        @test isnearlyequalorallnan(f(testdata[:test]), testoutput[:test][getname(f)])
end;


# Test catch22, time series by time series
catch24(testdata[:test])
println("Testing sample datasets")
function testFeatures(t::Symbol)
    @time f = catch22(testdata[t])
    out = testoutput[t]
    if isnothing(out)
        all(isnan.(f))
    else
        isnearlyequalorallnan(Array(f), getindex.((out,), getnames(f)))
    end
end
@testset "Dataset $f" for f in testnames
    @test testFeatures(f)
end;



# Test catch22 on a matrix
println("Testing 1000×100 array input")
catch22(randn(10, 10))
X = randn(1000, 100)
@testset "Matrices" begin
    @test @time catch24(X) isa FeatureMatrix
end;



println("Testing 1000×20×20 array input")
catch22(randn(10, 10, 10))
X = randn(1000, 20, 20)
@testset "Arrays" begin
    @test @time catch24(X) isa FeatureArray{T, 3} where {T}
end;



println("Testing FeatureSet operations")

@testset "FeatureSet" begin
    𝒇₁ = FeatureSet([sum, length], [:sum, :length], [["distribution"], ["sampling"]], ["∑x¹", "∑x⁰"])
    𝒇₂ = catch22[1:2]
    X = randn(100, 2)
    𝒇₃ = 𝒇₁ + 𝒇₂
    @test_nowarn 𝒇₁(X)
    @test_nowarn 𝒇₃(X)
    @test getnames(𝒇₃) == [:sum, :length , :DN_HistogramMode_5, :DN_HistogramMode_10]
    @test_nowarn 𝒇₃[:sum]
    @test getname(𝒇₃[:sum]) == :sum
    @test all([getname(𝒇₃[x]) == x for x in getnames(𝒇₃)])
    @test_nowarn 𝒇₃(X)[:sum, :]
    @test 𝒇₃(X)[:sum] == 𝒇₃(X)[:sum, :]
    @test_nowarn 𝒇₃(X)[[:sum, :length], :]
    @test 𝒇₃(X)[[:sum, :length]] == 𝒇₃(X)[[:sum, :length], :]
    @test 𝒇₁ == 𝒇₃ \ 𝒇₂ == setdiff(𝒇₃, 𝒇₂)
    @test 𝒇₃ == 𝒇₁ ∪ 𝒇₂
    @test 𝒇₂ == 𝒇₃ ∩ 𝒇₂
end;


println("Testing FeatureArray indexing")

@testset "FeatureArray indexing" begin
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
@testset "DimArrays" begin
    x = DimArray(randn(100), (Dim{:x}(1:100),))
    @test CO_f1ecac(x)[:CO_f1ecac] == CO_f1ecac(x|>vec)
    @test catch22(x) == catch22(x|>vec)
end


println("Testing CovarianceImage")
@testset "CovarianceImage" begin
    using Plots
    using Clustering
    X = hcat(randn(100, 100), 1:100)
    F = catch22(X)
    verbose = false
    @test covarianceimage(F; colormode=:top, verbose) isa Plots.Plot
    @test covarianceimage(F; colormode=:all, verbose) isa Plots.Plot
    @test covarianceimage(F; colormode=:raw, verbose, colorbargrad=:viridis) isa Plots.Plot
end


println("Testing SuperFeatures")
@testset "SuperFeatures" begin
    𝐱 = rand(1000, 2)
    @test_nowarn Catch22.zᶠ(𝐱)
    μ = SuperFeature(Catch22.mean, :μ, ["0"], "Mean value of the z-scored time series", super=Catch22.zᶠ)
    σ = SuperFeature(Catch22.std, :σ, ["1"], "Standard deviation of the z-scored time series"; super=Catch22.zᶠ)
    𝒇 = SuperFeatureSet([μ, σ])
    @test all(isapprox.(𝒇(𝐱), [0.0 0.0; 1.0 1.0]; atol=1e-9))
end

println("Testing Catch22 SuperFeatures")
@testset "Catch22 SuperFeatures" begin
    catch22² = vcat(fill(catch22, 22)...);
    catch22_raw² = vcat(fill(Catch22.catch22_raw, 22)...);
    X = rand(1000, 10)
    @test catch22²(X) !== catch22_raw²(X)
    @test catch22_raw²(X) !== catch22_raw²(mapslices(Catch22.z_score, X, dims=1))
    @test catch22²(X) == catch22_raw²(mapslices(Catch22.z_score, X, dims=1))
    # @test catch22²[1:10] isa SuperFeatureSet # Ideally
    @test catch22_raw²[1:10](X) == catch22_raw²(X)[1:10, :]

    # @benchmark catch22_raw²(X)
    # @benchmark catch22²(X)
    # @benchmark catch22_raw²(mapslices(Catch22.z_score, X, dims=1))
    # @benchmark mapslices(Catch22.z_score, X, dims=1)
end

println("Testing ACF and PACF")
@testset "ACF and PACF" begin
    X = randn(1000, 10)
    _acf = mapslices(x->autocor(x, Catch22.ac_lags; demean=true), X; dims=1)
    @test all(ac(X) .== _acf)
    _pacf = mapslices(x->pacf(x, Catch22.ac_lags; method=:regression), X; dims=1)
    @test all(partial_ac(X) .== _pacf)
end

println("Testing PACF superfeatures")
@testset "PACF superfeatures" begin
    X = randn(1000, 10)
    lags = Catch22.ac_lags
    AC_slow = FeatureSet([x->autocor(x, [ℓ]; demean=true)[1]::Float64 for ℓ ∈ lags],
                    Symbol.(["AC_$ℓ" for ℓ ∈ lags]),
                    [["correlation"] for ℓ ∈ lags],
                    ["Autocorrelation at lag $ℓ" for ℓ ∈ lags])
    AC_partial_slow = FeatureSet([x->pacf(x, [ℓ]; method=:regression)[1]::Float64 for ℓ ∈ lags],
                    Symbol.(["AC_partial_$ℓ" for ℓ ∈ lags]),
                    [["correlation"] for ℓ ∈ lags],
                    ["Partial autocorrelation at lag $ℓ (regression method)" for ℓ ∈ lags])

    @test all(AC_slow(X) .== ac(X))
    @test all(AC_partial_slow(X) .== partial_ac(X))
    println("\nFeature autocorrelation: "); @time AC_slow(X);
    println("\nSuperFeature autocorrelation: "); @time ac(X);
    println("\nFeature partial autocorrelation: "); @time AC_partial_slow(X);
    println("\nSuperfeature partial autocorrelation: "); @time partial_ac(X);
end

@testset "Multithreading" begin
    X = randn(10000)
    meths = Catch22.featurenames
    cres = zeros(size(X)[1], length(meths))
    window=100
    f(X) = for j in eachindex(meths)
        Threads.@threads for i in 1:size(X, 1)-window
            @inbounds cres[i+window, j] = catch22[meths[j]](X[i:i+window])
        end
    end

    g(X) = Threads.@threads for i in 1:size(X, 1)-window
        @inbounds cres[i+window, :] = catch22[meths](X[i:i+window])
    end

    h(X) = catch22[meths]([X[i:i+window] for i in 1:size(X, 1)-window])

    i(X) = catch22[meths](@views [X[i:i+window] for i in 1:size(X, 1)-window])

    # BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5
    @test_nowarn f(X); # @benchmark f(X)
    @test_nowarn g(X); # @benchmark g(X)
    @test_nowarn h(X); # @benchmark h(X)
    @test_nowarn i(X); # @benchmark i(X)
end

end
