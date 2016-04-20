context("start epiviz standalone")

test_that("startStandalone creates a proper object", {
  app <- startStandalone(non_interactive=TRUE)
  expect_is(app, "EpivizApp")
  
  expect_is(app$server, "EpivizServer")
  expect_is(app$chart_mgr, "EpivizChartMgr")
  expect_is(app$data_mgr, "EpivizDataMgr")
  
  expect_true(app$server$is_closed())
})
