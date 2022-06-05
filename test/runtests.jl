using SafeTestsets

@safetestset "Catch22" begin
using Catch22
import Catch22.featurenames, Catch22.testdata, Catch22.testoutput, Catch22.testnames
using Test

function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray)
    replace!(a, NaN=>0.0)
    replace!(b, NaN=>0.0)
    all(map((x, y) -> isapprox(x, y, rtol=1e-5), a, b))
end
function isnearlyequalorallnan(a::Real, b::Real)
    isapprox(a, b, rtol=1e-5) || (isnan(a) && isnan(b))
end

# Test features one by one
println("Testing individual features")
@testset "Feature $(getname(f))" for f ∈ catch22
        @test isnearlyequalorallnan(f(testdata[:test]), testoutput[:test][f])
end;


# Test catch22, time series by time series
catch22(testdata[:test])
println("Testing sample datasets")
function testFeatures(t::Symbol)
    @time f = catch22(testdata[t])
    ff = testoutput[t]
    isnearlyequalorallnan(Array(f), ff)
end
@testset "Dataset $f" for f in testnames
    @test testFeatures(f)
end;



# Test catch22 on a matrix
println("Testing 1000×100 array input")
catch22(randn(10, 10))
X = randn(1000, 100)
@testset "Matrices" begin
    @test @time catch22(X) isa FeatureMatrix
end;



println("Testing 1000×20×20 array input")
catch22(randn(10, 10, 10))
X = randn(1000, 20, 20)
@testset "Arrays" begin
    @test @time catch22(X) isa FeatureArray{T, 3} where {T}
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

end
