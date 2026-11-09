# Changes from the supplied scripts

## Execution-only revision — 9 November 2026

- Added the public saved-bundle URL, checksum verification, non-overwriting extraction helper, and separate terminal/RStudio walkthroughs.
- Default regenerated figures now go to `outputs/reproduced/`, preserving the bundled previews under `outputs/publication/`.
- Added a project-local library for missing dependencies, explicit dependency scopes and installed-source reporting; no full lockfile or empty-machine install is claimed.
- Fresh environment checks no longer require completed Step 4 outputs. Added early output-conflict checks, run-configuration checks and record-ID validation. Forest series are extracted per record to preserve their association with input IDs.
- Spatial cache files now record their input/settings fingerprint. Existing incompatible cache formats are rejected rather than silently reused.
- NDVI rebuild uses the listed 12 input filenames. Figure prerequisite messages explain detector-only pilot limitations.
- Corrected documentation of the existing category-panel +/-2-SE bands and the distinct continental/group gradual-loss rounding conventions. No analytical formula, threshold, classification or historical output was changed.
- Git attributes preserve ancillary-file bytes rather than creating line-ending-only changes on checkout. See `validation/EXECUTION_REVIEW_2026-11-09.md` for execution evidence and limitations. `PACKAGE_MANIFEST.csv` describes the original distributed package, not this revision's changed code.

## Technical cleanup

- Kept the named step sequence and separate figure/site/map/spatial scripts. Removed interactive resume positions, repeated workspace clearing, obsolete experiments and personal paths from executable copies. Original sources are archived unchanged.
- Centralized settings and paths; explicit dataset IDs replace inferred site-name joins and positional append state. Main outputs are confined to a new run directory.
- Read the BOM-prefixed ID CSV correctly; use original normalized CSV column names; preserve original first-match taxon mapping.
- Use the correct lipdR exports for selectData/extractTs/filterTs and handle both nested historical and current actR result schemas.
- State historical AMOC parameters explicitly, avoiding a silent switch to PELT defaults. Do not infer actual bin width from the current actR metadata field, which is misleading; verify actual adjacent bin centers.
- Preserve raster objects rather than calling as.numeric on a raster; use numeric 0/1 classes and terra's modal aggregation keyword. This fixes the source map code without changing the threshold or aggregation factor.
- Normalize the different positive/negative summary-table column labels, and remove only actual CSV row-index columns.
- Save plots explicitly in noninteractive Rscript sessions; remove dependencies on undefined objects left in an interactive workspace.

## Corrections that can change results, already identified in the audit

- The supplied main synthesis restores Lake Yoa's own AMOC results in place of the duplicated al-Hawa column. The older aggregate is not overwritten. Maximum observed change in raw plotted proportions was 1.22 percentage points.
- Use all 130 IDs as requested; do not apply the extra positional exclusions from to_rm.csv. This differs from running that later figure fragment literally.
- Fresh Step 3/4 analysis pairs biome age groups to age ensembles by explicit depth, correcting the reviewed zero/NA masking and ordering problems. Historical figure snapshots retain their original underlying analyses, apart from the documented Lake Yoa assembly correction.
- Retain Rusaka pooling as requested. Other unreviewed duplicate-age ambiguities stop instead of selecting a depth without review.
- Restore the original desert-plus-grass affinity term, which the previously cleaned scripts omitted; preserve the original missing-PFT denominator/contribution behavior.

## No new methodological investigation

No new seed study, chronology-update comparison, alternative biomization, or AMOC/PELT comparison is part of this package. One fixed seed is recorded for reproducibility of future fresh runs. The supplementary spatial PELT branch remains separate and explicitly labeled.

## Reproduction boundaries

The package exports analytical panels, not a pixel-identical PowerPoint composition. Curated category tables and subgroup summary tables remain supplied inputs. Their membership/curation cannot be inferred solely from the numeric detector output. Spatial classification and new age-model fits need the original scientific review steps if rerun from new downloads. The NGRIP panel is external and excluded at the user's request.
