# Technical checks only; no detector/PCA fitting or classification changes.
source('config.R')
evidence<-file.path(PUB_ROOT,'validation/execution');dir.create(evidence,recursive=TRUE,showWarnings=FALSE)
scripts<-c(list.files(PUB_ROOT,pattern='\\.R$',full.names=TRUE),list.files(file.path(PUB_ROOT,'R'),pattern='\\.R$',full.names=TRUE))
for(f in scripts)parse(f)
expect_error<-function(expr,text){msg<-tryCatch({force(expr);''},error=function(e)conditionMessage(e));if(!grepl(text,msg,fixed=TRUE))stop('Expected error: ',text,'; got: ',msg);msg}
tmp<-tempfile();saveRDS(1,tmp);expect_error(preflight_outputs(tmp),'Outputs already exist');stopifnot(identical(readRDS(tmp),1));unlink(tmp)
oldout<-OUT;oldmode<-MODE;oldids<-PROCESS_IDS
OUT<-tempfile();dir.create(file.path(OUT,'logs'),recursive=TRUE);MODE<-'recompute';PROCESS_IDS<-head(IDS,3)
check_run_identity();PROCESS_IDS<-rev(PROCESS_IDS);expect_error(check_run_identity(),'Run configuration/input tables differ');PROCESS_IDS<-head(IDS,3)
source('check_environment.R') # Must work before any Step 4 outputs exist.
dir.create(file.path(OUT,'step3'));saveRDS(list(id=-1),record_path(3,PROCESS_IDS[1]))
expect_error(read_record(3,PROCESS_IDS[1]),'Record ID mismatch')
OUT<-oldout;MODE<-oldmode;PROCESS_IDS<-oldids
# Baseline numerical output comparisons. No historical files are rewritten.
base<-file.path(PUB_ROOT,'outputs/publication/figures');fresh<-file.path(OUT,'figures')
csvs<-c('abrupt_frequency.csv','all_event_category_proportions.csv','map_sites_0_3000.csv','map_sites_3000_6000.csv','site_stack_selection.csv')
results<-lapply(csvs,function(n){a<-read.csv(file.path(base,n));b<-read.csv(file.path(fresh,n));ok<-isTRUE(all.equal(a,b,tolerance=1e-12));stopifnot(ok);data.frame(file=n,match=ok)})
write.csv(do.call(rbind,results),file.path(evidence,'numerical_output_checks.csv'),row.names=FALSE)
models<-list.files(base,pattern='^gam_.*\\.rds$')
need('mgcv');library(mgcv)
for(n in models){a<-readRDS(file.path(base,n));b<-readRDS(file.path(fresh,n));grid<-data.frame(times=seq(0,19500,length.out=100));stopifnot(isTRUE(all.equal(as.numeric(predict(a,grid)),as.numeric(predict(b,grid)),tolerance=1e-10)))}
files<-list.files(fresh,pattern='\\.(png|svg)$',full.names=TRUE)
stopifnot(length(files)==42,all(file.info(files)$size>0))
write.csv(data.frame(file=basename(files),bytes=file.info(files)$size),file.path(evidence,'figure_inventory.csv'),row.names=FALSE)
writeLines(c(paste(length(scripts),'R scripts parse'), 'Output-conflict guard preserves existing file', 'Changed run IDs rejected', 'Fresh three-ID environment check works without Step 4 outputs', 'Mismatched record ID rejected', 'Five saved figure data tables match bundled values',paste(length(models),'saved group GAM predictions match'),'42 nonempty PNG/SVG panels present'),file.path(evidence,'checks.txt'))
capture.output(sessionInfo(),file=file.path(evidence,'sessionInfo.txt'))
