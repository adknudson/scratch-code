library(argparser)
library(tidyverse)
library(BayesPsychometric)

f <- function(x, a, b) {
  1 / (1 + exp(-(a + b*x)))
}

myFitFunc <- function(reps, fixed_params) {
  x <- rep(seq(-500, 500, 50), reps)
  N <- length(x)
  if (fixed_params) {
    alpha <- -1.5
    beta <- 25
  } else {
    alpha <- rnorm(N, -1.5, 2.5)
    beta <- rgamma(N, 2.5, 0.1)
  }
  theta <- alpha + beta * x / 1000
  logistic_theta <- 1 / (1 + exp(-theta))
  y <- rbinom(N, 1, logistic_theta)
  fake_df <- tibble(
    y = y,
    x = x/1000
  )
  fit <- bayesPF(y ~ x, fake_df, "logit",
                 chains = 4, cores = 4)
  list(post = rstan::extract(fit$stanfit), data = fake_df)
}

p <- arg_parser("Run a simple simulation",
                name = "Simple Sim")

p <- add_argument(p,
                  arg = "--reps",
                  help = "The number of reps in a binomial parameter",
                  default = 3,
                  type = "integer",
                  nargs = 1)
p <- add_argument(p,
                  arg = "--fixed",
                  help = "Should the parameters be assumed fixed (1) or random (0)",
                  default = 1,
                  type = "integer",
                  nargs = 1)

argv <- parse_args(p)


cat(argv$reps, as.logical(argv$fixed), "\n", sep = "\n")

fit <- myFitFunc(argv$reps, as.logical(argv$fixed))

dir.create("tmp")
name <- paste0("fit--reps", argv$reps, "--fixed", argv$fixed)
saveRDS(fit, file = paste0("tmp/", name, ".rds"))

