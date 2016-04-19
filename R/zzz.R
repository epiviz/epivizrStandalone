.onLoad <- function(libname = find.package("epivizrStandalone"), pkgname = "epivizrStandalone") {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- file.path(path, 'www')
  
  if(file.exists(file.path(normalizePath('~'), ".txt"))) {
    params <- dget(file=file.path(normalizePath('~'), ".txt")) 
    
    if(is.null(params$local_path)) {
      if (!is.null(params$url) & !is.null(params$branch)){
        if(dir.exists(webpath)) {
          packageStartupMessage("checking for epiviz updates ...")
          repo <- git2r::repository(webpath)
          git2r::pull(repo)
          packageStartupMessage("Done")
        }
        else {
          packageStartupMessage("Cloning  epiviz from git ...")
          git2r::clone("https://github.com/epiviz/epiviz.git", local_path=webpath)
          packageStartupMessage("Done")
        }  
      }
    }  
  }
}