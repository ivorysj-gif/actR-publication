# Validation completed

Validated on Windows with R 4.5.2. Exact loaded versions are in sessionInfo.txt and the dependency/session logs.

## Passed

- All executable R scripts parse.
- Steps 1–3 ran with existing local Step 1 records 49925 (Otjikoto), 41269 (Small Momela), and 59883 (Tswaing). All three reproduce the original Step 3/26 biome affinities to within 7.11e-15. Explicit depth pairing and 1,000-column age matrices pass checks.
- An actual cleaned Step 4 detector run completed for Otjikoto. Stored results confirm AMOC, MBIC, 100 uncertainty realizations, 100 null simulations, and actual 100-year summary spacing.
- The main saved-results figure calculation exactly reproduces the verified all-130, Lake-Yoa-repaired historical aggregation.
- Saved-results PCA/scree, positive and negative event panels, continental event-type panels, original selected site stack, annotated site panels, both event maps, and both supplementary spatial map windows executed successfully.
- Twenty-one plots were generated in both SVG and PNG formats. PCA, map and spatial panels were visually inspected for rendering/layout problems.
- The map background was regenerated from the original 12 monthly NDVI rasters using the original >0.6 threshold and modal factor-15 aggregation. It is bundled as a small TIFF.

## Not run in this cleanup

- Fresh Neotoma downloads and new Bacon age-model fitting across the collection.
- A fresh all-130 PCA/detector fit. The saved PCA route is validated; its eight-PC, 1,000-realization computation route is supplied.
- New spatial PELT detection or the optional 41-window spatial index loop. The two spatial map windows were recalculated from supplied saved spatial events; the original index formula and range are implemented.
- Automatic regeneration of manual event-category decisions. Supplied historical tables are explicit inputs and are not silently reused for fresh analysis.

## Warnings and boundaries

Some installed packages emit deprecation notices and attempt an optional LiPD standard-table lookup at load time; the offline lookup warning did not prevent tested local runs. ggplot2 reports that it was built under R 4.5.3. Plotting-package deprecation warnings remain visible; scientific calculations were not patched to suppress them.

NGRIP is an external comparison panel and is intentionally not included. Output panels are not a pixel-identical reconstruction of PowerPoint page layout. Detailed scientific corrections and reproduction boundaries are in CHANGELOG.md and README.md.
