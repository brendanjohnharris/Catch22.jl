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
function loadoutput(x)
    file = normpath(joinpath(@__DIR__, "../test/testData", String(x)*"_output.txt"))
    if isfile(file)
        out = readdlm(file, ',', comments=true)
        return Dict([Symbol(x[2][2:end])=>x[1] for x in eachrow(out)])
    else
        return nothing
    end
end

const testdata = Dict(testnames .=> map(loaddata, testnames))
const testoutput = Dict(testnames .=> map(loadoutput, testnames))
