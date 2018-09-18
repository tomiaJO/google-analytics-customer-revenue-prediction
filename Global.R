library(magrittr)
library(data.table)
library(purrr)
library(glue)
library(ggplot2)

invisible(sapply(
  list.files(path = "functions", pattern = ".R", all.files = TRUE, full.names = TRUE), 
  source
))
