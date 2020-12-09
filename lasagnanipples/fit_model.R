library(rstan)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


df <- read.csv("data.csv")
dat <- list(x = df$x, y = df$y, N = length(df$x))

m <- stan(file = "model.stan", data = dat,
          cores = 4, chains = 4,
          warmup = 2000, iter = 4500)

summ <- as.data.frame(summary(m)$summary)
summ[,c("mean", "2.5%", "97.5%"),drop=FALSE]
