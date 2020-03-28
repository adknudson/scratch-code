process_sims <- function(prefix, sim_name) {
  files <- list.files(path = prefix, recursive = TRUE)
  data <- data.frame()
  for (f in files) {
    new_csv <- read.csv(paste0(prefix, f), stringsAsFactors = FALSE)
    data <- rbind(data, new_csv)
  }
  data[, 1] <- sim_name
  colnames(data)[1] <- "sim_name"
  data
}

gamma_sim <- process_sims(prefix = "results/bigsimr_sim_2020-02-26/", "gamma")

nbinom_sim <- process_sims("results/bigsimr_sim_2020-03-06/", "nbinom")
nbinom_adj_sim <- process_sims(
  "results/bigsimr_sim_2020-03-06_discrete_rescale/",
  "nbinom_adjusted")


all_sims <- dplyr::bind_rows(gamma_sim, nbinom_sim, nbinom_adj_sim)
write.csv(all_sims, file = "results/all_sims.csv", na = "NA", row.names = FALSE)
saveRDS(all_sims, file = "results/all_sims.rds")
