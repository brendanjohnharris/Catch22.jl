using SafeTestsets

# ------------------------------------------------------------------------------------------------ #
#                                               Tests                                              #
# ------------------------------------------------------------------------------------------------ #
@safetestset "catch22.jl" begin
using catch22
import catch22.featureNames, catch22.testData, catch22.testOutput, catch22.testNames
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
fs = catch1.(featureNames, (testData[:test],))
arbIdx = 1 # These are tests, so efficiency not too important?
@testset "Features $f" for f in featureNames
        @test isnearlyequalorallnan(fs[arbIdx], testOutput[:test][arbIdx])
        arbIdx += 1
        # Assumes the test outputs are written in the same order as featureNames
end


# ------------------------- Test catch22_all, time series by time series ------------------------- #
function testFeatures(t::Symbol)
    f = catch22_all(testData[t])
    ff = testOutput[t]
    isnearlyequalorallnan(f, ff)
end
# X = hcat(map(x -> get(testOutput, x, NaN), testNames)...)
@testset "Datasets $f" for f in testNames
        @test testFeatures(f)
end



# --------------------------------- Test catch22_all on an array --------------------------------- #
X = randn(1000, 100)
@testset "Arrays" begin
    @test_nowarn catch22_all(X)
end;


end
