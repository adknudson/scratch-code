library(readr)
library(rstan)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

gfed_dat <- read_csv("gfed_dat.csv",
                     col_types = cols(X1 = col_integer(),
                                      doy = col_integer()))


gfed_dat$gfed_sum[2] = mean(gfed_dat$gfed_sum[-2])
gfed_log_std = log(scale(gfed_dat$gfed_sum, center = FALSE, scale = TRUE))

d <- list(
  P_obs = as.numeric(gfed_log_std),
  P_sd  = sd(gfed_log_std) / sqrt(length(gfed_log_std)),
  N     = length(gfed_log_std)
)

m <- stan_model(file = "sam_fei.stan")

mfit <- sampling(m, data = d, chains = 1, iter = 2000, warmup = 1000,
                 algorithm = "Fixed_param")

prior <- extract(mfit)

P_obs_pred <- prior$P_obs_pred
P_mu <- apply(P_obs_pred, 2, mean)
P_pi <- apply(P_obs_pred, 2, sd)

plot(gfed_dat$doy, gfed_log_std, col="blue")
points(gfed_dat$doy, P_mu, pch=23)

