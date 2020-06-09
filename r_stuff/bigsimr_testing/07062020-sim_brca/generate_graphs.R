library(tidyverse)
library(bigsimr)

# mom_nbinom <- function(x) {
#   m <- mean(x)
#   s <- sd(x)
#   list("nbinom", size = m^2 / (s^2 - m), prob = m / s^2)
# }
#
# # Load in the data
# dat0 <- readRDS(
#   file = "~/Downloads/complete_processed_tcga2stat_RNASeq2_with_clinical.rds")
#
# # Select just the BRCA genes
# brca0 <- dat0 %>%
#   filter(disease == "BRCA") %>%
#   select(-c("patient":"tumorsize"))
#
# brca1 <- round(brca0, 0)
#
# # Subset the BRCA data to the cutpoint
# brca_median <- apply(brca1, 2, median)
#
# cut_point <- quantile(brca_median, c(0.99, 0.95, 0.90, 0.85, 0.80, 0.75))
# keep_genes <- map(cut_point, ~ names(brca_median)[brca_median >= .x])
#
#
# brca_ls <- list()
# for (i in 1:length(keep_genes)) {
#   brca_ls[[i]] <- select(brca1, keep_genes[[i]])
# }
#
# brca_rho_spearman <- map(brca_ls, ~fastCor(.x, method = "spearman"))
# brca_rho_pearson  <- map(brca_ls, ~fastCor(.x, method = "pearson"))
# brca_margins <- map(brca_ls, ~ apply(.x, 2, mom_nbinom))

cpu <- readRDS("~/projects/scratch-code/r_stuff/bigsimr_testing/07062020-sim_brca/sim_brca_cpu.rds")
gpu <- readRDS("~/projects/scratch-code/r_stuff/bigsimr_testing/07062020-sim_brca/sim_brca_gpu.rds")
gpu2 <- readRDS("~/projects/scratch-code/r_stuff/bigsimr_testing/07062020-sim_brca/sim_brca_gpu2.rds")

# Timeings
sim_times <- bind_rows(cpu, gpu, gpu2) %>%
  mutate(device = factor(device),
         type = factor(type))


sim_times %>%
  unite("Device-Cores", device, cores, sep = "-", remove = FALSE) %>%
  mutate(time_min = ceiling(sim_time / 60)) %>%
  ggplot(aes(factor(d), time_min, fill = `Device-Cores`)) +
  geom_col(position = "dodge") +
  facet_wrap(~ type) +
  scale_y_continuous(breaks = c(1, 5, 10, 15, 20, 25)) +
  labs(x = "Dimensions", y = "Simulation Time (minutes)")



pc5127cpu <- readRDS("~/projects/scratch-code/r_stuff/bigsimr_testing/07062020-sim_brca/sims_brca_cpu/d5127-N1212-c20-Corpearson-devCPU-libbigsimr.rds")
sp5127cpu <- readRDS("~/projects/scratch-code/r_stuff/bigsimr_testing/07062020-sim_brca/sims_brca_cpu/d5127-N1212-c20-Corspearman-devCPU-libbigsimr.rds")
pc5127cpu_rho <- fastCor(pc5127cpu, method = "pearson")
sp5127cpu_rho <- fastCor(sp5127cpu, method = "spearman")

all.equal(pc5127cpu_rho, brca_rho_pearson[[6]])
all.equal(sp5127cpu_rho, brca_rho_spearman[[6]])
