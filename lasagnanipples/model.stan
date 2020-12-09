functions{
  real G(real x, real c, real s) {
    return exp(-log(2) * ((x - c) / s)^2);
  }
  real L(real x, real c, real s) {
    return 1 / (1 + ((x - c) / s)^2);
  }
}
data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real<lower=0, upper=1> m;

  real Ag;
  real Cg;
  real<lower=0> Sg;

  real Al;
  real Cl;
  real<lower=0> Sl;

  real<lower=0> sigma;
}
model {
  vector[N] mu;

  m ~ beta(8, 2);

  Ag ~ normal(50, 5);
  Cg ~ normal(100, 100);
  Sg ~ exponential(0.1);

  Al ~ normal(20, 5);
  Cl ~ normal(0, 100);
  Sl ~ exponential(0.1);

  sigma ~ exponential(1);

  for (n in 1:N) {
    mu[n] = m * Al * L(x[n], Cl, Sl) + (1 - m) * Ag * G(x[n], Cg, Sg);
  }

  y ~ normal(mu, sigma);
}
