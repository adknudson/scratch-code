reticulate::use_condaenv("bigsimr-gpu")
library(bigsimr)
reticulate::py_config()


# Global Parameters
cores <- c(20, 10, 1)

size <- 8
prob <- 0.5

type <- c("pearson", "spearman")
n <- c(1e4, 1e5)
d <- c(1000, 5000, 10000)

eps <- 1e-2
pars <- expand.grid(
  n     = n,
  d     = d,
  cores = cores,
  type  = type,
  stringsAsFactors = FALSE
)

# Run the sims
res <- data.frame()
for (i in 1:nrow(pars)) {
  p <- do.call(list, pars[i,])
  cat("working on step", i, "/", nrow(pars), "\n")

  margins <- rep(list(list("nbinom", size = size, prob = prob)), p$d)
  rho <- matrix(0.5, p$d, p$d)
  diag(rho) <- 1.0

  time_data <- system.time({
    x <- rvec(n = p$n,
              rho = rho,
              params = margins,
              cores = p$cores,
              type = p$type)
  })

  # Estimate statistics
  Rho_hat <- fastCor(x, method = p$type)
  Rho_diff <- Rho_hat[lower.tri(Rho_hat)] - rho[lower.tri(rho)]
  Rho_diff_var <- mean(Rho_diff^2)

  # Save the results
  res <- rbind(res, data.frame(
    method = "bigsimr",
    device = "GPU",
    type = p$type,
    cores = p$cores,
    margins = "nbinom",
    d = p$d,
    N = p$n,
    rho_mse = Rho_diff_var,
    sim_time = unname(time_data["elapsed"])
  ))
}

