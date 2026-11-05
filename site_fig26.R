# Original hand-selected positions within the positive-PC1 ranked records.
if(!exists('PUB_ROOT'))source('config.R')
need(c('geoChronR','lipdR','dplyr','ggplot2'))
p<-read_pca();TS<-p$TS.filtered2
loading<-apply(p$pcout2$loadings,c(1,2),median,na.rm=TRUE)[,1]
ord<-order(loading,decreasing=TRUE);selection<-c(1,3,8,6,5,4,13,16,9,2,12,20)
if(length(TS)<max(selection))stop('Original curated site stack requires at least 20 records')
for(i in seq_along(TS))TS[[i]]$age<-apply(TS[[i]]$ageEnsemble,1,median,na.rm=TRUE)
chosen<-TS[ord[selection]]
dat<-lipdR::tidyTs(chosen,age.var='age');dat<-dat[dat$age>=0 & dat$age<=20000,]
write.csv(data.frame(rank=selection,site=vapply(chosen,function(x)x$geo_siteName,'')),file.path(OUT,'figures/site_stack_selection.csv'),row.names=FALSE)
svg(file.path(OUT,'figures/pos_plots.svg'),width=6,height=8)
print(geoChronR::plotTimeseriesStack(dat,time.var='age',color.var='paleoData_variableName',color.ramp=c('DarkBlue','Orange','Black','Dark Green'),line.size=.1,fill.alpha=0,lab.size=2,lab.space=3));dev.off()
png(file.path(OUT,'figures/pos_plots.png'),width=1200,height=1600,res=180)
print(geoChronR::plotTimeseriesStack(dat,time.var='age',color.var='paleoData_variableName',color.ramp=c('DarkBlue','Orange','Black','Dark Green'),line.size=.1,fill.alpha=0,lab.size=2,lab.space=3));dev.off()
log_session('site_figures')

# Additional review panel: the same selected sites with curated event annotations.
if(MODE=='saved'){
 library(ggplot2)
 selected_ids<-IDS[ord[selection]]
 series<-do.call(rbind,lapply(seq_along(chosen),function(i)data.frame(site=chosen[[i]]$geo_siteName,time=chosen[[i]]$age,forest=as.numeric(chosen[[i]]$paleoData_values))))
 event_rows<-list()
 for(nm in c('rise','abrupt_decrease','abrupt_loss','gradual_loss')){
  cl<-read_classes(nm)
  for(i in seq_along(selected_ids)){
   t<-cl[[as.character(selected_ids[i])]];t<-t[is.finite(t)&t>=0&t<=20000]
   if(length(t))event_rows[[length(event_rows)+1]]<-data.frame(site=chosen[[i]]$geo_siteName,time=t,type=nm)
  }
 }
 series$site<-factor(series$site,levels=vapply(chosen,function(x)x$geo_siteName,''))
 ev<-do.call(rbind,event_rows)
 g<-ggplot(series[series$time>=0&series$time<=20000,],aes(time,forest))+geom_line()+geom_vline(data=ev,aes(xintercept=time,color=type),linewidth=.35,alpha=.75)+facet_wrap(~site,ncol=2,scales='free_y')+scale_x_reverse()+scale_color_manual(values=c(rise='forestgreen',abrupt_decrease='grey50',abrupt_loss='#D55E00',gradual_loss='steelblue'))+theme_classic()+labs(x='Years BP',y='Forest affinity',color='Curated event')
 save_plot('selected_sites_with_events',g,10,12)
}
