# Shared paths and explicit paper settings. Run from this directory or via run.R.
PUB_ROOT <- normalizePath(getwd(), winslash='/', mustWork=TRUE)
stopifnot(file.exists(file.path(PUB_ROOT,'ancillary/dataset_id_2025_nums_badrm_fixed.csv')))
ANC <- file.path(PUB_ROOT,'ancillary')
SAVED <- file.path(PUB_ROOT,'saved_results')
RUN_NAME <- Sys.getenv('ACTR_RUN','publication')
if(!grepl('^[A-Za-z0-9_-]+$',RUN_NAME))stop('ACTR_RUN must be a simple folder name')
OUT <- file.path(PUB_ROOT,'outputs',RUN_NAME)
for(d in c('step1','step2','step3','step4','figures','logs','spatial','age_models'))dir.create(file.path(OUT,d),recursive=TRUE,showWarnings=FALSE)
MODE <- Sys.getenv('ACTR_MODE','saved') # saved = supplied paper inputs; recompute = Steps 1-4
stopifnot(MODE %in% c('saved','recompute'))
IDS <- read.csv(file.path(ANC,'dataset_id_2025_nums_badrm_fixed.csv'),fileEncoding='UTF-8-BOM')$datasetid
stopifnot(length(IDS)==130,!anyNA(IDS),!anyDuplicated(IDS))
subset_ids <- Sys.getenv('ACTR_IDS','')
PROCESS_IDS <- if(nzchar(subset_ids))as.integer(strsplit(subset_ids,',',fixed=TRUE)[[1]]) else IDS
stopifnot(!anyNA(PROCESS_IDS),!anyDuplicated(PROCESS_IDS),all(PROCESS_IDS %in% IDS))
YEAR_RANGE <- c(0,20000); PCA_BIN <- 500; SHIFT_BIN <- 100; FIGURE_BIN <- 500
N_ENSEMBLES <- 1000; N_PC <- 8; SHIFT_ENSEMBLES <- 100; NULL_SIMULATIONS <- 100
SHIFT_METHOD <- 'AMOC'; SHIFT_PENALTY <- 'MBIC'; MIN_SEGMENT <- 1
SEED <- 20261104L # Reproducible new runs; historical random states were not saved.
POLLEN_GROUPS <- c('TRSH','UPHE','PALM','VACR','VASC','SUCC','MANG','UNID')
MIN_TAXON_MAX_PCT <- 0.5
source(file.path(PUB_ROOT,'R/helpers.R'))
