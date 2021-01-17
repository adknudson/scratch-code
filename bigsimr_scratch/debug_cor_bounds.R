library(bigsimr)

margins <- list(
  Normal$new(mean = 70, sd = 10),
  Lognormal$new(meanlog = 3, sdlog = 1),
  Beta$new(shape1 = 5, shape2 = 3)
)

cor_bounds(margins)

# simdata <- sapply(margins, rand, n = 10)
# simsort <- apply(simdata, 2, sort)
# simrev  <- apply(simsort, 2, rev)
#
# upper <- cor(simsort)
# lower <- cor(simsort, simrev)
# diag(lower) <- 1.0
#
# list(lower = lower, upper = upper)
