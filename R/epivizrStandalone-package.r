#' Initialize Epiviz Standalone to either a local epiviz repository or clones from github.
#' @import git2r
#' @import epivizr
#' @param url (character) github url to use. defaults to (\url{"https://github.com/epiviz/epiviz.git"}).
#' @param branch (character) branch on the github repository. defaults to (master).
#' @param local_path (character) if you already have a local instance of epiviz and would like to run standalone use this.
#' 
#' @return path to the standalone location
#' 
#' @examples
#' see package vignete for example usage
#' initStandalone(url="https://github.com/epiviz/epiviz.git", branch="master")
#' 
#' @export


initStandalone <- function(url="https://github.com/epiviz/epiviz.git", branch="master", local_path=NULL) {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- file.path(path, 'www')
  
  unlink(webpath, recursive = TRUE)
  
  params <- list(url=url, branch=branch, local_path=local_path)
  dput(params, file=file.path(normalizePath('~'), ".txt"))
  
  if(!is.null(local_path)) {
    print("linking epiviz to local path ...")
    file.symlink(from=local_path, to=webpath)
  }
  else {
    print("Cloning epiviz from git ...")
    git2r::clone(url, local_path=webpath)
    if(branch != "master") {
      git2r::checkout(repo, branch)    
    }
  }
  
  webpath
}

#' Uses the local instance of epiviz to start a stanadalone epivizr session 
#' 
#'  
#' @return An object of class \code{\link{EpivizApp}}
#' 
#' @examples
#' see package vignete for example usage
#' app <- startStandalone()
#' app$stop_app()
#' 
#' @export


startStandalone <- function() {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- file.path(path, 'www')
  
  server <- epivizrServer::createServer(static_site_path = webpath)
  app <- epivizr::startEpiviz(server=server, host="http://localhost", path="/index-standalone.html", http_port=server$.port)
}
