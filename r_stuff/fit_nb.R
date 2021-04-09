library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

N <- 1000
size <- 2
prob <- 2e-6
y <- rnbinom(N, size, prob)
dat <- list(y = y, N = length(y), y_mu = mean(y), y_sd = sd(y))

f <- stan(file = "fit_nb.stan", data = dat,
          chains = 1, warmup = 1000, iter = 2000)
smp <- extract(f)
mean(smp$prob)
mean(smp$rate)

hist(smp$prob, breaks = 50)
hist(smp$rate, breaks = 50)
