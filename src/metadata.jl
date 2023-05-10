const featurenames = [
    :DN_HistogramMode_5
    :DN_HistogramMode_10
    :CO_Embed2_Dist_tau_d_expfit_meandiff
    :CO_f1ecac
    :CO_FirstMin_ac
    :CO_HistogramAMI_even_2_5
    :CO_trev_1_num
    :DN_OutlierInclude_p_001_mdrmd
    :DN_OutlierInclude_n_001_mdrmd
    :FC_LocalSimple_mean1_tauresrat
    :FC_LocalSimple_mean3_stderr
    :IN_AutoMutualInfoStats_40_gaussian_fmmi
    :MD_hrv_classic_pnn40
    :SB_BinaryStats_diff_longstretch0
    :SB_BinaryStats_mean_longstretch1
    :SB_MotifThree_quantile_hh
    :SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
    :SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
    :SP_Summaries_welch_rect_area_5_1
    :SP_Summaries_welch_rect_centroid
    :SB_TransitionMatrix_3ac_sumdiagcov
    :PD_PeriodicityWang_th0_01]

const catch24_featurenames = [featurenames..., :DN_Mean, :DN_Spread_Std]

const featuretypes = Dict(featurenames .=> [
                                    #DN_HistogramMode_5
                                    Cdouble
                                    #DN_HistogramMode_10
                                    Cdouble
                                    #CO_Embed2_Dist_tau_d_expfit_meandiff
                                    Cdouble
                                    #CO_f1ecac
                                    Cdouble
                                    #CO_FirstMin_ac
                                    Cint
                                    #CO_HistogramAMI_even_2_5
                                    Cdouble
                                    #CO_trev_1_num
                                    Cdouble
                                    #DN_OutlierInclude_p_001_mdrmd
                                    Cdouble
                                    #DN_OutlierInclude_n_001_mdrmd
                                    Cdouble
                                    #FC_LocalSimple_mean1_tauresrat
                                    Cdouble
                                    #FC_LocalSimple_mean3_stderr
                                    Cdouble
                                    #IN_AutoMutualInfoStats_40_gaussian_fmmi
                                    Cdouble
                                    #MD_hrv_classic_pnn40
                                    Cdouble
                                    #SB_BinaryStats_diff_longstretch0
                                    Cdouble
                                    #SB_BinaryStats_mean_longstretch1
                                    Cdouble
                                    #SB_MotifThree_quantile_hh
                                    Cdouble
                                    #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
                                    Cdouble
                                    #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
                                    Cdouble
                                    #SP_Summaries_welch_rect_area_5_1
                                    Cdouble
                                    #SP_Summaries_welch_rect_centroid
                                    Cdouble
                                    #SB_TransitionMatrix_3ac_sumdiagcov
                                    Cdouble
                                    #PD_PeriodicityWang_th0_01
                                    Cint])


"""
    Catch22.featurekeywords
A vector listing keywords of features as vectors of strings.
"""
const featurekeywords = [ # See hctsa
                                    #DN_HistogramMode_5
                                    ["distribution", "location"],
                                    #DN_HistogramMode_10
                                    ["distribution", "location"],
                                    #CO_Embed2_Dist_tau_d_expfit_meandiff
                                    ["correlation", "embedding"],
                                    #CO_f1ecac
                                    ["correlation", "timescale"],
                                    #CO_FirstMin_ac
                                    ["correlation", "timescale"],
                                    #CO_HistogramAMI_even_2_5
                                    ["information", "correlation", "AMI"],
                                    #CO_trev_1_num
                                    ["correlation", "nonlinear"],
                                    #DN_OutlierInclude_p_001_mdrmd
                                    ["distribution", "outliers"],
                                    #DN_OutlierInclude_n_001_mdrmd
                                    ["distribution", "outliers"],
                                    #FC_LocalSimple_mean1_tauresrat
                                    ["forecasting"],
                                    #FC_LocalSimple_mean3_stderr
                                    ["forecasting"],
                                    #IN_AutoMutualInfoStats_40_gaussian_fmmi
                                    ["information", "correlation", "AMI"],
                                    #MD_hrv_classic_pnn40
                                    ["medical"],
                                    #SB_BinaryStats_diff_longstretch0
                                    ["distribution", "stationarity"],
                                    #SB_BinaryStats_mean_longstretch1
                                    ["distribution", "stationarity"],
                                    #SB_MotifThree_quantile_hh
                                    ["symbolic", "motifs"],
                                    #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
                                    ["scaling"],
                                    #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
                                    ["scaling"],
                                    #SP_Summaries_welch_rect_area_5_1
                                    ["FourierSpectrum"],
                                    #SP_Summaries_welch_rect_centroid
                                    ["FourierSpectrum"],
                                    #SB_TransitionMatrix_3ac_sumdiagcov
                                    ["symbolic", "transitionmat"],
                                    #PD_PeriodicityWang_th0_01
                                    ["periodicity", "spline"]]


"""
    Catch22.featuredescriptions
A vector listing short descriptions of each feature, as strings.
"""
const featuredescriptions = [  # See catch22 paper
                                    #DN_HistogramMode_5
                                    "Mode of z-scored distribution (5-bin histogram)"
                                    #DN_HistogramMode_10
                                    "Mode of z-scored distribution (10-bin histogram)"
                                    #CO_Embed2_Dist_tau_d_expfit_meandiff
                                    "Exponential fit to successive distances in 2-d embedding space"
                                    #CO_f1ecac
                                    "First 1/𝑒 crossing of autocorrelation function"
                                    #CO_FirstMin_ac
                                    "First minimum of autocorrelation function"
                                    #CO_HistogramAMI_even_2_5
                                    "Automutual information, 𝑚=2,𝜏=5"
                                    #CO_trev_1_num
                                    "Time-reversibility statistic, ⟨(𝑥ₜ₊₁−𝑥ₜ)³⟩ₜ"
                                    #DN_OutlierInclude_p_001_mdrmd
                                    "Time intervals between successive extreme events above the mean"
                                    #DN_OutlierInclude_n_001_mdrmd
                                    "Time intervals between successive extreme events below the mean"
                                    #FC_LocalSimple_mean1_tauresrat
                                    "Change in correlation length after iterative differencing"
                                    #FC_LocalSimple_mean3_stderr
                                    "Mean error from a rolling 3-sample mean forecasting"
                                    #IN_AutoMutualInfoStats_40_gaussian_fmmi
                                    "First minimum of the automutual information function"
                                    #MD_hrv_classic_pnn40
                                    "Proportion of successive differences exceeding 0.04𝜎 (Mietus 2002)"
                                    #SB_BinaryStats_diff_longstretch0
                                    "Longest period of successive incremental decreases"
                                    #SB_BinaryStats_mean_longstretch1
                                    "Longest period of consecutive values above the mean"
                                    #SB_MotifThree_quantile_hh
                                    "Shannon entropy of two successive letters in equiprobable 3-letter symbolization"
                                    #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
                                    "Proportion of slower timescale fluctuations that scale with linearly rescaled range fits"
                                    #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
                                    "Proportion of slower timescale fluctuations that scale with DFA (50% sampling)"
                                    #SP_Summaries_welch_rect_area_5_1
                                    "Total power in lowest fifth of frequencies in the Fourier power spectrum"
                                    #SP_Summaries_welch_rect_centroid
                                    "Centroid of the Fourier power spectrum"
                                    #SB_TransitionMatrix_3ac_sumdiagcov
                                    "Trace of covariance of transition matrix between symbols in 3-letter alphabet"
                                    #PD_PeriodicityWang_th0_01
                                    "Periodicity measure of (Wang et al. 2007)"]
