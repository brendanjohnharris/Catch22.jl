using .Clustering
using .Plots
using .Colors
using .LinearAlgebra

function clustercovariance(Σ²)
    issymmetric(Σ²) || (Σ² = cov(Σ²'))
    Dr = 1.0.-abs.(Σ²)
    if !issymmetric(Dr)
        @warn "Correlation distance matrix is not symmetric, so not clustering"
    end
    Clustering.hclust(Dr; linkage=:average, branchorder=:optimal)
end

"""
    covarianceimage(f, F; [palette=[:cornflowerblue, :crimson, :forestgreen], colormode=:top, colorbargrad=:binary, donames=true, kwargs...])
Plot the covariance matrix of the columns of an `Array`, coloring elements by their contribution to each of the top 3 principal components.
Either provide as positional arguments a vector `f` of N row names and an N×_ matrix `F`, or just a `Catch22.FeatureArray`.

# Keyword Arguments
- `palette`: a vector containing a color for each principal component.
- `colorbargrad`: the color gradient for the colorbar.
- `donames`: override `f` and display no tick labels.
- `colormode`: how to color the covariance matrix. `:raw` gives no coloring by principal components, `:top` is a combination of the top three PC colors and `:all` is a combination of all PC colors, where PCN = :black if N > length(palette).
- `docluster`: whether to perform clustering on the covariance matrix.
- `kwargs...`: other `Plots` attributes.
"""
covarianceimage
@userplot CovarianceImage
Plots.@recipe function f(g::CovarianceImage; palette=[:cornflowerblue, :crimson, :forestgreen], colormode=:top, colorbargrad=:binary, donames=true, docluster=true, verbose=true, dendrogram=false)
    if g.args[1] isa AbstractFeatureArray || g.args[1] isa AbstractDimArray
        f, Σ² = string.(getdim(g.args[1], 1)), g.args[1] |> Array
    elseif length(g.args) == 2 && g.args[2] isa AbstractMatrix
        f, Σ² = g.args[1], g.args[2] |> Array
    else
        @error "Incorrect arguments; give row names and a matrix or an annotated DimArray"
    end

    issymmetric(Σ²) || (Σ² = cov(Σ²'))

    any(diag(Σ²) .== 0) && @warn "Covariance matrix is not positive definite, which may cause an error"

    if docluster == true
        idxs = clustercovariance(Σ²).order
    elseif docluster isa Union{AbstractVector, Tuple}
        idxs = docluster # Precomputed indices
    else
        idxs = 1:size(Dr, 1)
    end
    Σ̂² = Σ²[idxs, idxs]
    A = abs.(Σ̂²)./max(abs.(Σ̂²)...)
    f̂ = f[idxs]
    N = min(length(palette), size(Σ̂², 1))
    if colormode == :raw # * Don't color by PC's
        H = abs.(Σ̂²)
        colorbar --> true
    else
        λ = (eigvals∘Symmetric∘Array)(Σ̂²)
        λi = sortperm(abs.(λ), rev=true)
        λ = λ[λi]
        P = (eigvecs∘Symmetric∘Array)(Σ̂²)[:, λi] # Now sorted by decreasing eigenvalue norm
        vidxs = sortperm(abs.(P[:, 1]), rev=true)
        verbose && isnothing(printstyled("Feature weights:\n", color=:red, bold=true)) && display(vcat(hcat("Feature", ["PC$i" for i ∈ 1:N]...) , hcat(f̂[vidxs], round.(P[vidxs, 1:N], sigdigits=3))))
        P = abs.(P)
        if colormode == :top # * Color by the number of PC's given by the length of the color palette
            P = P[:, 1:N]
            P̂ = P.^2.0./sum(P.^2.0, dims=2)
            # Square the loadings, since they are added in quadrature. Maybe not a completely faithful representation of the PC proportions, but should get the job done.
            𝑓′ = parse.(Colors.XYZ, palette[1:N]);
        elseif colormode == :all # * Color by all PC's. This can end up very brown
            Σ̂′² = Diagonal(abs.(λ))
            P̂ = P.^2.0./sum(P.^2.0, dims=2)
            p = fill(:black, size(P, 2))
            p[1:N] = palette[1:N]
            𝑓′ = parse.(Colors.XYZ, p);
            [𝑓′[i] = Σ̂′²[i, i]*𝑓′[i] for i ∈ 1:length(𝑓′)]
        end
        𝑓 = Vector{eltype(𝑓′)}(undef, size(P̂, 1))
        try # Load colors by PC weights
            𝑓 = P̂*𝑓′
        catch
            # Equivalent but slower
            @info "Iterating to load covariances"
            for ii ∈ 1:length(𝑓)
                𝑓[ii] = sum([P̂[ii, jj]*𝑓′[jj] for jj ∈ 1:length(𝑓′)])
            end
        end

        H = Array{Colors.XYZA}(undef, size(Σ̂²))
        for (i, j) ∈ Tuple.(CartesianIndices(H)) # Apply the correlations as transparencies
            J = (𝑓[i] + 𝑓[j])/2
            H[i, j] = Colors.XYZA(J.x, J.y, J.z, A[i, j])
        end
        H = convert.((Colors.RGBA,), H)
    end
    @series begin
        seriestype := :heatmap
        if colormode == :raw
            seriescolor --> colorbargrad
        end
        if backend() == Plots.GRBackend() # For some reason, GR does heatmaps differently
            xs = 0.5:1:size(H, 1)+0.5
        else
            xs = 1:size(H, 1)
        end
        (xs, xs, H)
    end
    # Plot dummy data and set attributes
    @series begin
        if dendrogram
            colorbar := false
        else
            colorbar --> true
        end
        seriestype := :scatter
        markersize := 0.0
        label := nothing
        legend := :none
        marker_z := [0, max(abs.(Σ²)...)]
        markercolor := colorbargrad
        (zeros(2), zeros(2))
    end
    for i ∈ 1:N
        @series begin
            seriestype := :shape
            if colormode != :raw
                label := "PC$i"
                legend --> :topright
                line_width := 20
            else
                label := nothing
                legend := nothing
            end
            colorbar_title --> "\$|\\Sigma^2|\$"
            colorbar_titlefontsize := 14
            xticks := :none
            size --> (800, 400)
            yflip --> true
            lims := (0.5, size(H, 1)+0.5)
            aspect_ratio := :equal
            legendfontsize := 8
            if donames
                yticks := (1:size(H, 1), replace.(string.(f̂), (r"_" => s"\\_",)))
            else
                yticks := nothing
            end
            grid := :none
            framestyle := :box
            seriescolor := palette[i]
            (Shape([0.0;], [0.0;]))
        end
    end
    if dendrogram
        @series begin
            inset_subplots := (1, bbox(0.895, 0.0, 0.1, 1.0))
            subplot := 2
            orientation := :horizontal
            yticks := nothing
            showaxis := false
            colorbar := nothing
            axis := nothing
            useheight := false
            yflip := true
            x := clustercovariance(Σ²)
        end
    end
end
