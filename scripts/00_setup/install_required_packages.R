# Install R packages needed by the weighting pipeline.
# Run manually when preparing a new R environment.

cran_packages <- c(
  "survey",
  "dplyr",
  "tidyr",
  "readr",
  "haven",
  "labelled",
  "readxl",
  "stringr",
  "purrr",
  "lubridate",
  "rlang",
  "janitor",
  "fs",
  "glue",
  "testthat",
  "summarytools",
  "writexl",
  "expss",
  "paws",
  "aws.signature",
  "jsonlite"
)

installed <- rownames(installed.packages())
missing <- setdiff(cran_packages, installed)

if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

if (!requireNamespace("ReGenesees", quietly = TRUE)) {
  message(
    "ReGenesees is not installed. Install it manually with: ",
    "remotes::install_github('DiegoZardetto/ReGenesees')"
  )
}
