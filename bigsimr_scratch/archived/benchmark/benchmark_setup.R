args <- commandArgs(trailingOnly = TRUE)
subdir <- args[1]

library(bigsimr)

make_margins <- function(d) {
  sizes <- sample(5:25, size = d, replace = TRUE)
  probs  <- runif(d, 0.3, 0.7)

  lapply(1:d, function(i) {
    substitute(qnbinom(size = s, prob = p),
               list(s = sizes[i], p = probs[i]))
  })
}


set.seed(2020-12-23)
ds <- c(2, 5, 10, 50, 100, 200, 500, 1000, 2000, 3000, 4000, 5000)
cores <- c(1L, 2L, 4L, 8L, 12L, 16L, 24L)
spec <- expand.grid(dims = ds, cores = cores)


margins <- lapply(ds, make_margins)
rho <- lapply(ds, cor_randPSD)

spec$rho <- rep(rho, length(cores))
spec$margins <- rep(margins, length(cores))

saveRDS(spec, paste0(subdir, "/benchmark_spec.rds"))
