context("start epiviz standalone")

test_that("startStandalone creates a proper object", {
  seqinfo <- GenomeInfoDb::Seqinfo(c("chr1", "chr2"), c(10,20))
  app <- startStandalone(seqinfo=seqinfo, non_interactive=TRUE)
  expect_is(app, "EpivizApp")
  
  expect_is(app$server, "EpivizServer")
  expect_is(app$chart_mgr, "EpivizChartMgr")
  expect_is(app$data_mgr, "EpivizDataMgr")
  
  expect_true(app$server$is_closed())
})

test_that("startStandalone works with seqinfo", {
  skip_on_cran()
  skip_if_not_installed("Mus.musculus")
  
  library(Mus.musculus)
  
  seqinfo <- seqinfo(Mus.musculus)
  seqlevels <- paste0("chr", c(1:19,"X","Y", "M"))
  
  app <- startStandalone(seqinfo=seqinfo, keep_seqlevels=seqlevels, non_interactive=TRUE)
  expect_is(app, "EpivizApp")
  
  expect_is(app$server, "EpivizServer")
  expect_is(app$chart_mgr, "EpivizChartMgr")
  expect_is(app$data_mgr, "EpivizDataMgr")
  
  expect_true(app$server$is_closed())
})

test_that("startStandalone works with OrganismDb object", {
  skip_on_cran()
  skip_if_not_installed("Mus.musculus")
  require(Mus.musculus)
  
  seqlevels <- paste0("chr", c(1:19,"X","Y", "M"))
  
  app <- startStandalone(gene_track=Mus.musculus, keep_seqlevels=seqlevels, non_interactive=TRUE)
  expect_is(app, "EpivizApp")
  
  expect_is(app$server, "EpivizServer")
  expect_is(app$chart_mgr, "EpivizChartMgr")
  expect_is(app$data_mgr, "EpivizDataMgr")
  
  expect_true(app$server$is_closed())
})

test_that("startStandalone works with TxDb object", {
  skip_on_cran()
  skip_if_not_installed("TxDb.Mmusculus.UCSC.mm10.knownGene")
  require(TxDb.Mmusculus.UCSC.mm10.knownGene)

  seqlevels <- paste0("chr", c(1:19,"X","Y", "M"))
  
  app <- startStandalone(gene_track=TxDb.Mmusculus.UCSC.mm10.knownGene, keep_seqlevels=seqlevels, non_interactive=TRUE)
  expect_is(app, "EpivizApp")
  
  expect_is(app$server, "EpivizServer")
  expect_is(app$chart_mgr, "EpivizChartMgr")
  expect_is(app$data_mgr, "EpivizDataMgr")
  
  expect_true(app$server$is_closed())
})

