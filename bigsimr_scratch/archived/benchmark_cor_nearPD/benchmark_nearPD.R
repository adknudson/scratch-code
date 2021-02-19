library(bigsimr)
library(JuliaCall)
julia <- julia_setup("/home/alex/julia-1.5.3/bin/")
julia$library("Bigsimr")
library(tidyverse)
library(microbenchmark)

make_cor_nearPD_call <- function(d, df, o) {
  m <- df[, head(o, d)]
  rho_s <- cor_fast(m, method = "spearman")
  rho_p <- cor_convert(rho_s, "spearman", "pearson")
  substitute(cor_nearPD(G = r), list(r = rho_p))
}

make_Matrix_nearPD_call <- function(d, df, o) {
  m <- df[, head(o, d)]
  rho_s <- cor_fast(m, method = "spearman")
  rho_p <- cor_convert(rho_s, "spearman", "pearson")
  substitute(Matrix::nearPD(x = r, corr = TRUE), list(r = rho_p))
}

make_MvSim_nearPD_call <- function(d, df, o) {
  m <- df[, head(o, d)]
  rho_s <- cor_fast(m, method = "spearman")
  rho_p <- cor_convert(rho_s, "spearman", "pearson")
  substitute(julia$call("MvSim.cor_nearPD", r), list(r = rho_p))
}

make_MvSim_fastPD_call <- function(d, df, o) {
  m <- df[, head(o, d)]
  rho_s <- cor_fast(m, method = "spearman")
  rho_p <- cor_convert(rho_s, "spearman", "pearson")
  substitute(julia$call("MvSim.cor_fastPD", r), list(r = rho_p))
}


if (file.exists("brca.rds")) {
  brca <- readRDS("brca.rds")
} else {
  brca0 <- TCGA2STAT::getTCGA(disease = "BRCA",
                              data.type = "RNASeq",
                              p = 6L)

  brca <- as.data.frame(t(brca0$dat))
  saveRDS(brca, "brca.rds")
}

gene_median <- apply(brca, 2, median)
gene_median_order <- order(gene_median, decreasing = TRUE)

d1 <- c(10, seq(500, 2000, 500))
d2 <- c(10, seq(250, 1000, 250))
d3 <- c(10, 1000, 2000, 4000)
d4 <- c(10, 1000, 2000, 4000, 8000)

unique(c(d1, d2, d3, d4))
length(c(d1, d2, d3, d4))

spec1 <- lapply(d1, make_cor_nearPD_call, df = brca, o = gene_median_order)
names(spec1) <- paste0("bigsimr::cor_nearPD", "-", "dim", d1)
spec2 <- lapply(d2, make_Matrix_nearPD_call, df = brca, o = gene_median_order)
names(spec2) <- paste0("Matrix::nearPD", "-", "dim", d2)
spec3 <- lapply(d3, make_MvSim_nearPD_call, df = brca, o = gene_median_order)
names(spec3) <- paste0("MvSim.cor_nearPD", "-", "dim", d3)
spec4 <- lapply(d4, make_MvSim_fastPD_call, df = brca, o = gene_median_order)
names(spec4) <- paste0("MvSim.cor_fastPD", "-", "dim", d4)


if (file.exists("bench.rds")) {
  mb <- readRDS("bench.rds")
} else {
  mb <- microbenchmark(list = c(spec1, spec2, spec3, spec4),
                       times = 5)
  saveRDS(mb, "bench.rds")
}

mb_df <- summary(mb, unit = "s") %>%
  as.data.frame %>%
  separate(expr, c("Method", "dim"), sep = "-", remove = TRUE) %>%
  mutate(dim = as.integer(str_remove(dim, "dim")),
         Method = factor(Method,
                         levels = c("Matrix::nearPD",
                                    "bigsimr::cor_nearPD",
                                    "MvSim.cor_nearPD",
                                    "MvSim.cor_fastPD")))

mb_df %>%
  ggplot(aes(dim, median, color = Method)) +
  geom_line() +
  geom_point() +
  labs(x = "Dimensions", y = "Time (Seconds)",
       title = "Benchmark Nearest Correlation Matrix") +
  scale_x_continuous(breaks = c(0, 500, 1000, 2000, 4000, 8000),
                     minor_breaks = NULL) +
  scale_y_continuous(breaks = c(0, 5, 10, 15, 30, 45, 60),
                     minor_breaks = NULL) +
  theme_bw()
