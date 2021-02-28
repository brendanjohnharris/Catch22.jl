using DelimitedFiles

testNames = [
    :test
    :test2
    :testInf
    :testInfMinus
    :testNaN
    :testShort
    :testSinusoid
]

# -------------------------------- Load test timeseries into dict -------------------------------- #
testData = Dict(testNames .=> map(x -> reduce(vcat, readdlm(normpath(joinpath(@__DIR__, "../test/testData", String(x)*".txt")), ' ', Float64, '\n')), testNames))


# ---------------------------- Load expected feature outputs into dict --------------------------- #
testOutput = Dict(testNames .=> map(x -> reduce(vcat, readdlm(normpath(joinpath(@__DIR__, "../test/testData", String(x)*"_output.txt")), ' ', Float64, '\n', comments=true)), testNames))
