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
  path <- system.file(package = "epivizrStandalone")
  webpath <- file.path(path, 'www')
  
  server <- epivizrServer::createServer(static_site_path = webpath)
  app <- epivizr::startEpiviz(server=server, 
                              host="http://localhost", 
                              path="/index-standalone.html", 
                              http_port=server$.port, ...)
  app
}
