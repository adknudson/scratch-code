library(readr)
library(rethinking)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

gfed_dat <- read_csv("~/Downloads/gfed_dat.csv",
                     col_types = cols(X1 = col_integer(),
                                      doy = col_integer()))


gfed_dat$gfed_sum[2] = mean(gfed_dat$gfed_sum[-2])
gfed_log_std = log(scale(gfed_dat$gfed_sum, center = FALSE, scale = TRUE))
a

d = list(
  P_obs = gfed_log_std,
  P_sd  = sd(gfed_log_std) / sqrt(length(gfed_log_std)),
  N     = length(gfed_log_std)
)

m <- ulam(alist(
  P_obs ~ normal(P_true, P_sd),
  vector[N]:P_true ~ normal(mu, sigma),
  mu <- a,
  a ~ normal(0, 1.5),
  sigma ~ exponential(1)
), data = d,
chains = 4, cores = 4,
iter = 10000, warmup = 5000)

precis(m, depth = 2)
post <- extract.samples(m)


plot(gfed_dat$doy, P_obs, col="red",
     xlab = "Day of Year", ylab = "Log-Scaled-GFED")
points(gfed_dat$doy, P_mu)
abline(h = mean(P_obs), lty = "dashed")
legend(x = "bottomright", legend = c("Obs", "Est"),
       col = c("red", "black"),
       pch = 15)
