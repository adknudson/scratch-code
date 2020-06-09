library(tidyverse)
library(bigsimr)

mom_nbinom <- function(x) {
  m <- mean(x)
  s <- sd(x)
  list("nbinom", size = m^2 / (s^2 - m), prob = m / s^2)
}

reticulate::py_config()

# Load in the data
dat0 <- readRDS(
  file = "~/Downloads/complete_processed_tcga2stat_RNASeq2_with_clinical.rds")

# Select just the BRCA genes
brca0 <- dat0 %>%
  filter(disease == "BRCA") %>%
  select(-c("patient":"tumorsize"))

brca1 <- round(brca0, 0)

cores <- c(20, 1)
type <- c("pearson", "spearman")
n <- nrow(brca0)
top_percentile <- c(0.99, 0.95, 0.90, 0.85, 0.80, 0.75)

sim_pars <- expand.grid(n = n,
                        q = top_percentile,
                        cores = cores, 
                        type = type,
                        stringsAsFactors = FALSE)
                        
unlink("sims_brca_cpu", recursive = TRUE)
dir.create("sims_brca_cpu", showWarnings = FALSE)

brca_median <- apply(brca1, 2, median)

res <- data.frame()
for (i in 1:nrow(sim_pars)) {
  type  <- sim_pars$type[i]
  cores <- sim_pars$cores[i]
  n     <- sim_pars$n[i]
  q     <- sim_pars$q[i]
  
  # Subset the BRCA data to the cutpoint
  cut_point <- quantile(brca_median, q)
  keep_genes <- names(brca_median)[brca_median >= cut_point]
  (d <- length(keep_genes))
  
  brca_tmp <- brca1 %>%
    select(keep_genes)
  
  brca_rho     <- fastCor(brca_tmp, method = type)
  brca_margins <- apply(brca_tmp, 2, mom_nbinom)
  
  # Simulate new data
  time_data <- system.time({
    x <- rvec(
      n = n,
      rho = brca_rho,
      params = brca_margins,
      cores = cores,
      type = type
    )
  })
  
  Rho_hat     <- fastCor(x, method = type)
  margins_hat <- apply(x, 2, mom_nbinom)
  
  # Save the sims in case
  id <- paste0(
    "d", d,
    "-N", n,
    "-c", cores,
    "-Cor", type,
    "-dev", "CPU",
    "-lib", "bigsimr"
  )
  saveRDS(x, file = paste0("sims_brca_cpu/", id, ".rds"))
  
  # Save the results
    res <- rbind(res, data.frame(
      method = "bigsimr",
      device = "CPU",
      type = type,
      cores = cores,
      margins = "nbinom",
      d = d,
      N = n,
      sim_time = unname(time_data["elapsed"])
    ))
}

saveRDS(res, "sim_brca_cpu.rds")
