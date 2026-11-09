# Step 2: compare pollen names against the supplied nomenclature master.
if(!exists('PUB_ROOT'))source('config.R')
preflight_outputs(file.path(OUT,'step2',c('taxon_lookup.rds','master_mapping_audit.csv','taxon_review.csv')))
master<-read.csv(file.path(ANC,'APD_taxon_list_2024.csv'),check.names=TRUE)
lookup<-data.frame(variablename=master$ORIGINAL.NAMES,real_names=master$REVISED.NOMENCLATURE..2022.)
# Original distinct(variablename, .keep_all=TRUE) policy, explicitly recorded.
lookup$master_row<-seq_len(nrow(lookup));lookup$selected<-!duplicated(lookup$variablename)
write.csv(lookup,file.path(OUT,'step2/master_mapping_audit.csv'),row.names=FALSE)
lookup<-lookup[lookup$selected,c('variablename','real_names')]
saveRDS(lookup,file.path(OUT,'step2/taxon_lookup.rds'))
rows<-lapply(PROCESS_IDS,function(id){x<-readRDS(input_file(record_path(1,id)))$my_counts;x<-unique(x[x$ecologicalgroup%in%POLLEN_GROUPS,'variablename',drop=FALSE]);x$datasetid<-id;x$real_names<-lookup$real_names[match(x$variablename,lookup$variablename)];x})
review<-do.call(rbind,rows);write.csv(review,file.path(OUT,'step2/taxon_review.csv'),row.names=FALSE)
if(anyNA(review$real_names)||any(!nzchar(review$real_names)))stop('Unmapped taxa: inspect taxon_review.csv; no inferred assignments made.')
log_session('step2')
