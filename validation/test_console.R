# Execute the README's R-console source sequence in a clean R process.
# This tests source() compatibility; it does not claim GUI automation of RStudio.
Sys.setenv(ACTR_MODE='saved',ACTR_RUN='console_example')
Sys.unsetenv(c('ACTR_IDS','ACTR_LOCAL_STEP1','ACTR_RUN_BACON','ACTR_SPATIAL_RECOMPUTE','ACTR_SPATIAL_INDEX'))
source('config.R')
source('check_environment.R')
check_run_identity()
source('figs_2026.R')
source('site_fig26.R')
source('final_maps.R')
writeLines('README source() sequence completed for main figures, sites and maps.',file.path(OUT,'logs/console_validation.txt'))
