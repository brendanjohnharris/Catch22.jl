using Catch22
using Documenter

DocMeta.setdocmeta!(Catch22, :DocTestSetup, :(using Catch22); recursive=true)

makedocs(;
    modules=[Catch22, Features],
    authors="brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
    repo="https://github.com/brendanjohnharris/Catch22.jl/blob/{commit}{path}#{line}",
    sitename="Catch22.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Features" => "features.md",
        "FeatureSets" => "featuresets.md",
        "FeatureArrays" => "featurearrays.md",
    ],
)

deploydocs(
    repo = "github.com/brendanjohnharris/Catch22.jl.git",
)
