data{
    int N;
    real P_sd;
    vector[N] P_obs;
}
parameters{
    vector[N] P_true;
    real a;
    real<lower=0> sigma;
}
model{
    real mu;
    sigma ~ exponential( 1 );
    a ~ normal( 0 , 10 );
    mu = a;
    P_true ~ normal( mu , sigma );
    P_obs ~ normal( P_true , 1 );
}
