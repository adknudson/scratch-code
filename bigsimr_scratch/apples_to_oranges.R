reticulate::use_condaenv("bigsimr-cpu")
library(bigsimr)

make_margins <- function(d) {
  sizes <- sample(5:25, size = d, replace = TRUE)
  probs  <- runif(d, 0.3, 0.7)

  lapply(1:d, function(i) {
    substitute(qnbinom(size = s, prob = p),
               list(s = sizes[i], p = probs[i]))
  })
}

n <- 10000
d <- 1000
r <- cor_randPSD(d)
margins <- make_margins(d)

system.time( x <- rvec(n, r, margins, 8L) )
cor(x)
r
