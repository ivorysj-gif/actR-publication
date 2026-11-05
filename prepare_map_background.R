# Optional rebuild of the supplied small NDVI map background from original rasters.
if(!exists('PUB_ROOT'))source('config.R')
need('terra')
path<-Sys.getenv('ACTR_NDVI_DIR','');if(!nzchar(path))stop('Set ACTR_NDVI_DIR to the original monthly NDVI TIFF directory')
files<-list.files(path,'\\.tif$',full.names=TRUE);if(!length(files))stop('No NDVI TIFF files')
z<-terra::rast(files);forest<-terra::ifel(terra::app(z,mean,na.rm=TRUE)>.6,1,0)
names(forest)<-'cover'
small<-terra::aggregate(forest,fact=15,fun='modal',na.rm=TRUE)
# Writes into this run; never overwrites the supplied ancillary background.
terra::writeRaster(small,file.path(OUT,'forest_background.tif'),overwrite=FALSE,gdal=c('COMPRESS=DEFLATE'))
