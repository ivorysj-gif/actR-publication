# Execution and usability validation — 9 November 2026

This revision changes execution safeguards, setup and documentation only. It does not change scientific methods, parameters, dataset selection, historical classifications or saved results. The original Dropbox publication directory and GitHub repository have not been updated by this local revision.

## Starting point and inputs

- Fresh HTTPS clone of `https://github.com/ivorysj-gif/actR-publication.git` at commit `be96f750afe02bdcda3887463a4a38b365b13952`.
- Public v1.0.0 release ZIP downloaded successfully, 571,380,837 bytes. SHA-256 matches `13013e0a170540910bd1524770050833067d0f3e594c07e25c07ac9ba5a10830`.
- All 211 extracted bundle files remain byte-identical to the archive. All 16 ancillary files remain byte-identical to the GitHub commit. Neither existing preview outputs nor classifications were rewritten.
- Windows, R 4.5.2. Existing user R packages and the previously prepared pcaMethods library were made visible through `R_LIBS_USER`. Missing BiocManager was installed into this checkout's `.R-library` by the revised installer. This is a clean code/data checkout test, not a completely empty R installation.

## Commands and execution checks

The original instructions were inspected and attempted first. In the restricted test process their installer tried to write missing packages into a non-writable visible user library; the revised installer supplies a project-local destination. The saved environment check passed with the installed dependencies. The README now links directly to the release and explains extraction, output locations, R library visibility and platform syntax.

The following saved workflow completed in the fresh checkout:

```text
Rscript install_dependencies.R
Rscript run.R check
Rscript run.R figures sites maps
Rscript run.R spatial
```

The initial three figure tasks were also invoked in the same R process after `check`, exercising the launcher's execution order. The README's Console `source()` sequence was subsequently exercised in a clean R process for figures, sites and maps; this is source-mode validation, not automation of the RStudio GUI.

The archive was initially downloaded with HTTPS curl and extracted. The new R extraction helper was separately tested against that downloaded archive in an empty target: SHA-256 validation and extraction succeeded, and a repeated extraction was rejected without overwriting files. A further empty-target test exercised the helper end-to-end: R's libcurl downloaded the public 545 MiB asset, its SHA-256 matched, and extraction completed. The restricted execution process needed network access and a normal filesystem-access context for these tests; no credentials were needed.

## Results

- 21 analytical panels were produced in both PNG and SVG: 15 main figure panels, two site panels, two event maps, and two supplementary spatial panels. All 42 files are nonempty. These are component panels, not the final PowerPoint layout.
- Five exported data tables match the bundled versions to tolerance 1e-12: overall frequency, continental category proportions, both map-site tables, and selected-site metadata.
- All eight group-GAM fitted predictions match the bundled models on the tested grid to tolerance 1e-10.
- Technical guard checks cover early output conflict refusal, rejection of changed run IDs, rejection of a record-ID mismatch, and fresh three-record dependency checking without Step 4 outputs.
- The spatial image was visually inspected for successful rendering. A second spatial invocation completed using the matching caches. The input/settings cache signature rejects mismatched or older-format caches.
- The documented local pilot (IDs 49925, 41269 and 59883) completed Steps 1–4 using existing root Step 1 files and detector-only Step 4. It produced all three detector outputs and the ID-keyed aggregation. This was an execution test, not a new scientific comparison or historical-event equivalence claim.
- Pilot output IDs/dimensions were checked. Repeating each of the four computational stages was refused before calculation or overwrite; output fingerprints remained unchanged.

Detailed machine-readable evidence and logs are under the ignored `validation/execution/`, `execution_*.log`, and the new run directories. The original `PACKAGE_MANIFEST.csv` remains the historical distribution manifest; it is not represented as a checksum of revised executable code.

## Changes included

1. Clear saved-results entry point, release link, checksum helper and non-overwriting extraction.
2. Missing dependencies installed into `.R-library`; saved/fresh dependency scopes and actual installed-source reporting.
3. Default new figure destination `outputs/reproduced`, separate from bundled previews.
4. Environment checking independent of completed fresh-analysis outputs.
5. Early computational output checks, run configuration checks, ID validation and per-record forest-series extraction.
6. Spatial caches bound to event inputs, grid, settings and actR version.
7. Explicit partial-run figure prerequisites; listed-file NDVI rebuild; accurate comments for existing rounding and uncertainty bands.
8. Git attributes preserve distributed input bytes instead of generating line-ending-only changes to data on checkout.

## Remaining limitations

- macOS/Linux commands are documented but those platforms were not executed. Source packages can need platform build tools/system libraries. The tested R library is not a complete dependency lockfile or an empty-machine installation test.
- Fresh online Neotoma retrieval, Bacon age models, the full 130-record analysis and optional 41-window spatial index were not rerun. No new scientific comparison was undertaken.
- Existing package warnings include local locale settings, optional lipdverse metadata access under restricted network conditions, deprecated plotting interfaces, missing ageUnits metadata, and an installed package built under R 4.5.3. Successful figure execution is not described as warning-free. Logs are retained.
- Historical manual classifications remain required scientific inputs. The fresh route does not automatically regenerate or reuse those labels. Scientific ambiguities still stop for review.
- This is a local revision ready for review; the live GitHub README and scripts remain unchanged until a separately authorized publication step.
