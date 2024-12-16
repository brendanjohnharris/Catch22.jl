using Catch22
using Catch22.DimensionalData
using Catch22.DelimitedFiles
using BenchmarkTools
using JLD2
using CairoMakie

featureset = Catch22.catch22_raw
N⃗ = Int.(round.(exp10.(2:0.25:5)));
scaling = DimArray(zeros(length(featureset), 2, length(N⃗)),
                   (Feat(getnames(featureset)), Dim{:resource}([:time, :memory]),
                    Dim{:length}(N⃗)))

for f in featureset
    @info "Benchmarking $f"
    for N in N⃗
        log = @benchmark $f(x) setup=(x = randn($N)) seconds=2 samples=100
        log = median(log)
        scaling[At(f.name), At(:time), At(N)] = log |> time # * Time in nanoseconds!
        scaling[At(f.name), At(:memory), At(N)] = log |> memory
    end
end
file = joinpath(@__DIR__, "feature_scaling.jld2")
rm(file, force = true)
save(file, Dict("scaling" => scaling))

begin
    f = Figure()
    ax = Axis(f[1, 1]; xscale = log10, yscale = log10)
    map(eachslice(scaling[resource = At(:time)], dims = Feat)) do x
        lines!(ax, x)
    end
end

exponent = mapslices(scaling, dims = 3) do x
    b, m = [ones(length(N⃗)) log10.(N⃗)] \ log10.(x)
    # plot(log10.(N⃗), log10.(x))
    # lines!(log10.(N⃗), m.*log10.(N⃗) .+ b)
    # current_figure()
    return m
end
exponent = dropdims(exponent, dims = 3)

file = joinpath(@__DIR__, "scaling_exponents.csv")
rm(file, force = true)
out = [lookup(exponent, 1) round.(collect(exponent), sigdigits = 5)]
out = [hcat("feature", "time exponent", "memory exponent"); out]
writedlm(file, out, ',')
