# actR — for publication

## GitHub distribution

This repository contains the cleaned code, documentation and ancillary tables. The separate `actR-saved-results.zip` bundle contains the historical analysis snapshots, original reference scripts and generated figure previews. Extract that bundle into this repository before using the default saved-results commands below. The bundle is not tracked in Git. Fresh download/recompute scripts do not require the historical snapshots for the main Steps 1–4.

The original publication package remains unchanged. No software or data license has been assigned by this packaging step.


This package keeps the original organization: Steps 1–3 preprocess pollen and chronologies; Step 4 performs covariance age-uncertain PCA and abrupt-change analysis; the remaining scripts make the paper's panels. Original scripts are retained, unmodified, under `reference_originals/` for comparison. **Do not run that reference directory**: its absolute paths and historical interactive fragments are intentionally preserved.

## Quick start: figures from supplied saved results

Use R 4.5.x with the dependencies listed in `check_environment.R`. From a terminal:

```text
cd "path/to/for publication"
Rscript install_dependencies.R
Rscript run.R check
Rscript run.R figures sites maps
Rscript run.R spatial
```

Alternatively, open this folder in RStudio, install dependencies once, then `source("config.R")` followed by the desired script. The installer is optional when packages are already available. It uses commit-pinned sources for actR, geoChronR and lipdR, but is not a complete transitive lockfile. Tested package versions are recorded in `validation/build_environment_packages.csv` and run-specific session files. Packages must be visible to the R installation you run (`.libPaths()` / `R_LIBS_USER`). Installation and fresh online downloads were not repeated during validation.

The default mode is `saved`. Outputs go to `outputs/publication/`; SVG and PNG versions are written. The supplied snapshots remain unchanged. Set `ACTR_RUN` to a new simple name for a separate run. Figure exports can be regenerated within a run; calculated per-record analysis outputs refuse overwriting.

`spatial` reproduces the two supplementary spatial map windows from supplied spatial-event results. To calculate the original 41-window weighted spatial index as well, set `ACTR_SPATIAL_INDEX=true`. This is slower. The index preserves the original 0–500 through 20,000–20,500 BP windows; it does not silently shorten the original final window.

## Full preprocessing and analysis route

Environment variables control paths and run selection; there are no personal absolute input paths in the executable workflow. Example in **PowerShell**:

```powershell
$env:ACTR_MODE = "recompute"
$env:ACTR_RUN = "new_analysis"
$env:ACTR_RUN_BACON = "true"
Rscript run.R step1 step2 step3 step4
```

For an initial small trial, set `$env:ACTR_IDS = "49925,41269,59883"`. For detector-only testing set `$env:ACTR_STEP4_PART = "shifts"`; PCA needs enough records for the specified eight components. Remove `ACTR_IDS` for all 130 records. For a complete PCA-plus-detector run, remove `ACTR_STEP4_PART` or set it to `both`.

To use existing local Step 1 `.RData` files instead of downloading and refitting age models:

```powershell
$env:ACTR_LOCAL_STEP1 = "path/to/existing/step_1_files"
$env:ACTR_MODE = "recompute"
$env:ACTR_RUN = "local_analysis"
Rscript run.R step1 step2 step3 step4
```

On macOS/Linux use `export NAME=value` instead. Reset to the supplied historical figure route with `ACTR_MODE=saved` and a new `ACTR_RUN`.

Fresh Neotoma downloads and Bacon models require internet access, compatible Bacon dependencies, and scientific review of each chronology. The download/model script preserves the original northern/southern calibration-curve choice and named Bacon arguments. It does not claim that current downloads will reproduce historical snapshots exactly. Unmapped taxa, ambiguous sample alignment and unusable age models stop with an explicit message instead of silently dropping a record. Review the logged taxon and age-group tables before continuing.

## Script guide

| Script | Role |
|---|---|
| `config.R`, `R/helpers.R` | Portable paths, explicit settings, ID-keyed data handling |
| `step1_download_age_models.R` | Neotoma retrieval or local import; optional Bacon fitting and age mapping |
| `step2_harmonize.R` | Nomenclature lookup and mapping audit |
| `step3_full_workflow.R` | Age-group pooling, pollen percentages, biome affinities, verified depth pairing |
| `step4_full_workflow_synth.R` | Covariance PCA and AMOC detection, synthesis by dataset ID |
| `figs_2026.R` | PCA/scree, overall abrupt-change curve, curated event-category GAM panels |
| `site_fig26.R` | Original hand-selected PC1-ranked site stack and annotated review panels |
| `final_maps.R` | Curated event maps for 0–3000 and 3000–6000 BP |
| `spat_sign26.R` | Separate supplementary spatial method and weighted index |
| `prepare_map_background.R` | Optional rebuild of supplied NDVI background |
| `run.R`, `check_environment.R` | Launcher and dependency check |

## Analytical choices retained

- Main collection: all 130 curated dataset IDs; no additional `to_rm.csv` filtering.
- Pollen groups and strict maximum-percentage filter >0.5% retained.
- Original first-match taxonomic mapping retained and audited; ambiguous alternative mappings are not silently substituted.
- Square-root affinity calculation; savanna/steppe and desert both include the original grass contribution. Missing PFT assignments retain the original zero-affinity contribution and are logged.
- Historical age pooling retained, including Rusaka's ten samples at 9100 BP attached to 795 cm. No separate-sample sensitivity experiment is run here.
- Main detector: **AMOC**, MBIC, minimum segment length 1, 100 uncertainty realizations, 100 isospectral null simulations, 100-year summaries, p < 0.05. Fresh runs use a fixed seed for reproducibility, not a seed-sensitivity experiment.
- PCA: covariance PPCA, eight PCs, 1,000 ensembles, mean binning over 0–20 ka at 500 years.
- Figure aggregation: original nearest-500 rounding, deduplication within each record, and `cut` boundaries. Gradual-transition classification panels retain their original 250-year pre-rounding before 500-year counting. Original GAM formulas/default fitting and +/-1-SE smooth bands are retained where applicable.
- Supplementary spatial script is a **separate original PELT branch**, with 50 uncertainty/null realizations and 500-year summaries; distance grid 3 degrees, weighted robustNull, 1000-km cutoff. Saved results are supplied. Optional `ACTR_SPATIAL_RECOMPUTE=true` preserves the source script's two positional exclusions after its dimension check; these are not applied to the main 130-record synthesis. This branch must not be described as the main AMOC detector.

## Saved results versus a fresh run

The main supplied shift table is reconstructed from historical per-record AMOC outputs by ID, correcting the duplicated al-Hawa column in Lake Yoa's position. It is not assembled from the mixed newer PELT directory. The supplied PCA is the historical 130-record fit used for the paper. Fresh stochastic results can differ from these snapshots even with the same named analytical settings.

The `saved_results/records` files are compact extracted historical detector summaries, not raw Neotoma downloads. Fresh preprocessing uses downloaded records or an explicitly supplied local Step 1 directory. No large raw pollen archive is required for the saved-figure route.

## Manual classifications and scope of reproduction

`ancillary/classifications/` contains the original event-category CSVs, positive/negative group summary CSVs, and `manual_shifts.xlsx`. They are explicit scientific inputs. The group summaries are preserved as provided, not inferred from new PCA loadings or modified event times. Their original membership/curation must be reviewed if the analysis is updated. Likewise, the Lake Yoa repair to the main automatic shift table does not silently recode manually classified events.

For a new analysis, Steps 1–4 calculate new events. The overall PCA and abrupt-frequency figures can then run. Category maps/panels require a new manual classification review; the scripts refuse to reuse the historical classification files in recompute mode. The supplementary spatial recomputation uses its supplied reviewed spatial input (`tp.RData`), not a newly downloaded collection automatically.

The map background is derived from the same 12 monthly NDVI TIFFs as the original code: mean >0.6, followed by modal aggregation factor 15. The small derived raster is bundled, so maps do not depend on external Dropbox paths or downloads. `NDVI_sources.csv` records the source filenames. Optional rebuilding requires those TIFFs through `ACTR_NDVI_DIR`.

The external NGRIP comparison panel is intentionally excluded, as requested. Final slide layout, labels and multi-panel arrangement remain manuscript/presentation editing; the package exports the underlying panels. See `FIGURE_MAP.md` and `CHANGELOG.md` for exact coverage and disclosed corrections.
