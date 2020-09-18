library(ggplot2)
library(ggfortify)
library(RColorBrewer)
library(tidyverse)

load("data-raw/datRlog.RData")
hburkin_uterine_stretch <- datRlog

farben <- brewer.pal(11, 'Spectral')[8:11]
colorScheme <- c(rep(farben[1], 3),
                 rep(farben[2], 3),
                 rep(farben[3], 3),
                 rep(farben[4], 3))

pca <- prcomp(t(hburkin_uterine_stretch))
autoplot(pca, colour = colorScheme, size = 6)

PCs <- scale(pca$x) %>%
  as_tibble(rownames = "cond_rep") %>%
  separate(cond_rep, c("condition", "replication"), sep = "_", remove = FALSE) %>%
  mutate(cond_rep = factor(cond_rep),
         condition = factor(condition,
                            levels = c("0h", "3h", "8h", "24h"),
                            labels = c("Control", "3h", "8h", "24h")),
         replication = as.integer(replication)) %>%
  rename(`Strain Duration` = condition)

PCA_percents <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 2)

pca_plot <- PCs %>%
  ggplot(aes(PC1, PC2, fill = `Strain Duration`)) +
  geom_point(size = 5, shape = 21) +
  labs(x = paste0("PC1 (", PCA_percents[1], "%)"),
       y = paste0("PC2 (", PCA_percents[2], "%)"),
       title = "DESeq2 rlog-transformed filtered feature counts") +
  scale_fill_manual(values = farben)

pca_plot

ggsave(filename = "hburkin_uterine_stretch_PCA_5x4.png",
       path = "figures/",
       plot = pca_plot,
       device = "png",
       width = 5,
       height = 4,
       units = "in",
       dpi = 600)

ggsave(filename = "hburkin_uterine_stretch_PCA_5x5.png",
       path = "figures/",
       plot = pca_plot,
       device = "png",
       width = 5,
       height = 5,
       units = "in",
       dpi = 600)

ggsave(filename = "hburkin_uterine_stretch_PCA_6x4.png",
       path = "figures/",
       plot = pca_plot,
       device = "png",
       width = 6,
       height = 4,
       units = "in",
       dpi = 600)

pca_plot +
  coord_equal()
