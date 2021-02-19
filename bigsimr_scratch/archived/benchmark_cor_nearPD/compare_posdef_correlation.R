library(bigsimr)
library(JuliaCall)
julia <- julia_setup("/home/alex/julia-1.5.3/bin/")
julia$library("MvSim")

n <- 2000
r <- cor_convert(cor_randPSD(n), "spearman", "pearson")
matrixcalc::is.positive.definite(r)


system.time({
  r1_ret <- Matrix::nearPD(r, corr = TRUE, doSym = FALSE, ensureSymmetry = FALSE)
  r1 <- as.matrix(r1_ret$mat)
})
system.time({
  r2 <- cor_nearPD(r)
})
system.time({
  r3 <- julia$call("MvSim.cor_nearPD", r)
})
system.time({
  r4 <- julia$call("MvSim.cor_fastPD", r)
})

list(
  "Matrix::nearPD" = norm(r - r1),
  "bigsimr::cor_nearPD" = norm(r - r2),
  "MvSim.cor_nearPD" = norm(r - r3),
  "MvSim.cor_fastPD" = norm(r - r4)
)
