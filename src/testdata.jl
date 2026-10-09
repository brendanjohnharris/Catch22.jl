using DelimitedFiles
using Pkg.Artifacts

artifact_toml = joinpath(pkgdir(Catch22), "Artifacts.toml")
test_hash = artifact_hash("testdata_v0_6", artifact_toml)

if test_hash == nothing || !artifact_exists(test_hash)
    test_hash = create_artifact() do artifact_dir
        test_url_base = "https://raw.githubusercontent.com/DynamicsAndNeuralSystems/catch22/068220ae5d5aac3e966104f17e8e430cf32c445d/testData"
        testfiles = [
            "basic/test.txt",
            "basic/test2.txt",
            "pathological/testInf.txt",
            "pathological/testInfMinus.txt",
            "pathological/testNaN.txt",
            "basic/testShort.txt",
            "basic/testSinusoid.txt",
            "basic/test_output.txt",
            "basic/test2_output.txt",
            "basic/testShort_output.txt",
            "basic/testSinusoid_output.txt",
        ]
        [download("$(test_url_base)/$f", joinpath(artifact_dir, basename(f))) for f in testfiles]
    end
    bind_artifact!(artifact_toml, "testdata_v0_6", test_hash)
end

test_datadir = artifact_path(test_hash)

const testnames = [
    :test
    :test2
    :testInf
    :testInfMinus
    :testNaN
    :testShort
    :testSinusoid
]

function loaddata(x)
    return reduce(
        vcat,
        readdlm(
            normpath(joinpath(test_datadir, String(x) * ".txt")), ' ', Float64,
            '\n'
        )
    )
end
function loadoutput(x)
    file = normpath(joinpath(test_datadir, String(x) * "_output.txt"))
    if isfile(file)
        out = readdlm(file, ',', comments = true)
        return Dict([Symbol(x[2][2:end]) => x[1] for x in eachrow(out)])
    else
        return nothing
    end
end

const testdata = Dict(testnames .=> map(loaddata, testnames))
const testoutput = Dict(testnames .=> map(loadoutput, testnames))
