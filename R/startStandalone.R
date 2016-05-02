
.wait_until_connected <- function(server, timeout=3L) {
  ptm <- proc.time()
  while (!server$is_socket_connected() && (proc.time() - ptm < timeout)["elapsed"]) {
    Sys.sleep(0.001)
    server$service()
  }
  if (!server$is_socket_connected()) {
    stop("[epivizrStandalone] Error starting app. UI unable to connect to websocket server.")
  }
  invisible()
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
#' @import methods
#' @import BiocGenerics
#' @import GenomicFeatures
#' @import S4Vectors
#' 
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
  
  index_file <- .get_standalone_index()
  server <- epivizrServer::createServer(static_site_path = webpath, non_interactive=non_interactive, ...)
  app <- epivizr::startEpiviz(server=server, 
                              host="http://localhost", 
                              path=paste0("/", index_file), 
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
  
  # now load the app
  if (send_request) {
    app$.open_browser()
  }

  tryCatch({
    if (app$server$is_interactive()) {
      .wait_until_connected(app$server)      
    }

    app$data_mgr$add_seqinfo(seqinfo, keep_seqlevels=keep_seqlevels, send_request=send_request)
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
