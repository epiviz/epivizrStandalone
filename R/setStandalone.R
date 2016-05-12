#' Set settings for epiviz standalone repository.
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
#' @param non_interactive (logical) don't download repo, used for testing purposes.
#' @return path to the epiviz app git repository
#' 
#' @examples
#' # argument non_interactive here to avoid downloading when testing
#' # package. Remove non_interactive argument when you try it out.
#' setStandalone(url="https://github.com/epiviz/epiviz.git", branch="master", non_interactive=TRUE)
#' 
#' @export
setStandalone <- function(url="https://github.com/epiviz/epiviz.git", branch="min", local_path=NULL, non_interactive=FALSE) {
  webpath <- system.file("www", package = "epivizrStandalone")
  if (non_interactive) {
    return(webpath)
  }
  
  unlink(webpath, recursive = TRUE)
  
  index_file <- ifelse(branch=="min", "epivizr-standalone.html", "index-standalone.html")
  params <- list(url=url, branch=branch, local_path=local_path, index_file=index_file)
  options(epivizrStandalone_settings=params)
  
  if (!is.null(local_path)) {
    cat("linking epivizrStandalone repo to local repo at ", local_path, "...\n")
    file.symlink(from=local_path, to=webpath)
  } else {
    cat("cloning epiviz from git...\n")
    repo <- git2r::clone(url, local_path=webpath)
    if (branch != "master") {
      git2r::checkout(repo, branch)    
    }
  }
  webpath
}

.check_epiviz_repo <- function(params) {
  path <- system.file("www", package="epivizrStandalone")
  
  if (!dir.exists(path)) {
    return(FALSE)
  }  
  
  if (!git2r::in_repository(path)) {
    return(FALSE)
  }
  
  if (!file.exists(file.path(path, params$index_file))) {
    return(FALSE)
  }
  
  js_file <- ifelse(params$branch=="min", file.path(path, "epiviz-min.js"), file.path(path, "src", "epiviz", "epiviz.js"))
  if (!file.exists(js_file)) {
    return(FALSE)
  }
  
  TRUE
}

.check_epiviz_update <- function() {
  webpath <- system.file("www", package = "epivizrStandalone")
  
  params <- getOption("epivizrStandalone_settings")
  
  if (is.null(params$local_path)) {
    if (!is.null(params$url) & !is.null(params$branch)){
      if (.check_epiviz_repo(params)) {
        cat("checking for updates to epiviz app...\n")
        repo <- git2r::repository(webpath)
        git2r::pull(repo)
        cat("done\n")
      } else {
        unlink(webpath, recursive=TRUE)
        cat("cloning epiviz JS app from repository...\n")
        repo <- git2r::clone("https://github.com/epiviz/epiviz.git", local_path=webpath)
        if (params$branch != "master") {
          git2r::checkout(repo, params$branch)    
        }
        cat("done\n")
      }  
    }
  }  
}

.get_standalone_index <- function() {
  params <- getOption("epivizrStandalone_settings")
  params$index_file
}