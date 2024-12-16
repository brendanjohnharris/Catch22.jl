var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Catch22","category":"page"},{"location":"#Catch22.jl","page":"Home","title":"Catch22.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"API reference for Catch22.jl. For detailed information about the catch22 feature set, see the catch22 wiki and the original publication, Lubba et al. (2019). For further documentation, see TimeseriesFeatures.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Catch22, TimeseriesFeatures, TimeseriesFeatures.FeatureArrays, TimeseriesFeatures.Features, TimeseriesFeatures.FeatureSets]","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Catch22, TimeseriesFeatures, TimeseriesFeatures.FeatureArrays, TimeseriesFeatures.Features, TimeseriesFeatures.FeatureSets]","category":"page"},{"location":"#Catch22.c22","page":"Home","title":"Catch22.c22","text":"c22\n\nThe Catch22 feature set with shortened names; see catch22.\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.c24","page":"Home","title":"Catch22.c24","text":"c24\n\nThe Catch24 feature set with shortened names; see catch24.\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.catch22","page":"Home","title":"Catch22.catch22","text":"catch22(𝐱::Vector)\ncatch22(X::Array)\ncatch22[featurename::Symbol](X::Array)\n\nEvaluate all features for a time series vector 𝐱 or the columns of an array X. catch22 is a FeatureSet, which means it can be indexed by feature names (as symbols) to return a subset of the available features. getnames(catch22), getkeywords(catch22) and getdescriptions(catch22) will also return feature names, keywords and descriptions respectively. Features are returned in a FeatureArray, in which array rows are annotated by feature names. A FeatureArray can be converted to a regular array with Array(F).\n\nExamples\n\n𝐱 = Catch22.testdata[:test]\n𝐟 = catch22(𝐱)\n\nX = randn(100, 10)\nF = catch22(X)\nF = catch22[:DN_HistogramMode_5](X)\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.catch22_raw","page":"Home","title":"Catch22.catch22_raw","text":"The set of Catch22 features without a preliminary z-score\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.catch24","page":"Home","title":"Catch22.catch24","text":"catch24 isa FeatureSet\n\nA feature set containing the mean (DN_Mean) and standard deviation (DN_Spread_Std) in addition to all catch22 features. See catch22.\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.featuredescriptions","page":"Home","title":"Catch22.featuredescriptions","text":"Catch22.featuredescriptions\n\nA vector listing short descriptions of each feature, as strings.\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.featurekeywords","page":"Home","title":"Catch22.featurekeywords","text":"Catch22.featurekeywords\n\nA vector listing keywords of features as vectors of strings.\n\n\n\n\n\n","category":"constant"},{"location":"#Catch22.DN_HistogramMode_5","page":"Home","title":"Catch22.DN_HistogramMode_5","text":"DN_HistogramMode_5(x::AbstractVector{Union{Float64, Int}}) # For example\n\nAn alternative to catch22(:DN_HistogramMode_5](x). All features, such as DN_HistogramMode_5, are exported as Features and can be evaluated by calling their names.\n\nExamples\n\n𝐱 = Catch22.testdata[:test]\nf = DN_HistogramMode_5(𝐱)\n\n\n\n\n\n","category":"function"},{"location":"#Catch22._catch22-Tuple{AbstractVector, Symbol}","page":"Home","title":"Catch22._catch22","text":"_catch22(𝐱::AbstractArray{Float64}, fName::Symbol)\n_catch22(fName::Symbol, 𝐱::AbstractArray{Float64})\n\nEvaluate the feature fName on the single time series 𝐱. See Catch22.featuredescriptions for a summary of the 22 available time series features. Time series with NaN or Inf values will produce NaN feature values.\n\nExamples\n\n𝐱 = Catch22.testdata[:test]\nCatch22._catch22(𝐱, :DN_HistogramMode_5)\n\n\n\n\n\n","category":"method"},{"location":"#TimeseriesFeatures.RAD","page":"Home","title":"TimeseriesFeatures.RAD","text":"RAD(x, τ=1, doAbs=true)\n\nCompute the rescaled auto-density, a metric for inferring the distance to criticality that is insensitive to uncertainty in the noise strength. Calibrated to experiments on the Hopf bifurcation with variable and unknown measurement noise.\n\nInputs:     x:      The input time series (vector).     doAbs:  Whether to centre the time series at 0 then take absolute values (logical flag)     τ:      The embedding and differencing delay in units of the timestep (integer), or :τ\n\nOutputs:     f:      The RAD feature value\n\n\n\n\n\n","category":"function"},{"location":"#TimeseriesFeatures.FeatureArrays.FeatureArray","page":"Home","title":"TimeseriesFeatures.FeatureArrays.FeatureArray","text":"F = FeatureArray(data::AbstractArray, features::Union{Tuple{Symbol},Vector{Symbol}}, [timeseries::Union{Vector, Tuple}], args...)\n\nConstruct a FeatureArray, which annotates the array data with names of features along rows and, optionally, timeseries along columns. Since FeatureArray <: AbstractFeatureArray <: AbstractDimArray, further arguments to the FeatureArray constructor are passed to the DimArray constructor. To access feature names, use getnames(F).\n\nExamples\n\ndata = rand(Int, 2, 10) # Some feature matrix with 2 features and 10 timeseries\nF = FeatureArray(data, [:sum, :length])\n\n\n\n\n\n","category":"type"},{"location":"#TimeseriesFeatures.FeatureArrays.FeatureMatrix","page":"Home","title":"TimeseriesFeatures.FeatureArrays.FeatureMatrix","text":"FeatureArray{T, 2} where {T}\n\nAn alias to construct a FeatureArray for a flat set of timeseries.\n\nExamples\n\ndata = rand(Int, 2, 3) # Some feature matrix with 2 features and 3 timeseries\nF = FeatureMatrix(data, [:sum, :length], [1, 2, 3])\n\n\n\n\n\n","category":"type"},{"location":"#TimeseriesFeatures.FeatureArrays.FeatureVector","page":"Home","title":"TimeseriesFeatures.FeatureArrays.FeatureVector","text":"FeatureArray{T, 1} where {T}\n\nAn alias to construct a FeatureArray for a single time series.\n\nExamples\n\ndata = randn(2) # Feature values for 1 time series\n𝐟 = FeatureVector(data, [:sum, :length])\n\n\n\n\n\n","category":"type"},{"location":"#TimeseriesFeatures.FeatureArrays.featureDims-Tuple{DimensionalData.AbstractDimArray}","page":"Home","title":"TimeseriesFeatures.FeatureArrays.featureDims","text":"getnames(𝒇::FeatureArray)\n\nGet the names of features represented in the feature vector or array 𝒇 as a vector of symbols.\n\n\n\n\n\n","category":"method"},{"location":"#TimeseriesFeatures.Features.AbstractFeature","page":"Home","title":"TimeseriesFeatures.Features.AbstractFeature","text":"AbstractFeature has a loose interface. Overload (𝑓::AbstractFeature)(x) for different functionality. For compatibility with other TimeseresFeatures types, define:\n\nHelper methods:\n\ngetmethod(𝑓::AbstractFeature)\n`getname(𝑓::AbstractFeature)\n`getkeywords(𝑓::AbstractFeature)\ngetdescription(𝑓::AbstractFeature)\n\n\n\n\n\n","category":"type"},{"location":"#TimeseriesFeatures.Features.Feature","page":"Home","title":"TimeseriesFeatures.Features.Feature","text":"𝑓 = Feature([;] method::Function, name=Symbol(method), description=\"\", keywords=\"\")\n\nConstruct a Feature, which is a function annotated with a name, keywords and short description. Features can be called as functions while getname(𝑓), getkeywords(𝑓) and getdescription(𝑓) can be used to access the annotations. The function should have at minimum a method for AbstractVector. The method on vectors will be applied column-wise to Matrix inputs, regardless of the function methods defined for Matrix.\n\nExamples\n\n𝑓 = Feature(sum, :sum, [\"distribution\"], \"Sum of time-series values\")\n𝑓(1:10) # == sum(1:10) == 55\ngetdescription(𝑓) # \"Sum of time-series values\"\n\n\n\n\n\n","category":"type"},{"location":"#TimeseriesFeatures.FeatureSets.FeatureSet","page":"Home","title":"TimeseriesFeatures.FeatureSets.FeatureSet","text":"FeatureSet(methods, [names, descriptions, keywords])\nFeatureSet(features::Vector{T}) where {T <: AbstractFeature}\n\nConstruct a FeatureSet from methods (a vector of functions) and optionally provide names as a vector of symbols, descriptions as a vector of strings, and keywords as a vector of vectors of strings. A FeatureSet can be called on a time-series vector or matrix X (with time series occupying columns) to return a FeatureArray of feature values. Subsets of a FeatureSet 𝒇 can be obtained by indexing with feature names (as symbols) or the regular linear and logical indices. FeatureSets also support simple set operations defined for arrays, such as unions and intersections, as well as convenient syntax for concatenation (+) and set differencing (\\). Note that two features are considered the same (`isequal') if and only if their names are equal.\n\nExamples\n\n𝒇 = FeatureSet([sum, length], [:sum, :length], [\"∑x¹\", \"∑x⁰\"], [[\"distribution\"], [\"sampling\"]])\nX = randn(100, 2) # 2 time series, 100 samples long\nF = 𝒇(X)\n\n# Joining feature sets\n𝒇₁ = FeatureSet([x->min(x...), x->max(x...)], [:min, :max], [\"minimum\", \"maximum\"], [[\"distribution\"], [\"distribution\"]])\n𝒈₁ = 𝒇 + 𝒇₁\nG = 𝒈₁(X)\n\n# Intersecting feature sets, where features are identified exclusively by their names\n𝒇₂ = FeatureSet(x->prod, :sum, \"∏x\", [\"distributions\"])\n𝒈₂ = 𝒇 ∩ 𝒇₂ # The intersection of two feature sets, both with their own :sum\nG = 𝒈₂(X) # The intersection contains the :sum of the first argument to ∩; 𝒇\n\n\n\n\n\n","category":"type"}]
}
