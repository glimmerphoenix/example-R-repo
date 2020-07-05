# Data reading and cleaning
# Strings as factors
library(readr)
library(Hmisc)
library(dplyr)
library(here)

ACMETelephoneABT <- read_csv(here("data","raw", "ACMETelephoneABT.csv"),
                             na = c("", " "))

# Fix NAs, unify values in regionType field
ACMETelephoneABT$regionType[which(ACMETelephoneABT$regionType == "unknown")] <- NA
ACMETelephoneABT$regionType[which(ACMETelephoneABT$regionType == "r")] <- "rural"
ACMETelephoneABT$regionType[which(ACMETelephoneABT$regionType == "s")] <- "suburban"
ACMETelephoneABT$regionType[which(ACMETelephoneABT$regionType == "t")] <- "town"
ACMETelephoneABT$regionType = factor(ACMETelephoneABT$regionType, levels = c("rural", "suburban", "town"))

# Fix NAs in marriageStatus
ACMETelephoneABT$marriageStatus[which(ACMETelephoneABT$marriageStatus == "unknown")] <- NA
ACMETelephoneABT$marriageStatus = factor(ACMETelephoneABT$marriageStatus, levels = c("yes", "no"))

# Fix NAs, unify values in creditCard
ACMETelephoneABT$creditCard[which(ACMETelephoneABT$creditCard == "f")] <- "false"
ACMETelephoneABT$creditCard[which(ACMETelephoneABT$creditCard == "no")] <- "false"
ACMETelephoneABT$creditCard[which(ACMETelephoneABT$creditCard == "t")] <- "true"
ACMETelephoneABT$creditCard[which(ACMETelephoneABT$creditCard == "yes")] <- "true"
ACMETelephoneABT$creditCard = factor(ACMETelephoneABT$creditCard, levels = c("true", "false"))

# Assign NAs to cases with age = 0
ACMETelephoneABT$age[which(ACMETelephoneABT$age == 0)] <- NA

# Assume cases with income = 0 as NAs
ACMETelephoneABT$income[which(ACMETelephoneABT$income == 0)] <- NA

# Check level for all categorical columns
levels(ACMETelephoneABT$creditCard)
levels(ACMETelephoneABT$regionType)
levels(ACMETelephoneABT$marriageStatus)

# Recode output variable
ACMETelephoneABT$churn = ifelse(ACMETelephoneABT$churn, 1, 0)
ACMETelephoneABT$churn = factor(ACMETelephoneABT$churn, levels = c(1,0))

# Check data summary and levels of output var
summary(ACMETelephoneABT$churn)
levels(ACMETelephoneABT$churn)

ACMETelephoneABT$smartPhone = as.factor(ACMETelephoneABT$smartPhone)


save(ACMETelephoneABT, file = here("data", "processed", "ACMETel-clean.RData"))