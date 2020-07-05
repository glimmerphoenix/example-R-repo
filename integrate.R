# Run the R scripts in the correct order
library(here)

# Data cleaning
source(here("src", "data-cleaning.R"))

# Simple analysis
source(here("src", "simple-analysis.R"))