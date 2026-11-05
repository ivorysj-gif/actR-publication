# Supplementary spatial analysis. This original branch uses PELT, independently
# of the main AMOC synthesis. Saved events are supplied to avoid recomputation.
if(!exists('PUB_ROOT'))source('config.R')
need(c('actR','purrr','dplyr','ggplot2','patchwork'));library(ggplot2)
recompute<-identical(Sys.getenv('ACTR_SPATIAL_RECOMPUTE','false'),'true')
if(recompute){
 e<-read_env(file.path(SAVED,'tp.RData'));tp<-e$tp
 good<-vapply(tp,function(x)nrow(x$ageEnsemble[[1]])==length(x$paleoData_values[[1]]),TRUE)
 tp_good<-tp[good]
 # Preserved separate spatial-script exclusions; these do not alter main 130 IDs.
 if(length(tp_good)<96)stop('Original spatial subset cannot be identified')
 tp_good<-tp_good[-c(79,96)]
 set.seed(SEED)
 events<-purrr::list_rbind(purrr::map(tp_good,actR::detectShift,time.variable.name='ageEnsemble',vals.variable.name='forest',method='PELT',null.hypothesis.n=50,summary.bin.step=500,n.ens=50))
 events<-events[!is.na(events$pvalue),]
 write_new(events,file.path(OUT,'spatial/recomputed_events.rds'))
}else{
 e<-read_env(file.path(SAVED,'events8.2.RData'))
 if(!exists('events8.2',e,inherits=FALSE))stop('Missing events8.2 object')
 events<-e$events8.2
}
lon.range<-range(events$geo_longitude,na.rm=TRUE)+c(-5,5)
lat.range<-range(events$geo_latitude,na.rm=TRUE)+c(-5,5)
dist.grid<-actR::distanceGrid(events,lon.range=lon.range,lat.range=lat.range,grid.resolution=3)
spatial_window<-function(lo,hi){
 ev<-events[events$time_mid>=lo & events$time_mid<hi,]
 if(!nrow(ev))stop('No spatial events in window ',lo,'-',hi)
 cache<-file.path(OUT,'spatial',paste0('grid_',lo,'_',hi,'.rds'))
 if(file.exists(cache))g<-readRDS(cache) else {
  g<-purrr::map(dist.grid,actR::spatialSigTest,events=ev,agg.method='robustNull',use.weights=TRUE,distance.cutoff=1000)
  saveRDS(g,cache)
 }
 lapply(c('pvalPos','pvalNeg'),function(test)actR::plotSignificance(g,sigTestResults=ev,which.test=test,color.breaks=c(.01,.05,.1,.2),restrict.sites=TRUE,alpha.by.weight=TRUE,cutoff.distance=1000,x.lim=lon.range,y.lim=lat.range))
}
for(w in list(c(0,3000),c(3000,6000))){
 z<-spatial_window(w[1],w[2])
 colors<-list(c('#00441B','#238B45','#74C476','#F2F2F2','#F2F2F2'),c('#7F2704','#D94801','#FDAE6B','#F2F2F2','#F2F2F2'))
 plots<-lapply(1:2,function(i)z[[i]]$plot+scale_fill_stepsn(colours=colors[[i]],breaks=c(.01,.025,.05,.1,.15),limits=c(.01,.20),name='pval')+ggtitle(c('Forest increase','Forest loss')[i])+theme_classic())
 save_plot(paste0('spatial_sign_',w[1],'_',w[2],'_posneg'),patchwork::wrap_plots(plots),15,7.5)
}
# Original index includes 0-500 through 20,000-20,500 BP (41 intervals).
if(identical(Sys.getenv('ACTR_SPATIAL_INDEX','false'),'true')){
 rows<-lapply(seq(0,20000,500),function(t){z<-spatial_window(t,t+500);v<-vapply(z,function(a){d<-a$plot.data;sum(d$weight[d$pval<.05],na.rm=TRUE)/sum(d$weight,na.rm=TRUE)},1);data.frame(time=t,positive=v[1],negative=v[2])})
 index<-do.call(rbind,rows);write.csv(index,file.path(OUT,'spatial/weighted_index.csv'),row.names=FALSE)
 long<-rbind(data.frame(time=index$time,type='positive',value=index$positive),data.frame(time=index$time,type='negative',value=index$negative))
 g<-ggplot(long,aes(time,value,color=type))+geom_line(linewidth=1)+geom_point(size=2)+scale_color_manual(values=c(positive='#238B45',negative='#D94801'))+theme_classic()+labs(x='Time bin',y='Weighted spatial significance index',color='')
 save_plot('spatial_sign_weighted_ind_posneg',g,15,7.5)
}
log_session('spatial')
