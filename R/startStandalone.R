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
  
  if (file.exists(.settings_file)) {
    params <- dget(file=.settings_file) 
    
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
#' through the \code{\link[epivizr]{startEpiviz}} function. The epiviz app requires a list
#' of sequence names and lengths (e.g., chromsome names and lengths) to setup genome browsing. 
#' These can be passed in the \code{seqinfo} argument or derived from the \code{gene_track} argument.
#' The \code{gene_track} argument can be used to pass a genome annotation and add a gene track to the 
#' epiviz browser. See package vignette for further detail.
#' 
#' @param gene_track (OrganismDb) an object of type \code{\link[OrganismDbi]{OrganismDb}} or \code{\link[GenomicFeatures]{TxDb}} 
#' @param seqinfo (Seqinfo) an object of type \code{\link[GenomeInfoDb]{Seqinfo}} from which sequence names and lengths are obtained
#' @param keep_seqlevels (character) vector of sequence names to include in the standalone app
#' @param chr (character) chromosome to browse to on app startup.
#' @param start (integer) start location to browse to on app startup.
#' @param end (integer) end location to browse to on app startup.
#' @param non_interactive (logical) run server in non-interactive mode. Used for testing and development.
#' @param ... additional arguments passed to \code{\link[epivizr]{startEpiviz}}.
#'  
#' @return An object of class \code{\link[epivizr]{EpivizApp}}
#' 
#' @examples
#' # see package vignete for example usage
#' seqinfo <- GenomeInfoDb::Seqinfo(c("chr1","chr2"), c(10,20))
#' app <- startStandalone(seqinfo=seqinfo, non_interactive=TRUE)
#' app$stop_app()
#' 
#' @import epivizr
#' @import epivizrServer
#' @import GenomeInfoDb
#' @export
startStandalone <- function(gene_track=NULL, seqinfo=NULL, keep_seqlevels=NULL,  
                            chr=NULL, start=NULL, end=NULL,
                            non_interactive=FALSE, ...) {
  if (is.null(gene_track) && is.null(seqinfo)) {
    stop("Error starting standalone, one of 'gene_track' and 'seqinfo' must be non-null")
  }
  
  if (!is.null(gene_track) && !(is(gene_track, "OrganismDb") || is(gene_track, "TxDb"))) {
    stop("Error starting standalone, gene_track must be of type 'OrganismDb' or 'TxDb'")
  }
  
  if (!is.null(seqinfo) && !is(seqinfo, "Seqinfo")) {
    stop("Error starting standalone, seqinfo must be of type 'Seqinfo'")
  }
  
  if (!non_interactive) {
    .check_epiviz_update() 
  }
  webpath <- system.file("www", package = "epivizrStandalone")
  
  server <- epivizrServer::createServer(static_site_path = webpath, non_interactive=non_interactive, ...)
  app <- epivizr::startEpiviz(server=server, 
                              host="http://localhost", 
                              path="/index-standalone.html", 
                              http_port=server$.port,
                              open_browser=FALSE,
                              use_cookie=FALSE, 
                              chr=NULL,
                              start=NULL,
                              end=NULL, ...)

  send_request <- app$server$is_interactive()
  # add chromosome names and lengths to epiviz app
  if (!is.null(gene_track)) {
    seqinfo <- seqinfo(gene_track)
  }
  app$data_mgr$add_seqinfo(seqinfo, keep_seqlevels=keep_seqlevels, send_request=send_request)
  
  # now load the app
  if (send_request) {
    app$.open_browser()
  }
  
  app$server$wait_to_clear_requests()
  
  tryCatch({
    app$server$wait_to_clear_requests()
    
    # navigate to given starting position
    # or derive from seqinfo
    if (is.null(chr)) {
      chr <- seqnames(seqinfo)[1]
    }
    
    if (is.null(start) || is.null(end)) {
      start <- unname(round(seqlengths(seqinfo)[chr] * .6))
      end <- unname(round(seqlengths(seqinfo)[chr] * .7))      
    }
    
    if (app$server$is_interactive()) {
      app$navigate(chr, start, end) 
    }
    
    # add gene track
    if (!is.null(gene_track)) {
      genome_name <- unname(genome(seqinfo)[1])
      ms_obj <- app$data_mgr$add_measurements(gene_track, datasource_name=genome_name, send_request=send_request)
      app$server$wait_to_clear_requests()
      
      if (send_request && !app$data_mgr$is_ms_connected(ms_obj)) {
        stop("Error adding gene track data")
      }
      app$chart_mgr$plot(ms_obj)
    }
  }, error=function(e) {
    app$stop_app()
    stop(e)
  })
  app
}
