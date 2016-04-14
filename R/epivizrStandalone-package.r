#' epivizrStandalone.
#'
#' @name epivizrStandalone
#' @docType package
#' @import git2r

getStandaloneLocation <- function() {
  
  path <- system.file(package = "epivizrStandalone")
  webpath <- paste(path, '/www')
  
  repo <- git2r::repository(webpath)
  repo
}