reticulate::use_condaenv("bigsimr-gpu")
devtools::load_all()

mom_nbinom <- function(x) {
  m <- mean(x)
  s <- sd(x)
  list(size = m^2 / (s^2 - m), prob = m / s^2)
}

size <- 8
prob <- 0.5
margins <- list(
  list("nbinom", size = size, prob = prob),
  list("nbinom", size = size, prob = prob)
)

type <- c("pearson", "spearman", "kendall")
cores <- c(1, 2)
n <- c(1e3, 1e4, 1e5)
adjustForDiscrete <- c(FALSE)

eps <- 1e-2
grid_steps <- 100
sim_pars <- expand.grid(type = type, cores = cores, n = n,
                        stringsAsFactors = FALSE,
                        adjustForDiscrete = adjustForDiscrete)
sim_pars

file.remove("sims_nb")
dir.create("sims_nb", showWarnings = FALSE)

res2 <- data.frame()
for (i in 1:nrow(sim_pars)) {

  type <- sim_pars$type[i]
  cores <- sim_pars$cores[i]
  n <- sim_pars$n[i]
  adjustForDiscrete <- sim_pars$adjustForDiscrete[i]

  tmp_bounds <- computeCorBounds(margins, type = type)
  cor_lo <- tmp_bounds$lower[1,2] + eps
  cor_hi <- tmp_bounds$upper[1,2] - eps
  cor_seq <- seq(cor_lo, cor_hi, length.out = grid_steps)

  for (rho in cor_seq) {
    Rho <- matrix(rho, 2, 2)
    diag(Rho) <- 1.0

    time_data <- system.time({
      x <- rvec(n = n,
                rho = Rho,
                params = margins,
                cores = cores,
                type = type,
                adjustForDiscrete = adjustForDiscrete)
    })

    # Save the sims in case
    id <- paste0(
      "d", 2,
      "-N", n,
      "-c", cores,
      "-r", rho,
      "-Cor", type,
      "-adj", as.character(adjustForDiscrete),
      "-dev", "GPU",
      "-lib", "bigsimr"
    )
    saveRDS(x, file = paste0("sims_nb/", id, ".rds"))

    # Estimate statistics
    Rho_hat <- fastCor(x, method = type)
    rho_hat <- Rho_hat[1, 2]
    nbinom_args_hat <- mom_nbinom(x[,1])
    size_hat        <- nbinom_args_hat$size
    prob_hat        <- nbinom_args_hat$prob

    # Save the results
    res2 <- rbind(res2, data.frame(
      method = "bigsimr",
      device = "GPU",
      type = type,
      cores = cores,
      margins = "nbinom",
      adjustForDiscrete = adjustForDiscrete,
      d = 2,
      N = n,
      rho = rho,
      rho_hat = rho_hat,
      size = size,
      prob = prob,
      size_hat = size_hat,
      prob_hat = prob_hat,
      sim_time = unname(time_data["elapsed"])
    ))
  }
}

str(res2)

saveRDS(res2, "tests/sim_nbinom.rds")
