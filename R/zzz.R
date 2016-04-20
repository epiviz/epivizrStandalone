.settings_file <- ".epivizr-standalone"
.onLoad <- function(libname = find.package("epivizrStandalone"), pkgname = "epivizrStandalone") {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- file.path(path, 'www')

  settings_file <- file.path(normalizePath("~", epivizrStandalone:::.settings_file))  
  if (file.exists(settings_file)) {
    params <- dget(file=settings_file) 
    
    if (is.null(params$local_path)) {
      if (!is.null(params$url) & !is.null(params$branch)){
        if (dir.exists(webpath)) {
          packageStartupMessage("checking for updates to epiviz app...")
          repo <- git2r::repository(webpath)
          git2r::pull(repo)
          packageStartupMessage("done")
        } else {
          packageStartupMessage("cloning epiviz JS app from repository...")
          git2r::clone("https://github.com/epiviz/epiviz.git", local_path=webpath)
          packageStartupMessage("done")
        }  
      }
    }  
  }
}