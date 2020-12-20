data {
  int<lower=0> N;
  vector[N] P_obs;
  real P_sd;
}
generated quantities {
  vector[N] P_obs_pred;
  vector[N] P_true;
  real mu;

  real a = normal_rng(0, 3);
  real sigma = exponential_rng(2);
  mu = a;

  for (n in 1:N) {
    P_true[n] = normal_rng(mu, sigma);
    P_obs_pred[n] = normal_rng(P_true[n], P_sd);
  }
}
