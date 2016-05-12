.default_settings <- list(url="http://github.com/epiviz/epivizr.git", 
                          branch="min", 
                          local_path=NULL,
                          index_file="epivizr-standalone.html")

.onLoad <- function(libname = find.package("epivizrStandalone"), pkgname = "epivizrStandalone") {
  webpath <- tryCatch(system.file("www", package=pkgname, mustWork=TRUE), error=function(e) {
    dir.create(file.path(system.file(package=pkgname), "www"))
    system.file("www", package=pkgname)
  })
  options(epivizrStandalone_settings=.default_settings)
}
