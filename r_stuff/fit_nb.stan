data {
  int<lower=0> N;
  int y[N];
  real y_mu;
  real y_sd;
}
transformed data {
  real phi_mu = y_mu^2 / (y_sd^2 - y_mu);
}
parameters {
  real<lower=machine_precision()> mu;
  real<lower=machine_precision()> phi;
}
transformed parameters {
  real prob = phi / (mu + phi);
  real rate = phi;
}
model {
  mu ~ normal(y_mu, 1000);
  phi ~ exponential(phi_mu);
  y ~ neg_binomial_2(mu, phi);
}
