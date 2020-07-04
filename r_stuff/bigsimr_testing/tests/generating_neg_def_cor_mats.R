library(tidyverse)

# Load in the data
dat0 <- readRDS(
  file = "~/Downloads/complete_processed_tcga2stat_RNASeq2_with_clinical.rds")

# Select just the BRCA genes
brca0 <- dat0 %>%
  filter(disease == "BRCA") %>%
  select(-c("patient":"tumorsize"))

brca1 <- round(brca0, 0)

# Filter down the brca data set
brca_median <- apply(brca1, 2, median)

top_percentile <- 0.85
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]

(d <- length(keep_genes))

brca2 <- brca1 %>%
  select(all_of(keep_genes))

brca_rho <- bigsimr::fastCor(brca2, method = "spearman")
rho <- bigsimr::cor2cor(brca_rho, "spearman", "pearson")
eig <- eigen(rho)

rho_nd_3076 <- rho
write.csv(rho_nd_3076, file = "~/projects/bigsimr/scratch/rho_ND_3076.csv")

top_percentile <- 0.75
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]

(d <- length(keep_genes))

brca2 <- brca1 %>%
  select(all_of(keep_genes))

brca_rho <- bigsimr::fastCor(brca2, method = "spearman")
rho <- bigsimr::cor2cor(brca_rho, "spearman", "pearson")
eig <- eigen(rho)
sum(eig$values < 0)

rho_nd_5127 <- rho
write.csv(rho_nd_5127, file = "~/projects/bigsimr/scratch/rho_ND_5127.csv")


top_percentile <- 0.95
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]

(d <- length(keep_genes))

brca2 <- brca1 %>%
  select(all_of(keep_genes))

brca_rho <- bigsimr::fastCor(brca2, method = "spearman")
rho <- bigsimr::cor2cor(brca_rho, "spearman", "pearson")
eig <- eigen(rho)
sum(eig$values < 0)

write.csv(rho, file = "~/projects/bigsimr/scratch/rho_ND_1026.csv")


top_percentile <- 0.50
cut_point <- quantile(brca_median, top_percentile)
keep_genes <- names(brca_median)[brca_median >= cut_point]

(d <- length(keep_genes))

brca2 <- brca1 %>%
  select(all_of(keep_genes))

brca_rho <- bigsimr::fastCor(brca2, method = "spearman")
rho <- bigsimr::cor2cor(brca_rho, "spearman", "pearson")
eig <- eigen(rho)
sum(eig$values < 0)

write.csv(rho, file = "~/projects/bigsimr/scratch/rho_ND_10251.csv")


