# Changelog

## [0.7.1] - 2026-08-17

- Compat: `catch22_jll` 0.6, `DimensionalData` 0.30, `TimeseriesFeatures` 0.7.
- Formatting switched to Runic; nightly CI runs.

## [0.7.0] - 2024-12-16

- Reworked internal types for type stability and performance.
- Fixed slow `Float64` conversion of non-float inputs.
- Fixed `CovarianceImage`.
- Expanded scaling and per-feature performance tests.

## [0.6.0] - 2024-12-10

- **Breaking**: updated for `TimeseriesFeatures` 0.5.

## [0.5.2] - 2024-12-09

- Fixed `DN_Mean` and `DN_Spread_Std` on non-`Float64` inputs.
- Dropped the `ProgressLogging` dependency.

## [0.5.1] - 2024-11-05

- Support for `DimensionalData` 0.29.
- Type-stability tests; docs point to the catch22 GitBook wiki.

## [0.5.0] - 2024-01-23

- `Feature`, `FeatureSet` and `FeatureArray` moved to `TimeseriesFeatures.jl` and are re-exported from here.

## [0.4.5] - 2023-10-17

- New feature: `CR_RAD`.
- Added short-name feature sets.
- Test comparing per-feature evaluation time.

## [0.4.4] - 2023-05-10

- Fixed caching of `dlopen` pointers.
- `FeatureSet`s can be evaluated over vectors of time series.

## [0.4.3] - 2022-11-09

- Fixed minor-version compat bounds.

## [0.4.2] - 2022-11-09

- Relaxed compat bounds.

## [0.4.1] - 2022-09-21

- Added `SuperFeature`s and `SuperFeatureSet`s; catch22 z-scoring now uses them.
- Added `ACF` and `PACF` super-feature sets.
- Fixed `Feature` evaluation on `DimArray`s.

## [0.4.0] - 2022-06-22

- Updated to catch22 v0.4.0.
- `DN_Mean` and `DN_Spread_Std` are now `Feature`s.
- `Feature`s and `FeatureSet`s can be constructed with keywords; improved printing.
- Test data served via Artifacts; source restructured into modules; docs published.

## [0.3.1] - 2022-06-10

- Added `catch24`.
- Indexing by feature names alone.
- Updated for the interpolated `CO_f1ecac`; removed some dependencies.

## [0.2.4] - 2022-06-05

- `DimensionalData` compat.

## [0.2.3] - 2022-06-04

- Version bump for consistency.

## [0.2.2] - 2022-05-31

- Added `covarianceimage` (loaded via `Requires` when `Plots` is available), with optional clustering, manual sorting and feature weights.
- `Feature` and `FeatureSet` evaluation preserves `DimArray` dimensions.
- Threaded feature evaluation with progress logging.

## [0.2.1] - 2021-06-24

- Guard against very short time series.
- Operations between a `FeatureSet` and a `Feature`; `AbstractFeatureArray` aliases.

## [0.2] - 2021-05-29

- Added the `Feature`, `FeatureSet` and `FeatureArray` types, with keywords, descriptions and set operations.

## [0.1] - 2021-04-20

- Initial release: `ccall` wrappers for the catch22 C library via `catch22_jll`, `DimensionalData`-backed feature matrices, feature names and descriptions, and test time series.

[0.7.1]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.5.2...v0.6.0
[0.5.2]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.4.5...v0.5.0
[0.4.5]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.2.4...v0.3.1
[0.2.4]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.2...v0.2.1
[0.2]: https://github.com/brendanjohnharris/Catch22.jl/compare/v0.1...v0.2
[0.1]: https://github.com/brendanjohnharris/Catch22.jl/releases/tag/v0.1
