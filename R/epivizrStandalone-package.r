#' epivizrStandalone.
#'
#' @name epivizrStandalone
#' @docType package
#' @import git2r
#' @export

getStandaloneLocation <- function() {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- paste(path, '/www')
  
  repo <- git2r::repository(webpath)
  repo
}

#' @export
epivizrStandalone <- function(url="https://github.com/epiviz/epiviz.git", branch="master") {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- paste(path, '/www')
  
  unlink(webpath, recursive = TRUE)
  
  packageStartupMessage("Cloning epiviz from git ...")
  git2r::clone(url, local_path=webpath)
  git2r::checkout(repo, branch)
  
}