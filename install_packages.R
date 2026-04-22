# install packages needed to run the PAMS VOCs tidying app

# run the entire script below if you don't already have these packages installed
# or if you recently updated or installed RStudio

if (!require("pacman")) install.packages("pacman")
pacman::p_load("shiny", "dplyr", "lubridate", "hms", "readr", "tidyr")
