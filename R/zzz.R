.settings_file <- ".epivizr-standalone"
.default_settings <- list(url="http://github.com/epiviz/epivizr.git", 
                          branch="master", 
                          local_path=NULL)

.onLoad <- function(libname = find.package("epivizrStandalone"), pkgname = "epivizrStandalone") {
  settings_file <- file.path(normalizePath("~"), epivizrStandalone:::.settings_file)
  dput(.default_settings, file=settings_file)
}