using Catch22
using Catch22.DimensionalData
import Catch22.testdata, Catch22.testoutput, Catch22.testnames
using Test
using StatsBase
# using BenchmarkTools

function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray)
    replace!(a, NaN => 0.0)
    replace!(b, NaN => 0.0)
    all(isapprox.(a, b, atol=1e-6))
end
function isnearlyequalorallnan(a::Real, b::Real)
    isapprox(a, b, atol=1e-6) || (isnan(a) && isnan(b))
end

# Test features one by one
println("Testing individual features")
@testset "Feature $(getname(f))" for f in catch24
    if f in catch22
        @inferred Catch22._catch22(testdata[:test], getname(f))
        @inferred Catch22._catch22(randn(100, 10), getname(f))
    end
    @test isnearlyequalorallnan(f(testdata[:test]), testoutput[:test][getname(f)])
end

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
end

# Test catch22 on a matrix
println("Testing 1000×100 array input")
catch22(randn(10, 10))
X = randn(1000, 100)
@testset "Matrices" begin
    @test @time catch24(X) isa FeatureMatrix
end

# Test short name version is the same as the full version
println("Testing short names, c22")
@testset "Short names" begin
    @test parent(catch24(X)) == parent(c24(X))
end

println("Testing 1000×20×20 array input")
catch22(randn(10, 10, 10))
X = randn(1000, 20, 20)
@testset "Arrays" begin
    @test @time catch24(X) isa FeatureArray{T,3} where {T}
end

println("Testing input types")
X = rand(Int16, 10, 10, 10)
_F = catch24(X)
@testset "Types" begin
    @test eltype(_F) <: Float64
    for T in [Int, Int32, Float32, Float64]
        F = catch24(T.(X))
        @test eltype(F) <: Float64
        @test F ≈ _F
        @test F[DN_Mean] ≈ dropdims(mean(T.(X), dims=1), dims=1)
        @test F[DN_Spread_Std] ≈ dropdims(std(T.(X), dims=1), dims=1)
    end
end

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
    @test first(CO_f1ecac(x)) == CO_f1ecac(x |> vec)
    @test length(CO_f1ecac(x)) == 1
    @test catch22(x) == catch22(x |> vec)
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
    @test covarianceimage(F; colormode=:raw, verbose, colorbargrad=:viridis) isa
          Plots.Plot
end

println("Testing SuperFeatures")
@testset "SuperFeatures" begin
    𝐱 = rand(1000, 2)
    @test_nowarn Catch22.zᶠ(𝐱)
    μ = SuperFeature(Catch22.mean, :μ, ["0"], "Mean value of the z-scored time series",
        super=Catch22.zᶠ)
    σ = SuperFeature(Catch22.std, :σ, ["1"],
        "Standard deviation of the z-scored time series";
        super=Catch22.zᶠ)
    𝒇 = SuperFeatureSet([μ, σ])
    @test all(isapprox.(𝒇(𝐱), [0.0 0.0; 1.0 1.0]; atol=1e-9))
end

println("Testing Catch22 SuperFeatures")
@testset "Catch22 SuperFeatures" begin
    catch22² = vcat(fill(catch22, 22)...)
    catch22_raw² = vcat(fill(Catch22.catch22_raw, 22)...)
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

@testset "Multithreading" begin
    X = randn(10000)
    meths = Catch22.featurenames
    cres = zeros(size(X)[1], length(meths))
    window = 100
    f(X) =
        for j in eachindex(meths)
            Threads.@threads for i in 1:(size(X, 1)-window)
                @inbounds cres[i+window, j] = catch22[meths[j]](X[i:(i+window)])
            end
        end

    g(X) = Threads.@threads for i in 1:(size(X, 1)-window)
        @inbounds cres[i+window, :] = catch22[meths](X[i:(i+window)])
    end

    h(X) = catch22[meths]([X[i:(i+window)] for i in 1:(size(X, 1)-window)])

    i(X) = catch22[meths](@views [X[i:(i+window)] for i in 1:(size(X, 1)-window)])

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
