Sys.setenv(ACTR_MODE='recompute',ACTR_RUN='local_pilot',ACTR_IDS='49925,41269,59883',ACTR_STEP4_PART='shifts',ACTR_RUN_BACON='false')
source('config.R')
s<-read_shifts();stopifnot(identical(as.integer(s$ids),PROCESS_IDS),length(s$bins)==3,length(s$shifts)==3,s$method=='AMOC')
for(id in PROCESS_IDS){a<-read_record(3,id);stopifnot(nrow(a$ageEnsemble_values)==nrow(a$biomes),length(a$depth)==nrow(a$biomes))}
files<-list.files(OUT,recursive=TRUE,full.names=TRUE);before<-tools::md5sum(files)
for(script in c('step1_download_age_models.R','step2_harmonize.R','step3_full_workflow.R','step4_full_workflow_synth.R')){
 msg<-tryCatch({source(script);''},error=function(e)conditionMessage(e))
 stopifnot(grepl('Outputs already exist',msg,fixed=TRUE))
}
stopifnot(identical(before,tools::md5sum(files)))
writeLines(c('Three-record local pilot completed Steps 1-4 with detector-only Step 4', 'All output IDs and prepared dimensions validated', 'Repeating each computational stage refused before overwriting or fitting', 'Pilot output fingerprints unchanged by conflict tests'),file.path(PUB_ROOT,'validation/execution/pilot_checks.txt'))
