reticulate::use_condaenv("bigsimr-gpu")
library(bigsimr)
library(rlang)
library(microbenchmark)
library(ggplot2)

d <- 10000L
n <- 1e4

R <- matrix(0.5, d, d)
diag(R) <- 1.0
shapes <- sample(5:25, size = d, replace = TRUE)
rates  <- runif(d, 1, 5)

margins <- sapply(1:d, function(i) {
  q <- expr(qgamma(shape = shapes[i], rate = rates[i]))
  q[[2]] <- eval(q[[2]])
  q[[3]] <- eval(q[[3]])
  q
})

sim_and_calc <- function(n, d, R, m) {
  rvec(n, R[1:d, 1:d], m[1:d], "pearson", FALSE)
}

x <- sim_and_calc(n, 5000, R, margins)
Rhat <- cor_fast(x, method = "pearson")
RHat <- cor(x)

anyNA(Rhat)
anyNA(RHat)

mbm_gpu <- microbenchmark(
  d10n1e4 = sim_and_calc(n, 10, R, margins),
  d100n1e4 = sim_and_calc(n, 100, R, margins),
  d1000n1e4 = sim_and_calc(n, 1000, R, margins),
  d5000n1e4 = sim_and_calc(n, 5000, R, margins),
  # d10000n1e4 = sim_and_calc(n, 10000, R, margins),
  times = 10
)

autoplot(mbm_gpu) +
  labs(title = "Benchmark of bigsimr",
       subtitle = "develop branch - GPU")
