# Optional installation helper; no installations occur when running the analysis.
# Run this explicitly in an R environment/library you manage.
cran<-c('neotoma2','dplyr','tidyr','purrr','ggplot2','mgcv','terra','sf','patchwork','remotes','BiocManager','changepoint','rbacon')
missing<-cran[!vapply(cran,requireNamespace,TRUE,quietly=TRUE)]
if(length(missing))install.packages(missing,repos='https://cloud.r-project.org')
if(!requireNamespace('pcaMethods',quietly=TRUE))BiocManager::install('pcaMethods',ask=FALSE,update=FALSE)
# Commit-pinned GitHub dependencies are recorded in ancillary/package_sources.csv.
sources<-read.csv('ancillary/package_sources.csv',stringsAsFactors=FALSE)
for(i in seq_len(nrow(sources))){
 if(!requireNamespace(sources$package[i],quietly=TRUE))remotes::install_github(paste0(sources$repository[i],'@',sources$commit[i]),upgrade='never')
}
message('Run Rscript run.R check. See validation/build_environment_packages.csv for tested versions; this helper does not claim a full transitive lockfile.')
