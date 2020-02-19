library(argparser)
library(mvnfast)

timestamp <- Sys.time()

default_dims  <- 2L
default_N     <- 10L
default_cores <- 1L
default_rho   <- 0.5
default_id    <- paste0("d", default_dims, "-N", default_N, "-c",
                        default_cores, "-r", default_rho)

# Set up the command line argument parser ------------------------------------
p <- arg_parser("Run a simple simulation",
                name = "Benchmark MVNFast")
p <- add_argument(p,
                  arg = "--dims",
                  help = "The number of dimensions simulated from the NB distribution.",
                  default = default_dims,
                  type = "integer",
                  nargs = 1)
p <- add_argument(p,
                  arg = "-N",
                  help = "The number of samples to simulate.",
                  default = default_N,
                  type = "integer",
                  nargs = 1)
p <- add_argument(p,
                  arg = "--cores",
                  help = "How many cores (threads) should be utilized.",
                  default = default_cores,
                  type = "integer",
                  nargs = 1)
p <- add_argument(p,
                  arg = "--rho",
                  help = "What the off-diagonal elements of the correlation matrix be set to.",
                  default = default_rho,
                  nargs = 1)
p <- add_argument(p,
                  arg = "--id",
                  help = "Give this simulation a unique identifier.",
                  default = default_id,
                  nargs = 1)
argv <- parse_args(p)

assertthat::assert_that(all(
  argv$dims > 0,
  argv$N > 0,
  argv$cores > 0
))

id    <- argv$id
d     <- argv$dims
N     <- argv$N
cores <- argv$cores
rho   <- argv$rho
mu    <- rep(0, d)
seed  <- d + N + cores + (rho * 10)
mcor  <- matrix(data = rho, nrow = d, ncol = d)
diag(mcor) <- 1.0

# Run the simulation
set.seed(seed)
time_data <- system.time({
  mvn_sim <- rmvn(N, mu = mu, mcor, ncores = cores)
})

# estimate the correlation
cor_hat <- cor(mvn_sim)

# retrieve one pairwise estimated correlation
# Note: since elements of matrices are stored in contiguous memory, cor_hat[2]
# is the same as cor_hat[2,1]
rho_hat <- cor_hat[2]

# sum of absolute error
abs_error <- sum(abs(mcor - cor_hat))

# Save the results
sim_res <- data.frame(timestamp = timestamp,
                      d = d,
                      N = N,
                      cores = cores,
                      seed = seed,
                      rho = rho,
                      rho_hat = rho_hat,
                      time = unname(time_data["elapsed"]),
                      abs_error = abs_error)

# make sure the necessary directory and file exists
if (!dir.exists("sim_results")) {
  dir.create("sim_results", showWarnings = FALSE)
}

outfile <- paste0("sim_results/benchmark_mvnfast.csv")

write.table(sim_res, outfile, append = TRUE, quote = FALSE,
            sep = ",", row.names = FALSE, col.names = FALSE)

