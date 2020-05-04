library(tidyverse)
library(readxl)
library(rstan)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# Read 233 rows max because there is some non-table related data at the end
dat <- read_xlsx("~/Downloads/DataHernandezBarrios.xlsm",
                 sheet = "Data", n_max = 233)

# Fix the rownames to be easier to work with
dat <- dat %>%
  rename_all(str_replace, pattern = "-", replacement = "_") %>%
  rename_all(str_replace, pattern = "#", replacement = "")

# Create a vector of censorship indicators
# Censored means that the event value (death) was not observed
any_rows_na <- function(x) {
  c(apply(x, 1, function(r) any(is.na(r))))
}
censored <- dat %>%
  select(Surv_2:Surv_6) %>%
  any_rows_na()
dat$is_censored <- censored

# Turn NA values into 0's so we can calculate the survival time (in months)
dat <- dat %>%
  mutate_at(vars(Surv_2:Surv_6), ~ if_else(is.na(.), 0, .)) %>%
  mutate(surv_t = (Surv_2 + Surv_3 + Surv_4 + Surv_5 + Surv_6) * 6) %>%
  select(-c(Surv_2:Surv_6))

dat <- dat %>%
  select(Treatment, Sex, is_censored, surv_t) %>%
  drop_na()

#
n   <- nrow(dat)             # Number of observations
n_c <- sum(dat$is_censored)  # Number censored
n_o <- n - n_c               # Number observed
P   <- 1                     # Number of predictors (1 for intercept)
y_c <- with(dat, surv_t[is_censored])
y_o <- with(dat, surv_t[!is_censored])

data <- list(
  n   = n,
  n_c = n_c,
  n_o = n_o,
  P   = P,
  y_c = y_c,
  y_o = y_o,
  x_c = matrix(1, n_c, 1),
  x_o = matrix(1, n_o, 1)
)

model <- "data {
  int P; // number of beta parameters

  // data for censored subjects
  int n_c;
  matrix[n_c, P] x_c;
  vector[n_c] y_c;

  // data for observed subjects
  int n_o;
  matrix[n_o, P] x_o;
  real y_o[n_o];
}
parameters {
  vector[P] beta;
  real alpha; // Weibull Shape
}
transformed parameters{
  // model Weibull rate as function of covariates
  vector[n_c] lambda_c;
  vector[n_o] lambda_o;

  // standard weibull AFT re-parameterization
  lambda_c = exp((x_c*beta)*alpha);
  lambda_o = exp((x_o*beta)*alpha);
}
model {
  beta ~ normal(0, 100);
  alpha ~ exponential(1);

  // evaluate likelihood for censored and uncensored subjects
  target += weibull_lpdf(y_o | alpha, lambda_o);
  target += weibull_lccdf(y_c | alpha, lambda_c);
}
generated quantities{
  vector[1000] post_pred;
  real lambda;

  // generate hazard ratio
  lambda = exp((beta[1])*alpha);

  // generate survival times (for plotting survival curves)
  for(i in 1:1000){
    post_pred[i] = weibull_rng(alpha,  lambda);
  }
}"

weibull_fit <- stan(model_code = model,
                    model_name = "weibull_intercept_only",
                    data = data,
                    chains = 4,
                    iter = 10000,
                    warmup = 9000,
                    cores = 4,
                    verbose = FALSE)
