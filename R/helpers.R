need <- function(pkgs){missing<-pkgs[!vapply(pkgs,requireNamespace,TRUE,quietly=TRUE)];if(length(missing))stop('Install required packages: ',paste(missing,collapse=', '))}
input_file <- function(path){if(!file.exists(path))stop('Required input missing: ',path);path}
record_path <- function(stage,id)file.path(OUT,paste0('step',stage),paste0('dataset_',id,'.rds'))
read_env <- function(path){e<-new.env();load(input_file(path),e);e}
write_new <- function(x,path){if(file.exists(path))stop('Output already exists: ',path,'. Choose a new ACTR_RUN.');saveRDS(x,path)}
read_pca <- function(){path<-if(MODE=='saved')file.path(SAVED,'pc_results_20k_500.RData') else file.path(OUT,'step4/pc_results_20k_500.RData');read_env(path)}
read_shifts <- function()readRDS(input_file(if(MODE=='saved')file.path(SAVED,'shifts_by_id.rds') else file.path(OUT,'step4/shifts_by_id.rds')))
shift_table <- function(x){
 if(is.data.frame(x)){z<-x;p<-z$pvalue}else{z<-x$shiftDetection;p<-z$empirical_pvalue}
 if(is.null(z)||!is.numeric(z$time_mid)||length(p)!=nrow(z))stop('Unrecognized detector result schema')
 data.frame(time=z$time_mid,pvalue=p,significant=is.finite(p)&p<0.05)
}
# Preserve figure-script rounding, within-record deduplication and cut boundaries.
count_figure_bins <- function(series,round_to=500){
 x<-unlist(lapply(series,function(z)unique(round(z/round_to)*round_to)),use.names=FALSE)
 as.numeric(table(cut(x,breaks=seq(YEAR_RANGE[1],YEAR_RANGE[2],FIGURE_BIN))))
}
frequency <- function(s){den<-count_figure_bins(s$bins);num<-count_figure_bins(s$shifts);data.frame(time=seq(0,19500,500),records=den,shifting_records=num,proportion=ifelse(den>0,num/den,NA_real_))}
read_classes <- function(name){
 x<-read.csv(input_file(file.path(ANC,'classifications',paste0(name,'.csv'))),check.names=FALSE)
 if(ncol(x)==131)x<-x[,-1,drop=FALSE]
 if(ncol(x)!=130)stop('Expected 130 classification columns: ',name)
 names(x)<-as.character(IDS);x
}
save_plot <- function(name,plot,width=8,height=5){
 need('ggplot2')
 ggplot2::ggsave(file.path(OUT,'figures',paste0(name,'.svg')),plot,width=width,height=height)
 ggplot2::ggsave(file.path(OUT,'figures',paste0(name,'.png')),plot,width=width,height=height,dpi=180)
}
require_saved_classification <- function(){if(MODE!='saved')stop('Event categories were manually curated. Review fresh events and supply new classification tables before running category figures; see README.')}
log_session <- function(name)capture.output(sessionInfo(),file=file.path(OUT,'logs',paste0(name,'_session.txt')))

# Operational guards only: no analytical values or settings are changed.
preflight_outputs <- function(paths){
 existing<-paths[file.exists(paths)]
 if(length(existing))stop('Outputs already exist; choose a new ACTR_RUN before computing: ',paste(existing,collapse=', '))
}
check_run_identity <- function(){
 inputs<-list.files(ANC,recursive=TRUE,full.names=TRUE)
 inputs<-inputs[!file.info(inputs)$isdir]
 config<-list(mode=MODE,ids=PROCESS_IDS,local_step1=Sys.getenv('ACTR_LOCAL_STEP1',''),bacon=Sys.getenv('ACTR_RUN_BACON','false'),spatial_recompute=Sys.getenv('ACTR_SPATIAL_RECOMPUTE','false'),
 settings=list(YEAR_RANGE,PCA_BIN,SHIFT_BIN,FIGURE_BIN,N_ENSEMBLES,N_PC,SHIFT_ENSEMBLES,NULL_SIMULATIONS,SHIFT_METHOD,SHIFT_PENALTY,MIN_SEGMENT,SEED,POLLEN_GROUPS,MIN_TAXON_MAX_PCT),
 ancillary=unname(tools::md5sum(inputs)))
 path<-file.path(OUT,'logs/run_configuration.rds')
 if(file.exists(path)){
  if(!identical(readRDS(path),config))stop('Run configuration/input tables differ from this existing run. Choose a new ACTR_RUN.')
 }else saveRDS(config,path)
}
read_record <- function(stage,id){
 a<-readRDS(input_file(record_path(stage,id)))
 if(!identical(as.integer(a$id),as.integer(id)))stop('Record ID mismatch at stage ',stage,': expected ',id)
 a
}
