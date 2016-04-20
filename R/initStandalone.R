#' Initialize settings for epiviz standalone repository.
#' 
#' The epiviz app run by function \code{\link{startStandalone}} in this package
#' is cloned as a git repository. This function intializes the settings specifying
#' which git repository is used. It can be either a github repository (the usual case), 
#' or local repository containing the epiviz JS app (used for testing and development).
#' 
#' @import git2r
#' 
#' @param url (character) github url to use. defaults to (\url{"https://github.com/epiviz/epiviz.git"}).
#' @param branch (character) branch on the github repository. defaults to (master).
#' @param local_path (character) if you already have a local instance of epiviz and would like to run standalone use this.
#' 
#' @return path to the standalone location
#' 
#' @examples
#' # see package vignete for example usage
#' \dontrun {
#' initStandalone(url="https://github.com/epiviz/epiviz.git", branch="master")
#' }
#' 
#' @export
initStandalone <- function(url="https://github.com/epiviz/epiviz.git", branch="master", local_path=NULL) {
  path <- system.file(package = "epivizrStandalone")
  webpath <- file.path(path, 'www')
  
  unlink(webpath, recursive = TRUE)
  
  params <- list(url=url, branch=branch, local_path=local_path)
  settings_file <- file.path(normalizePath("~"), epivizrStandalone:::.settings_file)
  dput(params, file=settings_file)
  
  if(!is.null(local_path)) {
    cat("linking epivizrStandalone repo to local repo at ", local_path, "...\n")
    file.symlink(from=local_path, to=webpath)
  }
  else {
    cat("cloning epiviz from git ...")
    git2r::clone(url, local_path=webpath)
    if(branch != "master") {
      git2r::checkout(repo, branch)    
    }
  }
  webpath
}
