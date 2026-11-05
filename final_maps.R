# Final event maps: original 0-3000 and 3000-6000 BP windows and event colors.
if(!exists('PUB_ROOT'))source('config.R')
require_saved_classification();need(c('terra','ggplot2'));library(ggplot2)
meta<-read.csv(file.path(ANC,'site_metadata.csv'));stopifnot(identical(meta$datasetid,IDS))
background<-terra::rast(input_file(file.path(ANC,'forest_background.tif')))
forest_df<-as.data.frame(background,xy=TRUE,na.rm=TRUE);names(forest_df)<-c('x','y','cover');forest_df$cover<-factor(forest_df$cover,levels=0:1)
classes<-lapply(c('rise','abrupt_decrease','abrupt_loss','gradual_loss'),read_classes);names(classes)<-c('rise','decrease','abrupt','gradual')
for(window in list(c(0,3000),c(3000,6000))){
 flags<-lapply(classes,function(x)vapply(x,function(t)any(is.finite(t)&t>=window[1]&t<=window[2]),TRUE))
 # Preserve overlaps and original drawing order rather than assigning new categories.
 g<-ggplot()+geom_raster(data=forest_df,aes(x,y,fill=cover))+scale_fill_manual(name='Forest cover',values=c('0'='grey90','1'='forestgreen'),na.translate=FALSE)+geom_point(data=meta,aes(longitude,latitude),color='grey35',size=3.5,alpha=.55)
 g<-g+geom_point(data=meta[flags$gradual,],aes(longitude,latitude),color='#3b13a0',size=4)+geom_point(data=meta[flags$decrease,],aes(longitude,latitude),color='#D55E00',size=4)+geom_point(data=meta[flags$abrupt,],aes(longitude,latitude),color='#A01813',size=4)+coord_equal()+theme_classic()+theme(text=element_text(size=20))+labs(x='Longitude',y='Latitude')
 save_plot(paste0('all_afr_forest_grad_abrupt',window[2],'_final'),g,11,8)
 write.csv(data.frame(meta,as.data.frame(flags)),file.path(OUT,'figures',paste0('map_sites_',window[1],'_',window[2],'.csv')),row.names=FALSE)
}
log_session('maps')
