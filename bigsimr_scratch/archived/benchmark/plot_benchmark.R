library(tidyverse)
df <- readRDS("scratch/benchmark/_benchmark/benchmark_combined.rds")

df %>%
  mutate(median_seconds = median / 1000) %>%
  ggplot(aes(factor(dims), median_seconds, fill = factor(cores))) +
  geom_col(position = "dodge") +
  facet_grid(. ~ type) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = -60, vjust=0.5, hjust=0)) +
  scale_y_continuous(breaks = seq(0, 25, 5)) +
  labs(x = "Dimensions", y = "Time (seconds)",
       title = "bigsimr Benchmark", subtitle = "B = 10,000") +
  scale_fill_discrete(name = "Cores")
