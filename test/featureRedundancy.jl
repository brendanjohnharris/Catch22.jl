using Catch22
using Clustering
using CSV
using Plots
using Statistics
using UrlDownload

pyplot()
X = urldownload("https://ndownloader.figshare.com/files/24950795", true, format=:CSV, header=false, delim=",", type=Float64, silencewarnings=true) |> Array;

nomissing = F -> F[.!ismissing.(Array(F))]
X = [nomissing(collect(x)) for x in X];

F = FeatureArray(fill(NaN, length(catch22), length(X)), catch22);
@time Threads.@threads for x ∈ 1:length(X)
    F[:, x] = catch22(Float64.(X[x]))
end

covarianceimage(mapslices(Catch22.z_score, F, dims=2), background_color_legend=nothing, foreground_color_legend=nothing, colorbar_title="|r|", colormode=:top, dpi=600)
