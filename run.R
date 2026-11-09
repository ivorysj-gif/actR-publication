args<-commandArgs(FALSE);f<-sub('^--file=','',args[grepl('^--file=',args)])
if(length(f))setwd(dirname(normalizePath(f,winslash='/')))
source('config.R')
tasks<-commandArgs(TRUE);if(!length(tasks))tasks<-'figures'
allowed<-c('check','step1','step2','step3','step4','figures','maps','sites','spatial')
if(any(!tasks%in%allowed))stop('Tasks: ',paste(allowed,collapse=', '))
scripts<-c(check='check_environment.R',step1='step1_download_age_models.R',step2='step2_harmonize.R',step3='step3_full_workflow.R',step4='step4_full_workflow_synth.R',figures='figs_2026.R',maps='final_maps.R',sites='site_fig26.R',spatial='spat_sign26.R')
for(task in tasks){message('Running ',task);if(task!='check')check_run_identity();source(scripts[[task]],local=.GlobalEnv)}
