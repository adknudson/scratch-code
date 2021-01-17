reticulate::use_condaenv("bigsimr-cpu")
devtools::load_all()
library(mvnfast)
library(microbenchmark)

n   <- 10000
d   <- 2000
rho <- cor_randPSD(d)
mu  <- rep(0, d)

microbenchmark(
  rmvn(n, mu, rho),
  rmvn(n, mu, rho, 12),
  rmvn(n, mu, rho, 24),
  jax_rmvn(n, mu, rho),
  times = 5
)
