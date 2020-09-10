library(SWisSFreeNet)
library(tidyverse)
library(ggfortify)
library(RSpectra)

plot_condrep_PCA <- function(A, sep, estimate_variance = FALSE) {
  if (is.null(rownames(A))) {
    stop("The data matrix must have row names")
  }

  C <- cov(A)

  if (estimate_variance) {
    P <- RSpectra::eigs_sym(C, min(ncol(A), 10))
    var_prop <- P$values / sum(P$values)
  } else {
    P <- RSpectra::eigs_sym(C, 2)
  }

  PCs <- A %*% P$vectors[, 1:2]
  colnames(PCs) <- paste0("PC", 1:2)

  m <- colMeans(PCs)
  s <- 4 * apply(PCs, 2, sd)

  PCs <- (PCs - matrix(1, nrow(PCs), 1) %*% m) / (matrix(1, nrow(PCs), 1) %*% s)

  df <- PCs %>%
    as_tibble(rownames = "cond_rep") %>%
    separate(cond_rep, c("Condition", "Replication"), sep=sep, remove=TRUE) %>%
    mutate(Condition = factor(Condition),
           Replication = factor(Replication))

  shape_order <- c(15, 16, 17, 18, 21, 22, 23, 25, 25, 0, 1, 2, 5, 7, 10, 11)
  n_reps <- length(levels(df$Replication))

  p <- df %>%
    ggplot(aes(PC1, PC2, color = Condition, shape = Replication)) +
    geom_point(size = 8) +
    guides(color = guide_legend(order = 1),
           shape = guide_legend(order = 0)) +
    scale_shape_manual(values = shape_order[1:n_reps]) +
    theme_light()

  if (estimate_variance) {
    xlab <- paste0("PC1 (", round(100 * var_prop[1], 2), "% variance)")
    ylab <- paste0("PC2 (", round(100 * var_prop[2], 2), "% variance)")
    p <- p + labs(x = xlab, y = ylab)
  }

  p
}

dat <- hurkin %>%
  select(Hy_A_S5_sorted_bam:Veh_D_S12_sorted_bam) %>%
  as.matrix()

new_names <- paste(
  rep(c("Hyper.IL6", "IL6", "Vehicle"), each=4),
  rep(LETTERS[1:4], times=3),
  sep = "_")

colnames(dat) <- new_names

pca <- prcomp(t(dat))
autoplot(pca)

pca$x / (3 * matrix(1, 12, 1) %*% pca$sdev)

plot_condrep_PCA(t(dat), sep = "_")
# plot_condrep_PCA(data_matrix, sep = "_", estimate_variance = TRUE)
