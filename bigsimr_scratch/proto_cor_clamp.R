library(bigsimr)

margins <- alist(
  qlnorm(meanlog = 3.42, sdlog = 0.862),
  qnorm(mean = 77.9, sd = 9.49),
  qnbinom(size = 20, prob = 0.05)
)

rho_in  <- matrix(c(1.0, 0.6, 0.7,
                    0.6, 1.0, 0.8,
                    0.7, 0.8, 1.0), 3, 3)
rho_out  <- matrix(c(1.0, 0.6, 0.9,
                     0.6, 1.0, 0.8,
                     0.9, 0.8, 1.0), 3, 3)

(rho_bounds <- cor_bounds(margins, "pearson"))

cor_clamp_inbounds <- function(rho, margins, method) {
  bounds <- cor_bounds(margins, method)

  lt <- lower.tri(rho)

  lo <- bounds$lower[lt]
  up <- bounds$upper[lt]
  r  <- rho[lt]

  list(r, lo, up)
}

ret <- cor_clamp_inbounds(rho_in, margins, "pearson")

all(ret[[2]] <= ret[[1]] & ret[[1]] <= ret[[3]])

