# Shared dependency lists; no installation is performed by the workflow.
dependency_packages <- function(scope='saved') {
 saved <- c('lipdR','geoChronR','actR','dplyr','purrr','mgcv','ggplot2','terra','patchwork','svglite','digest')
 fresh <- c('neotoma2','lipdR','geoChronR','actR','changepoint','dplyr','tidyr','purrr','pcaMethods')
 switch(scope, saved=saved, recompute=fresh, all=unique(c(saved,fresh,'rbacon')), stop('Unknown dependency scope: ',scope))
}
dependency_report <- function(pkgs) {
 data.frame(package=pkgs,installed=vapply(pkgs,requireNamespace,TRUE,quietly=TRUE),
 version=vapply(pkgs,function(p)if(requireNamespace(p,quietly=TRUE))as.character(packageVersion(p)) else NA_character_,''))
}
