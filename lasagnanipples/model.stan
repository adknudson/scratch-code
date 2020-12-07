functions{
  real pv(real x,
          real amplig,
          real ampliL,
          real cen_G1,
          real cen_L1,
          real sigma_g1,
          real sigma_L1,
          real m) {
    return (m*ampliL/(1+((x-cen_L1)^2)/(sigma_L1^2))) + (((1-m)*amplig)/(exp(log(2)*((x-cen_G1)^2)/(sigma_g1^2))));
  }
}
data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real amplig;
  real ampliL;
  real cen_G1;
  real cen_L1;
  real<lower=0> sigma_g1;
  real<lower=0> sigma_L1;
  real m;
  real<lower=0> std_dev;
}

transformed parameters {
  vector[N] pvmodel;
  for (i in 1:N) {
    pvmodel[i] = pv(x[i], amplig, ampliL, cen_G1, cen_L1, sigma_g1, sigma_L1, m);
  }
}
model {
  y ~ normal(pvmodel, std_dev);
  amplig ~ normal(100,  1);
  ampliL ~ cauchy(50, 1);
  cen_G1 ~ normal(50, 1);
  cen_L1 ~ cauchy(50, 1);
  sigma_g1 ~ normal(5, 1);
  sigma_L1 ~ cauchy(5, 1);
  m ~ normal(0, 1);
  std_dev ~ normal(1, 100);
}
