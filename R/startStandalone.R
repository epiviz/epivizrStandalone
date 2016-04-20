.check_is_epiviz_repo <- function(path) {
  if (!dir.exists(path)) {
    return(FALSE)
  }  
  
  if (!git2r::in_repository(path)) {
    return(FALSE)
  }
  
  if (!file.exists(file.path(path, "index-standalone.html"))) {
    return(FALSE)
  }
  
  if (!file.exists(file.path(path, "src", "epiviz", "epiviz.js"))) {
    return(FALSE)
  }
  
  TRUE
}

.check_epiviz_update <- function() {
  webpath <- system.file("www", package = "epivizrStandalone")
  
  if (file.exists(epivizrStandalone:::.settings_file)) {
    params <- dget(file=epivizrStandalone:::.settings_file) 
    
    if (is.null(params$local_path)) {
      if (!is.null(params$url) & !is.null(params$branch)){
        if (.check_is_epiviz_repo(webpath)) {
          cat("checking for updates to epiviz app...\n")
          repo <- git2r::repository(webpath)
          git2r::pull(repo)
          packageStartupMessage("done")
        } else {
          unlink(webpath, recursive=TRUE)
          cat("cloning epiviz JS app from repository...\n")
          git2r::clone("https://github.com/epiviz/epiviz.git", local_path=webpath)
          cat("done\n")
        }  
      }
    }  
  }
}

#' Start a standalone \code{epivizr} session.
#' 
#' Uses the local repository of epiviz JS app to start a standalone epivizr session
#' through the \code{\link[epivizr]{startEpiviz}} function.
#' 
#' @param ... additional arguments passed to \code{\link[epivizr]{startEpiviz}}.
#'  
#' @return An object of class \code{\link[epivizr]{EpivizApp}}
#' 
#' @examples
#' # see package vignete for example usage
#' app <- startStandalone(non_interactive=TRUE, open_browser=TRUE)
#' app$stop_app()
#' 
#' @export
startStandalone <- function(...) {
  .check_epiviz_update()
  webpath <- system.file("www", package = "epivizrStandalone")
  
  server <- epivizrServer::createServer(static_site_path = webpath, ...)
  app <- epivizr::startEpiviz(server=server, 
                              host="http://localhost", 
                              path="/index-standalone.html", 
                              http_port=server$.port, ...)
  app
}
