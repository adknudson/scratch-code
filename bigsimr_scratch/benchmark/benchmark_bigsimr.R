args <- commandArgs(trailingOnly = TRUE)
subdir <- args[1]
condaenv <- args[2]
out <- paste0(subdir, "/", paste("benchmark", condaenv, sep = "_"), ".rds")

list(subdir, condaenv, out)

reticulate::use_condaenv(condaenv)
library(bigsimr)
library(microbenchmark)


if (!file.exists(paste0(subdir, "/benchmark_spec.rds"))) {
  source("benchmark_setup.R")
}
spec <- readRDS(paste0(subdir, "/benchmark_spec.rds"))

rvecs <- lapply(1:nrow(spec), function(i) {
  substitute(rvec(n = 10000, rho = r, margins = m, cores = s),
             list(r = spec$rho[[i]], m = spec$margins[[i]], s = spec$cores[[i]]))
})

spec$names <- with(spec, paste0("dims", dims, "_cores", cores))
names(rvecs) <- spec$names

mb <- microbenchmark(list = rvecs, times = 3)
saveRDS(mb, out)

mb
