# Step 1: Neotoma download, count extraction and age-model preparation.
if(!exists('PUB_ROOT'))source('config.R')
preflight_outputs(vapply(PROCESS_IDS,function(id)record_path(1,id),''))
need(c('neotoma2','lipdR','geoChronR'))
LOCAL_STEP1 <- Sys.getenv('ACTR_LOCAL_STEP1','')
RUN_BACON <- identical(Sys.getenv('ACTR_RUN_BACON','false'),'true')
if(RUN_BACON)need('rbacon')
for(id in PROCESS_IDS){
 dest<-record_path(1,id)
 if(nzchar(LOCAL_STEP1)){
  files<-list.files(LOCAL_STEP1,paste0(id,'\\.RData$'),full.names=TRUE);if(length(files)!=1)stop('Expected one local Step 1 file for ',id)
  e<-read_env(files);needed<-c('L_lip','my_counts','ageEnsemble');stopifnot(all(needed%in%ls(e)))
  item<-mget(needed,e);item$id<-id;item$source<-files
 }else{
  L<-neotoma2::get_downloads(id)
  item<-list(id=id,L_lip=lipdR::neotoma2lipd(L),my_counts=neotoma2::samples(L),source='Fresh Neotoma download')
  if(RUN_BACON){
   oldwd<-getwd();setwd(file.path(OUT,'age_models'))
   item$L_lip<-tryCatch(geoChronR::runBacon(item$L_lip,bacon.dir=file.path(OUT,'age_models'),lab.id.var='neotomaChronConrolId',age.14c.var='age14C',age.14c.uncertainty.var='age14CUnc',age.var='age',age.uncertainty.var='ageUnc',depth.var='depth',cc=if(as.numeric(item$L_lip$geo$latitude)>0)1 else 3,reservoir.age.14c.var=NULL,reservoir.age.14c.uncertainty.var=NULL,rejected.ages.var=NULL,plot.pdf=FALSE,accept.suggestions=TRUE),finally=setwd(oldwd))
   item$L_lip<-geoChronR::mapAgeEnsembleToPaleoData(item$L_lip)
  }
  item$ageEnsemble<-tryCatch(lipdR::selectData(item$L_lip,'ageEnsemble'),error=function(e)NULL)
 }
 if(is.null(item$ageEnsemble)||is.null(item$ageEnsemble$values))stop('No usable modeled age ensemble for ',id,'. Enable ACTR_RUN_BACON=true or supply reviewed local Step 1 data.')
 write_new(item,dest)
}
log_session('step1')
