reticulate::use_condaenv("bigsimr-cpu")
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
  x <- rvec(n, R[1:d, 1:d], m[1:d], "pearson", FALSE, 12L)
}

mbm_cpu <- microbenchmark(
  d10n1e4 = sim_and_calc(n, 10, R, m),
  d100n1e4 = sim_and_calc(n, 100, R, m),
  d1000n1e4 = sim_and_calc(n, 1000, R, m),
  d5000n1e4 = sim_and_calc(n, 5000, R, m),
  # d10000n1e4 = sim_and_calc(n, 10000, R, m),
  times = 10
)

autoplot(mbm_cpu) +
  labs(title = "Benchmark of bigsimr",
       subtitle = "develop branch - 12 cores")
