library(tidyverse)
library(bigsimr)

dat0 <- readRDS(
  file = "~/Downloads/complete_processed_tcga2stat_RNASeq2_with_clinical.rds")
brca0 <- dat0 %>%
  filter(disease == "BRCA") %>%
  select(-c("patient":"tumorsize"))
brca1 <- round(brca0, 0)
brca_median <- apply(brca1, 2, median)

top_percentile <- 0.95
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]
(d <- length(keep_genes))
brca2 <- brca1 %>%
  select(all_of(keep_genes))
brca_rho <- cor_fast(brca2, method = "spearman")
rho <- cor_convert(brca_rho, "spearman", "pearson")
write.table(
  rho,
  file = "~/projects/scratch-code/r_stuff/bigsimr_testing/rho_ND_1K.csv",
  sep = ",",
  row.names = FALSE,
  col.names = FALSE
)


top_percentile <- 0.85
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]
(d <- length(keep_genes))
brca2 <- brca1 %>%
  select(all_of(keep_genes))
brca_rho <- cor_fast(brca2, method = "spearman")
rho <- cor_convert(brca_rho, "spearman", "pearson")
write.table(
  rho,
  file = "~/projects/scratch-code/r_stuff/bigsimr_testing/rho_ND_3K.csv",
  sep = ",",
  row.names = FALSE,
  col.names = FALSE
)

top_percentile <- 0.75
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]
(d <- length(keep_genes))
brca2 <- brca1 %>%
  select(all_of(keep_genes))
brca_rho <- cor_fast(brca2, method = "spearman")
rho <- cor_convert(brca_rho, "spearman", "pearson")
write.table(
  rho,
  file = "~/projects/scratch-code/r_stuff/bigsimr_testing/rho_ND_5K.csv",
  sep = ",",
  row.names = FALSE,
  col.names = FALSE
)


top_percentile <- 0.50
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]
(d <- length(keep_genes))
brca2 <- brca1 %>%
  select(all_of(keep_genes))
brca_rho <- cor_fast(brca2, method = "spearman")
rho <- cor_convert(brca_rho, "spearman", "pearson")
write.table(
  rho,
  file = "~/projects/scratch-code/r_stuff/bigsimr_testing/rho_ND_10K.csv",
  sep = ",",
  row.names = FALSE,
  col.names = FALSE
)
