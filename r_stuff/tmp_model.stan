data{
    // Number of observations, factor levels, etc.
    int<lower=1> N;
    int<lower=1> N_age_group;
    int<lower=1> N_trial;

    // Response Data
    int response[N];

    // Numeric Data
    vector[N] soa;

    // Factor Data
    int age_group[N];
    int trial[N];
}
transformed data{
    vector[N] soa_std;
    soa_std = (soa - mean(soa)) / sd(soa);
}
parameters{
    // Intercept terms
    real a0;
    vector[N_age_group] a_age_group;
    vector[N_trial] a_trial;

    // Slope terms
    real bsoa;
    vector[N_age_group] bsoa_age_group;
    vector[N_trial] bsoa_trial;

    // Adaptive Pooling terms
    real<lower=0> sd_a_age_group;
    real<lower=0> sd_a_trial;
    real<lower=0> sd_bsoa_age_group;
    real<lower=0> sd_bsoa_trial;
}
model{
    vector[N] theta;

    // Priors
    a0 ~ normal(0, 10);
    a_age_group ~ normal(0, sd_a_age_group);
    a_trial ~ normal(0, sd_a_trial);
    sd_a_age_group ~ cauchy(0, 2.5);
    sd_a_trial ~ cauchy(0, 2.5);
    bsoa ~ normal(0, 10);
    bsoa_age_group ~ normal(0, sd_bsoa_age_group);
    bsoa_trial ~ normal(0, sd_bsoa_trial);
    sd_bsoa_age_group ~ cauchy(0, 2.5);
    sd_bsoa_trial ~ cauchy(0, 2.5);

    // General linear model
    for (i in 1:N)
        theta[i] = a0 + a_age_group[age_group[i]] + a_trial[trial[i]] + (bsoa + bsoa_age_group[age_group[i]] + bsoa_trial[trial[i]]) * soa_std[i];

    response ~ bernoulli_logit(theta);
}
generated quantities{
    real log_lik = 0;

    for (i in 1:N) {
        real theta = a0 + a_age_group[age_group[i]] + a_trial[trial[i]] + (bsoa + bsoa_age_group[age_group[i]] + bsoa_trial[trial[i]]) * soa[i];
        log_lik += bernoulli_logit_lpmf(response[i] | theta);
    }
}
