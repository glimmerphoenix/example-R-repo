library(here)
library(log4r)

library(dplyr)
library(caret)
library(partykit)
library(rpart)
library(rpart.plot)

# Set up simple logger
# Configure the logger at DEBUG level
log_file = here("src", "log-simple-analysis.log")
logger <- logger("DEBUG", appenders = file_appender(log_file))


# Load clean data
load(here("data", "processed", "ACMETel-clean.RData"))
info(logger, "Clean data successfully loaded.")

ACME_subset <- ACMETelephoneABT %>% 
  select(avgOverBundleMins, lastMonthCustomerCareCalls, avgrecurringCharge,
         peakOffPeakRatio, billAmountChangePct, smartPhone, churn)
info(logger, "Subset variables included in models: OK.")

# Data split training/testing sets
inTraining <- createDataPartition(pull(ACME_subset, churn),
                                  p = .7, list = FALSE, times = 1)
acme_training <- slice(ACME_subset, inTraining)
acme_testing <- slice(ACME_subset, -inTraining)
info(logger, "Training/testing split: OK.")

# Generate extra variable
acme_training <- acme_training %>%
  mutate(binary_billAmountChangePct = ifelse(billAmountChangePct > 0, "positive","negative"))
acme_training$binary_billAmountChangePct = as.factor(acme_training$binary_billAmountChangePct)
info(logger, "Generate extra binary var. for billAmountChangePct: OK.")

info(logger, "Starting ctree model...")
# Decision tree
ctree_acme = ctree(churn ~ avgOverBundleMins +
                     lastMonthCustomerCareCalls +
                     avgrecurringCharge + peakOffPeakRatio +
                     binary_billAmountChangePct + smartPhone,
                   data=acme_training)

# Save model on disk
saveRDS(ctree_acme, here("output", "models", "ctree_acme.rds"))
info(logger, "ctree model saved on disk: OK.")

sink(here("src", "summary_ctree_acme.out"))
print(ctree_acme)
sink()

# Generate plot, save on disk
pdf(file = here("output", "figs", "ctree_plot.pdf"))
plot(ctree_acme, gp = gpar(fontsize = 10),
     inner_panel=node_inner,
     ip_args=list(
       abbreviate = TRUE, 
       id = FALSE)
)
dev.off()
info(logger, "Generated fig for ctree_acme: OK.")

# Second decision tree, now with rpart
rpart_acme = rpart(churn ~ avgOverBundleMins +
                     lastMonthCustomerCareCalls +
                     avgrecurringCharge + peakOffPeakRatio +
                     binary_billAmountChangePct + smartPhone,
                   data=acme_training, model=TRUE)

saveRDS(rpart_acme, here("output", "models", "rpart_acme.rds"))
info(logger, "rpart model saved on disk: OK.")

sink(here("src", "summary_rpart_acme.out"))
summary(rpart_acme)
sink()

# Generate plot, save on disk
pdf(file = here("output", "figs", "rpart_plot.pdf"))
rpart.plot(rpart_acme)
dev.off()

info(logger, "Generated fig for rpart_acme: OK.")

