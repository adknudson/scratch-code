reticulate::use_condaenv("bigsimr-cpu")

devtools::load_all()
# library(bigsimr)
library(microbenchmark)

n <- 1000
d <- 2000

sizes <- runif(d, 3, 20)
probs <- runif(d, 0.3, 0.7)
margins <- lapply(1:d, function(i) {
  substitute(qnbinom(size = s, prob = p),
             list(s = sizes[i], p = probs[i]))
})

rho <- cor_randPSD(d, 5)

# Generate correlated uniform data
system.time({
  U <- .rmvuu(n, rho)
})

f1 <- function(d, U, margins) {
  sapply(1:d, function(i) {.u2m(U[,i], margins[[i]])})
}

f2 <- function(d, U, margins) {
  vapply(X = 1:d, FUN = function(i) {
    .u2m(U[,i], margins[[i]])
  }, FUN.VALUE = numeric(n))
}

f3 <- function(d, U, margins, cores = 24L) {
  cl <- parallel::makeCluster(spec = cores, type = "FORK")
  rv <- parallel::parSapply(cl = cl, 1:d, function(i) {
    .u2m(U[,i], margins[[i]])
  }, simplify = TRUE)
  parallel::stopCluster(cl)
  rv
}

f4 <- function(d, U, margins, cores = 24L) {
  `%dopar%` <- foreach::`%dopar%`
  cl <- parallel::makeCluster(spec = cores, type = "FORK")
  doParallel::registerDoParallel(cl)
  rv <- foreach::foreach(i = 1:d, .combine = 'cbind') %dopar% {
    .u2m(U[,i], margins[[i]])
  }
  parallel::stopCluster(cl)
  rv
}

mb <- microbenchmark(
  simple_sapply    = f1(d, U, margins),
  simple_vapply    = f2(d, U, margins),
  parallel_sapply  = f3(d, U, margins),
  times = 10
)

plot(mb)
