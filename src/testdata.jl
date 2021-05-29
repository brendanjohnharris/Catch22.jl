using DelimitedFiles

const testnames = [
    :test
    :test2
    :testInf
    :testInfMinus
    :testNaN
    :testShort
    :testSinusoid
]

loaddata(x) = reduce(vcat, readdlm(normpath(joinpath(@__DIR__, "../test/testData", String(x)*".txt")), ' ', Float64, '\n'))
loadoutput(x) =  FeatureVector(reduce(vcat, readdlm(normpath(joinpath(@__DIR__, "../test/testData", String(x)*"_output.txt")), ' ', Float64, '\n', comments=true)), featurenames)

const testdata = Dict(testnames .=> map(loaddata, testnames))
const testoutput = Dict(testnames .=> map(loadoutput, testnames))
