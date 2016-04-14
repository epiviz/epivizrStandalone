.onLoad <- function(libname = find.package("epivizrStandalone"), pkgname = "epivizrStandalone") {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- paste(path, '/www')
  
  if(dir.exists(webpath)) {
    packageStartupMessage("checking for epiviz updates ...")
    repo <- git2r::repository(webpath)
    git2r::checkout(repo, "master")
  }
  else {
    packageStartupMessage("Cloning latest version of epiviz from git ...")
    git2r::clone("https://github.com/epiviz/epiviz.git", local_path=webpath)
  }
}