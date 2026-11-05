# Paper panel map

| Paper quantity | Script | Output stem / input |
|---|---|---|
| Overall abrupt-change frequency (Fig. 1) | figs_2026.R | overall_abrupt_GAM; all 130 records, Lake Yoa repaired |
| PC1 loading map and trajectory (Fig. 2) | figs_2026.R | pca; original plotting API and saved fit |
| PCA scree | figs_2026.R | scree |
| Positive-PC1 event-type panels (Fig. 3) | figs_2026.R | pc1_positive_*; supplied positive_sites.csv |
| Negative-PC1 comparison panels | figs_2026.R | pc1_negative_*; supplied negative_sites.csv |
| Representative site series (Fig. 4) | site_fig26.R | pos_plots; original 12 selected rank positions |
| Event-annotated site review panels | site_fig26.R | selected_sites_with_events; supplied classification matrices |
| Event maps (Fig. 5) | final_maps.R | all_afr_forest_grad_abrupt3000_final and 6000_final |
| Continental event-type supplement | figs_2026.R | all_rise, all_decline, all_abruptloss, all_gradloss |
| Spatial significance supplement | spat_sign26.R | spatial_sign_0_3000_posneg and 3000_6000_posneg |
| Weighted spatial significance index | spat_sign26.R | spatial_sign_weighted_ind_posneg; ACTR_SPATIAL_INDEX=true |
| External NGRIP panel | External | Excluded as requested |

SVG files are editable; PNG files provide quick previews. Grouped category panels use the supplied manually curated group summary tables, preserving their original smoothing choices. Supplementary spatial analysis retains its original independent PELT method. These must not be described as freshly recalculated from the main AMOC table.
