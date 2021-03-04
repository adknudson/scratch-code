library(tidyr)
library(dplyr)
library(ggplot2)

df <- readr::read_csv("benchmark_results.csv",
                      col_types = c("ifiddddd"))

df_long <- df %>%
  select(-total_time) %>%
  pivot_longer(cols = c(corr_time:sim_time),
               names_to = "Step",
               values_to = "Time") %>%
  mutate(fct_dim = factor(dim),
         fct_samples = factor(samples),
         Step = factor(Step,
                       levels = c("corr_time",
                                  "adjust_time",
                                  "admiss_time",
                                  "sim_time"),
                       labels = c("Compute Correlation",
                                  "Adjust Correlation",
                                  "Check Admissibility",
                                  "Simulate Data"))) %>%
  rename(Correlation = corr, Dimensions = fct_dim, Samples = fct_samples)


df_long %>%
  filter(dim > 2 & dim <= 100) %>%
  ggplot(aes(Samples, Time, fill=Step)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(y = "Time (Seconds)") +
  facet_grid(Correlation ~ Dimensions, scales = "free") +
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust = 0.5))

df_long %>%
  filter(dim > 100 & dim <= 1000) %>%
  ggplot(aes(Samples, Time, fill=Step)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(y = "Time (Seconds)") +
  facet_grid(Correlation ~ Dimensions, scales = "free") +
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust = 0.5))


df_long %>%
  filter(dim >= 1000 & dim <= 5000) %>%
  ggplot(aes(Samples, Time, fill=Step)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(y = "Time (Seconds)") +
  facet_grid(Dimensions ~ Correlation, scales = "free") +
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust = 0.5))


