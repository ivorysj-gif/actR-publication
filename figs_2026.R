# Paper figure panels: PCA, all-record abrupt changes, and curated event types.
if(!exists('PUB_ROOT'))source('config.R')
need(c('geoChronR','lipdR','ggplot2','mgcv'))
library(ggplot2)
pca<-read_pca();pcout2<-pca$pcout2;TS.filtered2<-pca$TS.filtered2
s<-read_shifts()

# 1. Scree and PCA plot, using the original geoChronR plotting functions/settings.
for(ext in c('svg','png')){
 path<-file.path(OUT,'figures',paste0('scree.',ext))
 if(ext=='svg')svg(path,width=6,height=4) else png(path,width=1200,height=800,res=180)
 print(geoChronR::plotScreeEns(pcout2));dev.off()
 path<-file.path(OUT,'figures',paste0('pca.',ext))
 if(ext=='svg')svg(path,width=8,height=6) else png(path,width=1600,height=1200,res=180)
 z<-geoChronR::plotPcaEns(ens.pc.out=pcout2,TS=TS.filtered2,map.type='line',probs=c(.025,.25,.5,.75,.975),shape.by.archive=FALSE,projection='sinusoidal',which.pcs=1,which.leg=1,restrict.map.range=TRUE)
 if(inherits(z,'ggplot'))print(z)
 dev.off()
}

# 2. All-record proportions. No second application of to_rm.csv.
dat<-frequency(s);write.csv(dat,file.path(OUT,'figures/abrupt_frequency.csv'),row.names=FALSE)
m<-mgcv::gam(proportion~s(time),data=dat) # Original overall GAM: default fitting, no REML override.
saveRDS(m,file.path(OUT,'figures/overall_gam.rds'))
pred<-predict(m,newdata=dat,se.fit=TRUE);dat$fit<-as.numeric(pred$fit);dat$se<-as.numeric(pred$se.fit)
plot<-ggplot(dat,aes(time,proportion))+geom_point()+geom_ribbon(aes(ymin=fit-se,ymax=fit+se),alpha=.2)+geom_line(aes(y=fit),color='steelblue')+scale_x_reverse()+theme_classic()+labs(x='Years BP',y='Proportion of records with abrupt change')
save_plot('overall_abrupt_GAM',plot,8,4)

# 3. Historical manually curated positive/negative PC1 event-class panels.
# These supplied tables were used in the original figure script. They are not
# automatically recalculated from newly detected events or altered site groups.
if(MODE=='saved'){
 for(group in c('positive','negative')){
  dat<-read.csv(file.path(ANC,'classifications',paste0(group,'_sites.csv')),check.names=TRUE)
  if(ncol(dat)==7)dat<-dat[,-1]
  if(group=='negative')names(dat)<-c('time','all','rise','decline','abruptloss','gradloss')
  stopifnot(all(c('time','rise','decline','abruptloss','gradloss')%in%names(dat)))
  dat$times<-dat$time
  for(variable in c('rise','decline','abruptloss','gradloss')){
   term<-if(group=='negative'||variable=='gradloss')'s(times,k=6,sp=0)' else if(variable=='decline')"s(times,bs='cr')" else 's(times)'
   f<-as.formula(paste(variable,'~',term));m<-mgcv::gam(f,data=dat)
   # Original figure plots the centered smooth with partial residuals and +/-1 SE.
   tmp<-tempfile(fileext='.pdf');pdf(tmp);po<-plot(m,residuals=TRUE)[[1]];dev.off();unlink(tmp)
   sm<-data.frame(time=as.numeric(po$x),fit=as.numeric(po$fit),se=as.numeric(po$se))
   raw<-data.frame(time=as.numeric(po$raw),value=as.numeric(po$p.resid))
   g<-ggplot(sm,aes(time,fit))+geom_ribbon(aes(ymin=fit-se,ymax=fit+se),alpha=.3)+geom_line()+geom_point(data=raw,aes(time,value))+theme_light()+labs(x='Years BP',y=paste(group,variable,'(centered smooth)'))
   save_plot(paste0('pc1_',group,'_',variable),g,7,3)
   saveRDS(m,file.path(OUT,'figures',paste0('gam_',group,'_',variable,'.rds')))
  }
 }
}
log_session('figures')

# 4. Continental event-category panels from the supplied classification matrices.
if(MODE=='saved'){
 den<-count_figure_bins(s$bins)
 dat<-data.frame(times=seq(0,19500,500),rise=count_figure_bins(read_classes('rise'))/den,decline=count_figure_bins(read_classes('abrupt_decrease'))/den,abruptloss=count_figure_bins(read_classes('abrupt_loss'))/den,gradloss=count_figure_bins(read_classes('gradual_loss'),round_to=250)/den)
 write.csv(dat,file.path(OUT,'figures/all_event_category_proportions.csv'),row.names=FALSE)
 for(variable in c('rise','decline','abruptloss','gradloss')){
  term<-if(variable=='gradloss')'s(times,k=6,sp=0)' else if(variable=='decline')"s(times,bs='cr')" else 's(times)'
  m<-mgcv::gam(as.formula(paste(variable,'~',term)),data=dat)
  tmp<-tempfile(fileext='.pdf');pdf(tmp);po<-plot(m,residuals=TRUE)[[1]];dev.off();unlink(tmp)
  sm<-data.frame(time=as.numeric(po$x),fit=as.numeric(po$fit),se=as.numeric(po$se));raw<-data.frame(time=as.numeric(po$raw),value=as.numeric(po$p.resid))
  g<-ggplot(sm,aes(time,fit))+geom_ribbon(aes(ymin=fit-se,ymax=fit+se),alpha=.3)+geom_line()+geom_point(data=raw,aes(time,value))+theme_light()+labs(x='Years BP',y=paste(variable,'(centered smooth)'))
  save_plot(paste0('all_',variable),g,7,3)
 }
}
