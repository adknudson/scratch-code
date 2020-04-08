library(reticulate)
use_condaenv("pygantic")

onp <- import("numpy", convert = FALSE)
np <- import("jax.numpy", convert = FALSE)
random <- import("jax.random", convert = FALSE)
jax <- import("jax", convert = FALSE)

d <- 200L
n <- 2000L
mu <- rep(0, d)
rho <- 0.5
Rho <- matrix(rho, d, d)
diag(Rho) <- 1.0

Rho = onp$array(Rho, dtype=onp$float32)
mu  = onp$array(mu, dtype=onp$float32)
Rho = jax$device_put(Rho)
mu  = jax$device_put(mu)
key = random$PRNGKey(0L)
x = random$multivariate_normal(key, mu, Rho, list(n))$block_until_ready()
x_cpu = jax$device_get(x)
xr <- py_to_r(x_cpu)
