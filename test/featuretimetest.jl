using Catch22, CairoMakie, Normalization

# ? Calculate
𝒳 = round.(Int, 1:0.1:5 .|> exp10) .|> randn
run() = [(@timed f(x)).time for f in catch22, x in 𝒳]
T = run()
T = MinMax(T, dims=1)(T)

# ? Plot
f = Figure(resolution=(1080, 720));
ax = Axis(f[1, 1]; ylabel="Feature", xlabel="Length (samples)", yticks=(1:length(catch22), string.(getnames(catch22))));
p = heatmap!(ax, length.(𝒳), 1:length(catch22), T')
Colorbar(f[1, 2], p, label="Normalized time")
f
save("./test/featuretimetest.pdf", f)
