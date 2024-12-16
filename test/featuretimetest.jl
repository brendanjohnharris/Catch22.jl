using Catch22
using CairoMakie
using Normalization
using Statistics

# ? Calculate
𝒳 = round.(Int, 1:0.1:5 .|> exp10) .|> randn
run() = [[(@timed f(x)).time for _ in 1:50] for f in catch22, x in 𝒳]
T = median.(run()) # Time in seconds
T̂ = MinMax(T, dims = 1)(T)

begin # ? Plot
    f = Figure(size = (1080, 720))
    ax = Axis(f[1, 1]; ylabel = "Feature", xlabel = "Length (samples)",
              yticks = (1:length(catch22), string.(getnames(catch22))), xscale = log10)
    p = heatmap!(ax, length.(𝒳), 1:length(catch22), T̂')
    Colorbar(f[1, 2], p, label = "Normalized time")
    save(joinpath(@__DIR__, "featuretimetest.pdf"), f)
    f
end
