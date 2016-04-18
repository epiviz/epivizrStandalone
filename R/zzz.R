.onLoad <- function(libname = find.package("epivizrStandalone"), pkgname = "epivizrStandalone") {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- paste(path, '/www')
  
  packageStartupMessage("checking for repo updates")
  
  if(dir.exists(webpath)) {
    packageStartupMessage("checking for epiviz updates ...")
    repo <- git2r::repository(webpath)
    git2r::pull(repo)
  }
  else {
    packageStartupMessage("Cloning  epiviz from git ...")
    git2r::clone("https://github.com/epiviz/epiviz.git", local_path=webpath)
  }
}