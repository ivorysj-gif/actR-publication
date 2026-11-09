# actR publication workflow

Start with the **saved-results route** below to regenerate the analytical panels. It uses the historical inputs supplied with the paper; it does not download pollen records, fit age models, or rerun PCA/detection. Steps 1–3 preprocess records and Step 4 performs PCA and abrupt-change analysis in the separate fresh-analysis route.

## 1. Obtain the code and R

Install R 4.5.x and optionally RStudio. Clone the repository, or download its source ZIP and extract it:

```sh
git clone https://github.com/ivorysj-gif/actR-publication.git
cd actR-publication
```

All commands below run **inside that folder**. Folder names differ if you downloaded a source ZIP. Paths containing spaces must be quoted. You do not need SSH or a GitHub account to download this public repository.

On Windows, open `actR_publication.Rproj` in RStudio for the simplest entry point. For PowerShell commands, `Rscript` must be on PATH. If it is not, add your R installation's `bin` folder for the current terminal (adjust the version):

```powershell
$env:Path = "C:\Program Files\R\R-4.5.2\bin;" + $env:Path
```

On macOS/Linux, verify `Rscript --version` in a terminal after installing R. Source installations of R packages may require platform build tools and geospatial libraries; follow errors from the R package installer. Windows binary packages avoid many build requirements, but source packages may require the matching Rtools version.

## 2. Install packages and obtain saved inputs

Run once from a terminal:

```sh
Rscript install_dependencies.R
Rscript download_saved_results.R
```

Or in the RStudio **Console**, with the project open:

```r
source("install_dependencies.R")
source("download_saved_results.R")
```

The installer defaults to saved-workflow dependencies. It installs missing packages into `.R-library/` inside the project, leaving existing libraries unchanged. Existing visible packages are reused; installed versions and GitHub source commits are reported. The three GitHub dependencies use recorded commits when installed from scratch. This is **not a complete environment lockfile**. Tested versions are recorded in `validation/build_environment_packages.csv`; each run also writes session information. If you use a custom R library, make it visible through `R_LIBS_USER` before starting R, or `.libPaths()` in RStudio. A fresh Rscript process does not inherit an RStudio `.libPaths()` change.

The download helper fetches the approximately 545 MiB archive from the [v1.0.0 release](https://github.com/ivorysj-gif/actR-publication/releases/tag/v1.0.0), verifies its SHA-256, and extracts it without overwriting existing bundle files. No token is required. Manual alternative: download [actR-saved-results.zip](https://github.com/ivorysj-gif/actR-publication/releases/download/v1.0.0/actR-saved-results.zip) and extract its contents directly into the repository root, not an extra nested folder. Expected layout:

```text
actR-publication/
  run.R
  ancillary/
  saved_results/
    pc_results_20k_500.RData
    shifts_by_id.rds
    events8.2.RData
    tp.RData
    records/
  reference_originals/
  outputs/publication/       # bundled previews: preserve these
```

Archive SHA-256: `13013e0a170540910bd1524770050833067d0f3e594c07e25c07ac9ba5a10830`.

If the helper says destinations exist, do not extract again: proceed to the check below if the bundle is complete. Use a fresh clone to recover from a partial extraction without overwriting historical files. Do not execute scripts in `reference_originals/`; their historical paths and interactive fragments are intentionally preserved.

## 3. Regenerate the figures

In a new terminal with no earlier actR environment overrides:

```sh
Rscript run.R check
Rscript run.R figures sites maps
Rscript run.R spatial
```

Defaults are `ACTR_MODE=saved` and `ACTR_RUN=reproduced`. New outputs are written to **`outputs/reproduced/`**, preserving the bundled `outputs/publication/` previews. The spatial command calculates supplementary spatial maps from saved events and can take longer.

RStudio equivalent:

```r
Sys.setenv(ACTR_MODE="saved", ACTR_RUN="reproduced")
Sys.unsetenv(c("ACTR_IDS", "ACTR_LOCAL_STEP1", "ACTR_RUN_BACON",
              "ACTR_SPATIAL_RECOMPUTE", "ACTR_SPATIAL_INDEX"))
source("config.R")
source("check_environment.R")
check_run_identity()
source("figs_2026.R")
source("site_fig26.R")
source("final_maps.R")
source("spat_sign26.R")
```

Always re-source `config.R` after changing environment settings in an existing R session. Do not enter PowerShell commands in the R Console.

Expected outputs under `outputs/reproduced/figures/`:

| Command | Main outputs (PNG and SVG) |
|---|---|
| `figures` | `scree`, `pca`, `overall_abrupt_GAM`, eight `pc1_*` category panels, four `all_*` category panels; frequency CSVs and fitted GAM objects |
| `sites` | `pos_plots`, `selected_sites_with_events`, and `site_stack_selection.csv` |
| `maps` | `all_afr_forest_grad_abrupt3000_final`, `all_afr_forest_grad_abrupt6000_final`, and map-site CSVs |
| `spatial` | `spatial_sign_0_3000_posneg`, `spatial_sign_3000_6000_posneg`; cached calculations under `spatial/` |

Session records and the dependency report are in `logs/`. See `FIGURE_MAP.md` for the manuscript-panel mapping. The external NGRIP panel and final PowerPoint arrangement are not generated here.

Plots can be regenerated within an unchanged run. Calculated analysis outputs are protected: use a new `ACTR_RUN` rather than replacing them. Spatial caches are checked against their inputs and settings. The optional 41-window spatial index is enabled with `ACTR_SPATIAL_INDEX=true`; it is slower and is not required for the basic walkthrough.

## 4. Fresh preprocessing and analysis (separate workflow)

This route requires downloads or reviewed local Step 1 files. It does **not** recreate historical random draws or automatically regenerate manual classifications. Install additional dependencies by setting `ACTR_INSTALL_SCOPE=all`. All 130 curated IDs remain the default.

PowerShell:

```powershell
$env:ACTR_INSTALL_SCOPE = "all"
Rscript install_dependencies.R
$env:ACTR_MODE = "recompute"
$env:ACTR_RUN = "new_analysis"
$env:ACTR_RUN_BACON = "true"
Rscript run.R check
Rscript run.R step1 step2 step3 step4
Rscript run.R figures
```

macOS/Linux:

```sh
export ACTR_INSTALL_SCOPE=all
Rscript install_dependencies.R
export ACTR_MODE=recompute ACTR_RUN=new_analysis ACTR_RUN_BACON=true
Rscript run.R check
Rscript run.R step1 step2 step3 step4
Rscript run.R figures
```

RStudio: use `Sys.setenv(ACTR_INSTALL_SCOPE="all")`, source the installer, then `Sys.setenv(ACTR_MODE="recompute", ACTR_RUN="new_analysis", ACTR_RUN_BACON="true")`, source `config.R`, run `check_run_identity()`, and source the numbered scripts in order. Do not rerun a completed computational stage into the same output files; choose a new run name. Unmapped taxa or ambiguous age/depth relationships stop for review rather than silently changing data.

For a small local-data pilot, use a new run and set these variables before `run.R check` and Steps 1–4:

```powershell
$env:ACTR_MODE = "recompute"
$env:ACTR_RUN = "local_pilot"
$env:ACTR_LOCAL_STEP1 = "C:/path/to/reviewed/step_1_files"
$env:ACTR_RUN_BACON = "false"
$env:ACTR_IDS = "49925,41269,59883"
$env:ACTR_STEP4_PART = "shifts"
```

On macOS/Linux use `export NAME=value`; in RStudio use `Sys.setenv(NAME="value")`. The pilot calculates detectors only. It does not produce the PCA required by the combined `figures` task. A full PCA needs at least eight suitable records; clear `ACTR_IDS` for all 130 and set `ACTR_STEP4_PART=both` for a full run in another output directory.

To return to saved figures in PowerShell:

```powershell
$env:ACTR_MODE = "saved"
$env:ACTR_RUN = "saved_again"
Remove-Item Env:ACTR_IDS, Env:ACTR_LOCAL_STEP1, Env:ACTR_RUN_BACON, Env:ACTR_STEP4_PART, Env:ACTR_SPATIAL_RECOMPUTE, Env:ACTR_SPATIAL_INDEX -ErrorAction SilentlyContinue
```

In macOS/Linux use `export ACTR_MODE=saved ACTR_RUN=saved_again` and `unset ACTR_IDS ACTR_LOCAL_STEP1 ACTR_RUN_BACON ACTR_STEP4_PART ACTR_SPATIAL_RECOMPUTE ACTR_SPATIAL_INDEX`.

Fresh Neotoma/Bacon runs require internet access and review of individual chronologies. Fresh event categories require manual review; historical category maps and labels are deliberately unavailable in recompute mode. Supplementary spatial recomputation uses the separate supplied `tp.RData` inputs, not the newly downloaded main collection. No scientific choices are made automatically to get a failed record to run.

## Execution validation and limitations

See `validation/EXECUTION_REVIEW_2026-11-09.md` for the exact tested checkout, commands, results, and limitations. Windows execution is tested with existing R libraries plus a project-local installation of missing dependencies; this is a clean repository checkout, **not an empty-machine installation test**. macOS/Linux syntax is provided but those platforms have not been executed here. Fresh online download/Bacon runs and a full 130-record recomputation are outside this usability test. Package startup/deprecation warnings are logged and are not described as warning-free execution.

No software or data license has been assigned by this packaging step.

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
- Figure aggregation: original nearest-500 rounding, deduplication within each record, and `cut` boundaries. Continental gradual-loss panels use 250-year pre-rounding; the supplied PC1-group tables reproduce with 500-year rounding. Original GAM formulas/default fitting are retained. Centered category panels use the original plot extraction with +/-2 SE; the overall fitted-proportion plot uses +/-1 SE.
- Supplementary spatial script is a **separate original PELT branch**, with 50 uncertainty/null realizations and 500-year summaries; distance grid 3 degrees, weighted robustNull, 1000-km cutoff. Saved results are supplied. Optional `ACTR_SPATIAL_RECOMPUTE=true` preserves the source script's two positional exclusions after its dimension check; these are not applied to the main 130-record synthesis. This branch must not be described as the main AMOC detector.

## Saved results versus a fresh run

The main supplied shift table is reconstructed from historical per-record AMOC outputs by ID, correcting the duplicated al-Hawa column in Lake Yoa's position. It is not assembled from the mixed newer PELT directory. The supplied PCA is the historical 130-record fit used for the paper. Fresh stochastic results can differ from these snapshots even with the same named analytical settings.

The `saved_results/records` files are compact extracted historical detector summaries, not raw Neotoma downloads. Fresh preprocessing uses downloaded records or an explicitly supplied local Step 1 directory. No large raw pollen archive is required for the saved-figure route.

## Manual classifications and scope of reproduction

`ancillary/classifications/` contains the original event-category CSVs, positive/negative group summary CSVs, and `manual_shifts.xlsx`. They are explicit scientific inputs. The group summaries are preserved as provided, not inferred from new PCA loadings or modified event times. Their original membership/curation must be reviewed if the analysis is updated. Likewise, the Lake Yoa repair to the main automatic shift table does not silently recode manually classified events.

For a new analysis, Steps 1–4 calculate new events. The overall PCA and abrupt-frequency figures can then run. Category maps/panels require a new manual classification review; the scripts refuse to reuse the historical classification files in recompute mode. The supplementary spatial recomputation uses its supplied reviewed spatial input (`tp.RData`), not a newly downloaded collection automatically.

The map background is derived from the same 12 monthly NDVI TIFFs as the original code: mean >0.6, followed by modal aggregation factor 15. The small derived raster is bundled, so maps do not depend on external Dropbox paths or downloads. `NDVI_sources.csv` records the source filenames. Optional rebuilding requires those TIFFs through `ACTR_NDVI_DIR`.

The external NGRIP comparison panel is intentionally excluded, as requested. Final slide layout, labels and multi-panel arrangement remain manuscript/presentation editing; the package exports the underlying panels. See `FIGURE_MAP.md` and `CHANGELOG.md` for exact coverage and disclosed corrections.
