# Exercise the README helper's public download and extraction, with no local ZIP reuse.
root<-normalizePath(getwd(),winslash='/');source('config.R')
target<-file.path(root,'validation/execution/network_download')
dir.create(file.path(target,'ancillary'),recursive=TRUE,showWarnings=FALSE)
file.copy('ancillary/package_sources.csv',file.path(target,'ancillary/package_sources.csv'),overwrite=FALSE)
if(file.exists(file.path(target,'actR-saved-results.zip')))stop('Use a new test target to exercise a fresh network download.')
setwd(target);source(file.path(root,'download_saved_results.R'));setwd(root)
writeLines('Public R libcurl download, SHA-256 verification and safe extraction completed end-to-end.','validation/execution/network_download_check.txt')
