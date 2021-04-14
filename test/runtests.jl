using SafeTestsets

# ------------------------------------------------------------------------------------------------ #
#                                               Tests                                              #
# ------------------------------------------------------------------------------------------------ #
@safetestset "Catch22" begin
using Catch22
import Catch22.featureNames, Catch22.testData, Catch22.testOutput, Catch22.testNames
using Test

function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray) # Must be a nicer way
    replace!(a, NaN=>0.0)
    replace!(b, NaN=>0.0)
    all(map((x, y) -> isapprox(x, y, rtol=1e-5), a, b))
end
function isnearlyequalorallnan(a::Real, b::Real)
    isapprox(a, b, rtol=1e-5) || (isnan(a) && isnan(b))
end
# ----------------------------------- Test features one by one ----------------------------------- #
println("Testing individual features")
fs = catch22.(featureNames, (testData[:test],))
arbIdx = 1
@testset "Features $f" for f in featureNames
        @test isnearlyequalorallnan(fs[arbIdx], testOutput[:test][arbIdx])
        arbIdx += 1
        # Assumes the test outputs are written in the same order as featureNames
end


# ------------------------- Test catch22, time series by time series ------------------------- #
println("Testing sample datasets")
function testFeatures(t::Symbol)
    f = catch22(testData[t])
    @time f = catch22(testData[t])
    ff = testOutput[t]
    isnearlyequalorallnan(f, ff)
end
# X = hcat(map(x -> get(testOutput, x, NaN), testNames)...)
@testset "Datasets $f" for f in testNames
    @test testFeatures(f)
end



# --------------------------------- Test catch22 on an array --------------------------------- #
println("Testing 1000×100 array input")
X = randn(1000, 100)
@testset "Arrays" begin
    @test_nowarn begin
        catch22(X)
        @time catch22(X)
    end
end;

end
