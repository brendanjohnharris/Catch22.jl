using SafeTestsets

# ------------------------------------------------------------------------------------------------ #
#                                               Tests                                              #
# ------------------------------------------------------------------------------------------------ #
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

# ----------------------------------- Test features one by one ----------------------------------- #
println("Testing individual features")
@testset "Feature $(getname(f))" for f ∈ catch22
        @test isnearlyequalorallnan(f(testdata[:test]), testoutput[:test][f])
end;


# ------------------------- Test catch22, time series by time series ------------------------- #
catch22(testdata[:test]) # To avoid compilation in test @time
println("Testing sample datasets")
function testFeatures(t::Symbol)
    @time f = catch22(testdata[t])
    ff = testoutput[t]
    isnearlyequalorallnan(Array(f), ff)
end
@testset "Dataset $f" for f in testnames
    @test testFeatures(f)
end;



# --------------------------------- Test catch22 on an array --------------------------------- #
println("Testing 1000×100 array input")
catch22(randn(10, 10)) # To avoid compilation in test @time
X = randn(1000, 100)
@testset "Arrays" begin
    @test_nowarn begin
        @time typeof(catch22(X)) <: FeatureMatrix
    end
end;



# ---------------------------------- Test FeatureSet operations ---------------------------------- #
println("Testing FeatureSet operations")

@testset "FeatureSet" begin
    𝒇₁ = FeatureSet([sum, length], [:sum, :length], [["distribution"], ["sampling"]], ["∑x¹", "∑x⁰"])
    𝒇₂ = catch22[1:2]
    X = randn(100, 2)
    𝒇₃ = 𝒇₁ + 𝒇₂
    @test_nowarn 𝒇₁(X)
    @test_nowarn 𝒇₃(X)
    @test_nowarn getnames(𝒇₃) == [:sum, :length , :DN_HistogramMode_5, :DN_HistogramMode_10]
    @test_nowarn 𝒇₁ == 𝒇₃ \ 𝒇₂ == setdiff(𝒇₃, 𝒇₂)
    @test_nowarn 𝒇₃ == 𝒇₁ ∪ 𝒇₂
    @test_nowarn 𝒇₂ == 𝒇₃ ∩ 𝒇₂
end;

end
