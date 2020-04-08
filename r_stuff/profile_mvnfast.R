library(profvis)
library(mvnfast)
library(reticulate)
use_python("~/miniconda3/envs/pygantic/bin/python")
np <- import("numpy")

d <- 15000L
n <- 2000L
rho <- 0.5
Rho <- matrix(rho, d, d)
diag(Rho) <- 1.0
cores <- 10L

p <- profvis({
  mvn_sim <- rmvn(n = n,
                  mu = rep(0, d),
                  sigma = Rho,
                  ncores = cores,
                  isChol = FALSE)
  np$random$multivariate_normal(mean = rep(0.0, d),
                                cov = Rho,
                                size = list(n))

})


