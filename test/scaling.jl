using Catch22
using Plots

function timeCatch22(𝒳)
    t⃗ = [(@timed catch22(𝐱)) for 𝐱 ∈ 𝒳]
    ([x.time for x in t⃗], [x.bytes for x in t⃗])
end

N⃗ = Int.(round.(exp10.(1:0.1:5)));
𝒳 = [randn(N) for N ∈ N⃗];
t⃗, b⃗ = timeCatch22(𝒳);


plot(N⃗, t⃗, scale=:log10, label=:none, color=:black, markersize=2, marker=:o, right_margin=15Plots.mm)
plot!(xguide="Time-series Length", yguide="Time (s)", framestyle=:box, minorticks=true)

plot!(twinx(), N⃗, b⃗, scale=:log10, label=:none, seriescolor=:red, markersize=2, markershape=:circle, markerstrokewidth=0, grid=:off, yguide="Memory (bytes)", foreground_color_guide=:red, minorticks=true)
