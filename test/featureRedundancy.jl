using Catch22
using Clustering
using CSV
using Plots
using StatsBase
using UrlDownload

pyplot()
X = urldownload("https://ndownloader.figshare.com/files/24950795", true, format=:CSV, header=false, delim=",", type=Float64, silencewarnings=true) |> Array; # Ignore the warnings

nomissing = F -> F[.!ismissing.(Array(F))]
X = [nomissing(collect(x)) for x in X];

F = hcat([catch22(Float64.(x)) for x in X]...); # May take a minute
Df = 1.0.-abs.(StatsBase.corspearman(F'))
idxs = Clustering.hclust(Df; linkage=:average, branchorder=:optimal).order

p2 = plot(Df[idxs, idxs], seriestype = :heatmap, aspect_ratio=:equal, xaxis=nothing)

plot!(yticks=(1:size(Df, 1), replace.(string.(Catch22.featureNames[idxs]), '_'=>"\\_")), size=(800, 400), xlims=[0.5, size(Df, 1)+0.5], ylims=[0.5, size(Df, 1)+0.5], box=:on, colorbar_title="1-|ρ|", clims=(0.0, 1.0))
