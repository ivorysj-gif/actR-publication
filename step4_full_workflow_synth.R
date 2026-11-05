# Step 4: age-uncertain PCA, abrupt-change calculation, and synthesis.
if(!exists('PUB_ROOT'))source('config.R')
if(MODE!='recompute')stop('Step 4 computes new results. Set ACTR_MODE=recompute; saved figures do not need Step 4.')
need(c('lipdR','geoChronR','actR','purrr','dplyr'))
PART <- Sys.getenv('ACTR_STEP4_PART','both');stopifnot(PART%in%c('both','pca','shifts'))
records<-lapply(PROCESS_IDS,function(id)readRDS(input_file(record_path(3,id))))

# 1. Attach biomes at verified sample depths, then map ages by depth.
D<-lapply(records,function(a){
 ll<-a$L_lip;values<-data.frame(depth=a$depth,a$biomes,check.names=FALSE)
 tab<-lapply(names(values),function(nm)list(values=as.numeric(values[[nm]]),variableName=nm,units=if(nm=='depth')'cm' else 'percent',TSid=lipdR::createTSid()));names(tab)<-names(values)
 ll$paleoData[[1]]$measurementTable[[2]]<-tab;ll
})
FD<-purrr::map(D,geoChronR::mapAgeEnsembleToPaleoData,strict.search=TRUE,age.var='ageEnsemble',paleo.age.var=NULL,chron.depth.var='depth',paleo.depth.var='depth',paleo.meas.table.num=2)
TS<-lipdR::extractTs(FD);TS.filtered2<-lipdR::filterTs(TS,'variableName == forest')
if(length(TS.filtered2)!=length(records))stop('Expected exactly one forest series per record')
for(i in seq_along(records)){
 # Use the verified depth crosswalk directly; do not trust row-count equality alone.
 TS.filtered2[[i]]$ageEnsemble<-records[[i]]$ageEnsemble_values
 TS.filtered2[[i]]$paleoData_values<-matrix(records[[i]]$biomes$forest,ncol=1)
 TS.filtered2[[i]]$depth<-records[[i]]$depth
}
saveRDS(list(ids=PROCESS_IDS,TS=TS.filtered2),file.path(OUT,'step4/forest_series_by_id.rds'))

# 2. Covariance Monte Carlo PCA: original 500-year grid, 8 PCs, 1,000 realizations.
if(PART%in%c('both','pca')){
 if(length(records)<N_PC)stop('PCA needs at least ',N_PC,' records; use ACTR_STEP4_PART=shifts for a small pilot')
 set.seed(SEED)
 binned.TS2<-geoChronR::binTs(TS.filtered2,bin.vec=seq(0,20000,PCA_BIN),time.var='ageEnsemble',max.ens=N_ENSEMBLES)
 set.seed(SEED)
 pcout2<-geoChronR::pcaEns(binned.TS2,pca.type='cov',method='ppca',n.pcs=N_PC,n.ens=N_ENSEMBLES)
 valid_ids<-PROCESS_IDS
 dest<-file.path(OUT,'step4/pc_results_20k_500.RData');if(file.exists(dest))stop('Choose a new ACTR_RUN; PCA output already exists')
 save(pcout2,TS.filtered2,valid_ids,file=dest)
}

# 3. Abrupt change: explicit historical AMOC settings, not package defaults.
if(PART%in%c('both','shifts')){
 bins<-shifts<-setNames(vector('list',length(records)),PROCESS_IDS)
 for(i in seq_along(records)){
  a<-records[[i]];id<-PROCESS_IDS[i]
  time<-a$ageEnsemble_values;vals<-a$biomes$forest
  stopifnot(nrow(time)==length(vals),all(is.finite(time)),all(is.finite(vals)))
  chronology<-a$L_lip$chronData[[1]]$model[[1]]$summaryTable[[1]]$age$values
  if(!length(chronology)||any(!is.finite(chronology)))stop('Invalid chronology-summary range at ',id)
  result<-actR::detectShift(time=time,vals=vals,time.variable.name='age',time.units='BP',vals.variable.name='Forest',vals.units='%',dataset.name=as.character(id),summary.bin.step=SHIFT_BIN,time.range=range(chronology),method=SHIFT_METHOD,penalty=SHIFT_PENALTY,minimum.segment.length=MIN_SEGMENT,n.ens=SHIFT_ENSEMBLES,null.hypothesis.n=NULL_SIMULATIONS,surrogate.method='isospectral',seed=SEED+id,progress=FALSE)
  z<-shift_table(result);stopifnot(all(abs(diff(z$time)-SHIFT_BIN)<1e-6))
  write_new(result,file.path(OUT,'step4',paste0('detector_',id,'.rds')))
  write.csv(z,file.path(OUT,'step4',paste0('detector_',id,'.csv')),row.names=FALSE)
  bins[[i]]<-z$time;shifts[[i]]<-z$time[z$significant]
 }
 write_new(list(ids=PROCESS_IDS,bins=bins,shifts=shifts,method=SHIFT_METHOD),file.path(OUT,'step4/shifts_by_id.rds'))
 write.csv(frequency(list(bins=bins,shifts=shifts)),file.path(OUT,'step4/abrupt_frequency.csv'),row.names=FALSE)
}
log_session('step4')
