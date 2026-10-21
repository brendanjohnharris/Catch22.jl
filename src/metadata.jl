# Feature names in the order of the C library (catch22_feature_name(i) for i = 0:21, then
# mean and std); featureList.txt in DynamicsAndNeuralSystems/catch22 is the source.
# Long names are hctsa's, short names are for readability, and legacy names are the
# catch22 v0.x long names (bound as deprecated aliases in Catch22.jl).
const featurenames = [
    :DN_HistogramMode_5
    :DN_HistogramMode_10
    :DN_OutlierInclude_p_001_mdrmd
    :DN_OutlierInclude_n_001_mdrmd
    :CO_FirstCrossing_acf_1e_pointOfCrossing
    :CO_FirstMin_ac
    :SP_Summaries_fft_area_5_1
    :SP_Summaries_fft_wq_50
    :FC_LocalSimple_mean3_stde
    :FC_LocalSimple_mean1_taurat
    :MD_pNN_pnn40
    :SB_BinaryStats_mean_longstretch1
    :SB_BinaryStats_diff_longstretch0
    :SB_MotifThree_quantile_hh
    :CO_HistogramAMI_even_5bin_ami2
    :CO_trev_1_num
    :IN_AutoMutualInfoStats_40_gaussian_fmmi
    :SB_TransitionMatrix_quantile_3_ac_sumdiagcov
    :PD_PeriodicityWang_th0_01
    :CO_Embed2_Dist_tau_d_expfit_meandiff
    :SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
    :SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
]

const short_featurenames = [
    :mode_5
    :mode_10
    :outlier_timing_pos
    :outlier_timing_neg
    :acf_timescale
    :acf_first_min
    :low_freq_power
    :median_freq
    :forecast_error
    :whiten_timescale
    :high_fluctuation
    :stretch_high
    :stretch_decreasing
    :entropy_pairs
    :ami2
    :trev
    :ami_timescale
    :transition_variance
    :periodicity
    :embedding_dist
    :rs_range
    :dfa
]

const legacy_featurenames = [
    :DN_HistogramMode_5
    :DN_HistogramMode_10
    :DN_OutlierInclude_p_001_mdrmd
    :DN_OutlierInclude_n_001_mdrmd
    :CO_f1ecac
    :CO_FirstMin_ac
    :SP_Summaries_welch_rect_area_5_1
    :SP_Summaries_welch_rect_centroid
    :FC_LocalSimple_mean3_stderr
    :FC_LocalSimple_mean1_tauresrat
    :MD_hrv_classic_pnn40
    :SB_BinaryStats_mean_longstretch1
    :SB_BinaryStats_diff_longstretch0
    :SB_MotifThree_quantile_hh
    :CO_HistogramAMI_even_2_5
    :CO_trev_1_num
    :IN_AutoMutualInfoStats_40_gaussian_fmmi
    :SB_TransitionMatrix_3ac_sumdiagcov
    :PD_PeriodicityWang_th0_01
    :CO_Embed2_Dist_tau_d_expfit_meandiff
    :SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
    :SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
]

const catch24_featurenames = [featurenames..., :DN_mean, :DN_Spread_std]
const short_catch24_featurenames = [short_featurenames..., :mean, :std]
const legacy_catch24_featurenames = [legacy_featurenames..., :DN_Mean, :DN_Spread_Std]

"""
    Catch22.featurekeywords
A vector listing keywords of features as vectors of strings.
"""
const featurekeywords = [ # See hctsa
    #DN_HistogramMode_5
    ["distribution", "location"],
    #DN_HistogramMode_10
    ["distribution", "location"],
    #DN_OutlierInclude_p_001_mdrmd
    ["distribution", "outliers"],
    #DN_OutlierInclude_n_001_mdrmd
    ["distribution", "outliers"],
    #CO_FirstCrossing_acf_1e_pointOfCrossing
    ["correlation", "timescale"],
    #CO_FirstMin_ac
    ["correlation", "timescale"],
    #SP_Summaries_fft_area_5_1
    ["FourierSpectrum"],
    #SP_Summaries_fft_wq_50
    ["FourierSpectrum"],
    #FC_LocalSimple_mean3_stde
    ["forecasting"],
    #FC_LocalSimple_mean1_taurat
    ["forecasting"],
    #MD_pNN_pnn40
    ["medical"],
    #SB_BinaryStats_mean_longstretch1
    ["distribution", "stationarity"],
    #SB_BinaryStats_diff_longstretch0
    ["distribution", "stationarity"],
    #SB_MotifThree_quantile_hh
    ["symbolic", "motifs"],
    #CO_HistogramAMI_even_5bin_ami2
    ["information", "correlation", "AMI"],
    #CO_trev_1_num
    ["correlation", "nonlinear"],
    #IN_AutoMutualInfoStats_40_gaussian_fmmi
    ["information", "correlation", "AMI"],
    #SB_TransitionMatrix_quantile_3_ac_sumdiagcov
    ["symbolic", "transitionmat"],
    #PD_PeriodicityWang_th0_01
    ["periodicity", "spline"],
    #CO_Embed2_Dist_tau_d_expfit_meandiff
    ["correlation", "embedding"],
    #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
    ["scaling"],
    #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
    ["scaling"],
]

"""
    Catch22.featuredescriptions
A vector listing short descriptions of each feature, as strings.
"""
const featuredescriptions = [  # See catch22 paper
    #DN_HistogramMode_5
    "Mode of z-scored distribution (5-bin histogram)"
    #DN_HistogramMode_10
    "Mode of z-scored distribution (10-bin histogram)"
    #DN_OutlierInclude_p_001_mdrmd
    "Time intervals between successive extreme events above the mean"
    #DN_OutlierInclude_n_001_mdrmd
    "Time intervals between successive extreme events below the mean"
    #CO_FirstCrossing_acf_1e_pointOfCrossing
    "First 1/𝑒 crossing of autocorrelation function"
    #CO_FirstMin_ac
    "First minimum of autocorrelation function"
    #SP_Summaries_fft_area_5_1
    "Total power in lowest fifth of frequencies in the Fourier power spectrum"
    #SP_Summaries_fft_wq_50
    "Median frequency of the Fourier power spectrum"
    #FC_LocalSimple_mean3_stde
    "Mean error from a rolling 3-sample mean forecasting"
    #FC_LocalSimple_mean1_taurat
    "Change in correlation length after iterative differencing"
    #MD_pNN_pnn40
    "Proportion of successive differences exceeding 0.04𝜎 (Mietus 2002)"
    #SB_BinaryStats_mean_longstretch1
    "Longest period of consecutive values above the mean"
    #SB_BinaryStats_diff_longstretch0
    "Longest period of successive incremental decreases"
    #SB_MotifThree_quantile_hh
    "Shannon entropy of two successive letters in equiprobable 3-letter symbolization"
    #CO_HistogramAMI_even_5bin_ami2
    "Automutual information at lag 2 (5 even bins)"
    #CO_trev_1_num
    "Time-reversibility statistic, ⟨(𝑥ₜ₊₁−𝑥ₜ)³⟩ₜ"
    #IN_AutoMutualInfoStats_40_gaussian_fmmi
    "First minimum of the automutual information function"
    #SB_TransitionMatrix_quantile_3_ac_sumdiagcov
    "Trace of covariance of transition matrix between symbols in 3-letter alphabet"
    #PD_PeriodicityWang_th0_01
    "Periodicity measure of (Wang et al. 2007)"
    #CO_Embed2_Dist_tau_d_expfit_meandiff
    "Exponential fit to successive distances in 2-d embedding space"
    #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
    "Proportion of slower timescale fluctuations that scale with linearly rescaled range fits"
    #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
    "Proportion of slower timescale fluctuations that scale with DFA (50% sampling)"
]
