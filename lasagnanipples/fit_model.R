library(rstan)

N <- 100
x <- seq(1, 100, length.out = N)
y <-
dat <- list(N=N, x=x, y=y)

m <- stan(file = "scratch-code/lasagnanipples/model.stan",
          algorithm = "Fixed_param")
