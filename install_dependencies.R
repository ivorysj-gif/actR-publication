# Optional installation helper; no installations occur when running the analysis.
# Run this explicitly in an R environment/library you manage.
if(!file.exists('R/dependencies.R'))stop('Run from the repository root.')
dir.create('.R-library',showWarnings=FALSE)
.libPaths(c(normalizePath('.R-library'),.libPaths()))
source('R/dependencies.R')
scope<-Sys.getenv('ACTR_INSTALL_SCOPE','saved')
pkgs<-unique(c(dependency_packages(scope),'digest','remotes','BiocManager'))
sources<-read.csv('ancillary/package_sources.csv',stringsAsFactors=FALSE)
cran<-setdiff(pkgs,c(sources$package,'pcaMethods'))
missing<-cran[!vapply(cran,requireNamespace,TRUE,quietly=TRUE)]
if(length(missing))install.packages(missing,repos='https://cloud.r-project.org')
if('pcaMethods'%in%pkgs && !requireNamespace('pcaMethods',quietly=TRUE))BiocManager::install('pcaMethods',ask=FALSE,update=FALSE)
# Commit-pinned GitHub dependencies are recorded in ancillary/package_sources.csv.
sources<-read.csv('ancillary/package_sources.csv',stringsAsFactors=FALSE)
for(i in seq_len(nrow(sources))){
 if(sources$package[i]%in%pkgs && !requireNamespace(sources$package[i],quietly=TRUE))remotes::install_github(paste0(sources$repository[i],'@',sources$commit[i]),upgrade='never')
 if(requireNamespace(sources$package[i],quietly=TRUE)){
  desc<-packageDescription(sources$package[i]);sha<-desc$RemoteSha
  message(sources$package[i],': installed ',desc$Version,'; tested ',sources$version[i],'; source commit ',if(is.null(sha))'not recorded' else sha)
  if(desc$Version!=sources$version[i] || (!is.null(sha)&&sha!=sources$commit[i]))warning('Installed package differs from tested source; it was not replaced.')
 }
}
tab<-dependency_report(pkgs);print(tab)
if(any(!tab$installed))stop('Installation incomplete; resolve the messages above and rerun.')
message('Run Rscript run.R check. See validation/build_environment_packages.csv for tested versions; this helper does not claim a full transitive lockfile.')
