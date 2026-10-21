using DelimitedFiles
using Pkg.Artifacts

artifact_toml = joinpath(pkgdir(Catch22), "Artifacts.toml")
test_hash = artifact_hash("testdata_v1_2", artifact_toml)

if test_hash == nothing || !artifact_exists(test_hash)
    test_hash = create_artifact() do artifact_dir
        # the expected outputs are catch24 with masking, as run_features writes them
        test_url_base = "https://raw.githubusercontent.com/DynamicsAndNeuralSystems/catch22/v1.2.0/testData"
        testfiles = [
            "basic/test.txt",
            "basic/test2.txt",
            "basic/testShort.txt",
            "basic/testSinusoid.txt",
            "pathological/testConstant.txt",
            "pathological/testInf.txt",
            "pathological/testInfMinus.txt",
            "pathological/testNaN.txt",
            "pathological/testOneSample.txt",
        ]
        for f in testfiles, g in (f, replace(f, ".txt" => "_output.txt"))
            download("$(test_url_base)/$g", joinpath(artifact_dir, basename(g)))
        end
    end
    bind_artifact!(artifact_toml, "testdata_v1_2", test_hash)
end

test_datadir = artifact_path(test_hash)

const testnames = [
    :test
    :test2
    :testShort
    :testSinusoid
    :testConstant
    :testInf
    :testInfMinus
    :testNaN
    :testOneSample
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
