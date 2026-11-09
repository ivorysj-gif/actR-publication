# Run from the repository root. Downloads public release assets without credentials.
url <- 'https://github.com/ivorysj-gif/actR-publication/releases/download/v1.0.0/actR-saved-results.zip'
expected <- '13013e0a170540910bd1524770050833067d0f3e594c07e25c07ac9ba5a10830'
if(!file.exists('ancillary/package_sources.csv'))stop('Run this script from the repository root.')
if(dir.exists('.R-library')).libPaths(c(normalizePath('.R-library'),.libPaths()))
if(!requireNamespace('digest',quietly=TRUE))stop('Run install_dependencies.R first (digest is needed for checksum verification).')
archive <- 'actR-saved-results.zip'
if(!file.exists(archive)){
 old_timeout<-getOption('timeout');options(timeout=max(3600,old_timeout))
 tryCatch(download.file(url,archive,mode='wb',method='libcurl'),finally=options(timeout=old_timeout))
}
actual <- digest::digest(file=archive,algo='sha256')
if(!identical(actual,expected))stop('Archive checksum mismatch. Move the failed archive aside and download again.')
entries <- unzip(archive,list=TRUE)$Name
if(any(grepl('(^/|^[A-Za-z]:|(^|/)\\.\\.(/|$))',entries)))stop('Unsafe archive path')
files <- entries[!grepl('/$',entries)]
if(any(file.exists(files)))stop('Bundle destinations already exist; extraction will not overwrite them. Use a fresh clone or use the already extracted bundle.')
unzip(archive,exdir='.')
message('Verified bundle extracted. Historical previews are under outputs/publication; new runs use outputs/reproduced.')
