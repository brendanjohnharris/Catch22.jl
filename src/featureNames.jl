featureNames = [
    :DN_HistogramMode_5 # These shouldn't change between versions of catch22
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

featureDescriptions = [ # See catch22 paper
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
    ""
    #DN_OutlierInclude_n_001_mdrmd
    ""
    #FC_LocalSimple_mean1_tauresrat
    ""
    #FC_LocalSimple_mean3_stderr
    ""
    #IN_AutoMutualInfoStats_40_gaussian_fmmi
    ""
    #MD_hrv_classic_pnn40
    ""
    #SB_BinaryStats_diff_longstretch0
    ""
    #SB_BinaryStats_mean_longstretch1
    ""
    #SB_MotifThree_quantile_hh
    ""
    #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
    ""
    #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
    ""
    #SP_Summaries_welch_rect_area_5_1
    ""
    #SP_Summaries_welch_rect_centroid
    ""
    #SB_TransitionMatrix_3ac_sumdiagcov
    ""
    #PD_PeriodicityWang_th0_01
    ""]

features = Dict(featureNames .=> featureDescriptions)

"""
    features()

A dictionary list of feature names, as symbols, and short descriptions, as strings.

# Examples
```@repl
catch22.features()
```
```@eval
catch22.features()
```
"""
features() = features