functions{
  real G(real x, real c, real s) {
    return 2^(-(2*(x-c)/s)^2); // gauss
  }
  real L(real x, real c, real s) {
    return 1 / (1 + (2*(x - c) / s)^2); //lorentz
  }
  real normal_lb_rng(real mu, real sigma, real lb) {
    real p = normal_cdf(lb, mu, sigma);  // cdf for bounds
    real u = uniform_rng(p, 1);
    return (sigma * inv_Phi(u)) + mu;  // inverse cdf for ppc check
}
}
data {
  int<lower=1> N;
  vector[N] x;
  vector<lower=0>[N] y;
}
parameters {                  //parameters for each peak respectively
  real<lower=0, upper=1> m1;
  real<lower=0, upper=1> m2;
  real<lower=0, upper=1> m3;
  real<lower=0, upper=1> m4;
  
  real<lower=0>S0;

  real<lower=0> A1;       // peak 1-4 respectively
  real<lower=284, upper=291> C1;
  real<lower=0> S1;    
  
  real<lower=0>A2;
  real<lower=C1, upper=291> C2;
  real<lower=0> S2;     

  real<lower=0> A3;
  real<lower=C2, upper=291> C3;
  real<lower=0> S3;
  
  real<lower=0> A4;
  real<lower=C3, upper=291> C4;
  real<lower=0> S4;

  real<lower=0> sigma;
  real<lower=0>r;
}

model {
  vector[N] mu;
  
  //priors as below, note: can be changed to reflect data if needed
  m1 ~ beta(2, 8);
  m2 ~ beta(2, 8);
  m3 ~ beta(2, 8);
  m4 ~ beta(2, 8);
  
  r ~ lognormal(log(0.5), 0.08);

  S0 ~ normal(1, 1); 
  
  A1 ~ normal(0, 10e3);
  C1 ~ normal(285, 0.2);
  S1 ~ normal(S0, 0.2);
  
  A2 ~ normal(r*A1, 10e3);
  C2 ~ normal(285.7, 0.1); // needs to be more informative
  S2 ~ normal(S0, 0.2);
       
  A3 ~ normal(0, 10e3);
  C3 ~ normal(286.81, 0.2);
  S3 ~ normal(S0, 0.2); 

  A4 ~ normal(0, 10e3);
  C4 ~ normal(288.91, 0.2);
  S4 ~ normal(S0, 0.2);

  sigma ~ exponential(1);  // diffuse prior 

  for (n in 1:N) {
    mu[n] = (m1 * A1 * L(x[n], C1, S1) + (1 - m1) * A1 * G(x[n], C1, S1)) + 
            (m2 * A2 * L(x[n], C2, S2) + (1 - m2) * A2 * G(x[n], C2, S2)) + 
            (m3 * A3 * L(x[n], C3, S3) + (1 - m3) * A3 * G(x[n], C3, S3)) + 
            (m4 * A4 * L(x[n], C4, S4) + (1 - m4) * A4 * G(x[n], C4, S4));

    
     y[n] ~ normal(mu[n], sigma); T[0, ]
    
}
generated quantities {
    vector[N] log_lik;   //log_likelihood
    vector[N] y_rep;      //posterior predictive check
    vector[N] mu;
    for (n in 1:N) {
    mu[n] = (m1 * A1 * L(x[n], C1, S1) + (1 - m1) * A1 * G(x[n], C1, S1))  + (m2 * A2 * L(x[n], C2, S2) + (1 - m2) * A2 * G(x[n], C2, S2)) + (m3 * A3 * L(x[n], C3, S3) + (1 - m3) * A3 * G(x[n], C3, S3)) + (m4 * A4 * L(x[n], C4, S4) + (1 - m4) * A4 * G(x[n], C4, S4));
  }
    for (i in 1:N) {
        log_lik[i] = normal_lpdf(y[i] | mu[i], sigma);
        y_rep[i] = normal_lb_rng(mu[i], sigma, 0);
       }
}