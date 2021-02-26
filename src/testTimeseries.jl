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


testData = Dict(testNames .=> map(x -> reduce(vcat, readdlm(normpath(joinpath(@__DIR__, "../test/testData", String(x)*".txt")), ' ', Float64, '\n')), testNames))

testOutput = Dict(testNames .=> map(x -> reduce(vcat, readdlm(normpath(joinpath(@__DIR__, "../test/testData", String(x)*"_output.txt")), ' ', Float64, '\n', comments=true)), testNames))
