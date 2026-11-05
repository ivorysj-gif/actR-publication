# Step 3: harmonization, percentage calculation and biomization.
if(!exists('PUB_ROOT'))source('config.R')
need(c('dplyr','tidyr'))
lookup<-readRDS(input_file(file.path(OUT,'step2/taxon_lookup.rds')))
pft<-read.csv(file.path(ANC,'harm_names_all_forest2024.csv'),check.names=TRUE)
stopifnot(!anyDuplicated(pft$real_names),identical(names(pft)[7:11],c('temp_trees','forest','savanna.steppe','desert','grass')))
for(id in PROCESS_IDS){
 a<-readRDS(input_file(record_path(1,id)));x<-a$my_counts
 x<-x[x$ecologicalgroup%in%POLLEN_GROUPS,];x$real_names<-lookup$real_names[match(x$variablename,lookup$variablename)]
 if(anyNA(x$real_names)||any(!nzchar(x$real_names))||any(!is.finite(x$value))||any(x$value<0))stop('Invalid/unmapped counts at ',id)
 # Keep historical age-based pooling, including Rusaka's 9100 BP group.
 sumx<-dplyr::summarise(dplyr::group_by(x,age,real_names),value=sum(value),.groups='drop')
 wide<-tidyr::pivot_wider(sumx,names_from=real_names,values_from=value,values_fill=0,id_cols=age)
 mat<-as.matrix(wide[,-1]);total<-rowSums(mat);if(any(total<=0))stop('Zero sample total at ',id)
 pct<-mat/total*100;pct<-pct[,apply(pct,2,max,na.rm=TRUE)>MIN_TAXON_MAX_PCT,drop=FALSE]
 member<-as.matrix(pft[match(colnames(pct),pft$real_names),7:11]);missing<-colnames(pct)[is.na(match(colnames(pct),pft$real_names))]
 write.csv(data.frame(taxon=missing),file.path(OUT,'step3',paste0('missing_PFT_',id,'.csv')),row.names=FALSE)
 member[is.na(member)]<-0 # Preserve original na.rm sum: no invented assignment.
 aff<-sqrt(pct)%*%member
 bm<-data.frame(forest=aff[,'forest'],savanna=aff[,'savanna.steppe']+aff[,'grass'],desert=aff[,'desert']+aff[,'grass']);names(bm)[2]<-'savanna/steppe'
 samples<-unique(x[,c('sampleid','depth','age')]);dep<-as.numeric(a$L_lip$paleoData[[1]]$measurementTable[[1]]$depth$values)
 if(anyDuplicated(dep)||length(dep)!=nrow(a$ageEnsemble$values))stop('Ambiguous ensemble/depth mapping: ',id)
 keep<-is.finite(wide$age);if(id==52842)keep<-keep & wide$age!=0
 selected_depth<-vapply(wide$age[keep],function(age){d<-unique(samples$depth[!is.na(samples$age)&samples$age==age]);if(length(d)>1 && !(id==2312 && age==9100))stop('Unreviewed duplicate-age pooling at ',id);if(length(d)==0)stop('No sample depth at ',id);min(d)},numeric(1))
 idx<-match(selected_depth,dep);if(anyNA(idx))stop('Unmatched depth: ',id)
 a$biomes<-bm[keep,,drop=FALSE];a$depth<-selected_depth;a$biome_age<-wide$age[keep];a$ageEnsemble_values<-a$ageEnsemble$values[idx,,drop=FALSE]
 a$retained_taxa<-colnames(pct);a$sample_totals<-total
 write.csv(data.frame(age=wide$age,retained=keep),file.path(OUT,'step3',paste0('age_group_audit_',id,'.csv')),row.names=FALSE)
 if(any(!is.finite(a$ageEnsemble_values)))stop('Nonfinite modeled ages: ',id)
 write_new(a,record_path(3,id))
}
log_session('step3')
