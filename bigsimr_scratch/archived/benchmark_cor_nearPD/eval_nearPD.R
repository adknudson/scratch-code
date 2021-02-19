library(tidyverse)
library(bigsimr)
library(Matrix)

eval_nearPD <- function(d, df, o) {
  m <- df[, head(o, d)]

  rho_s <- cor_fast(m, method = "spearman")
  rho_p <- cor_convert(rho_s, "spearman", "pearson")

  rho_bigsimr <- cor_nearPD(rho_p)
  rho_Matrix  <- nearPD(rho_p, corr = TRUE)$mat

  norm_bigsimr <- norm(rho_p - rho_bigsimr, type = "F")
  norm_Matrix  <- norm(rho_p - rho_Matrix, type = "F")
  c(bigsimr = norm_bigsimr, Matrix = norm_Matrix)
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

d <- c(250, 500, 750, 1000, 1250, 1500)
res <- vapply(d, eval_nearPD, FUN.VALUE = numeric(2),
              df = brca, o = gene_median_order)
df <- data.frame(t(res))
df$dim <- d

df %>%
  pivot_longer(c(bigsimr, Matrix), names_to = "Method", values_to = "Norm") %>%
  ggplot(aes(dim, Norm, fill = Method)) +
  geom_col(position = "dodge") +
  labs(x = "Dimensions", y = "Frobenius Norm",
       title = "Evaluate cor_nearPD") +
  scale_x_continuous(breaks = d, minor_breaks = NULL) +
  theme_bw()
