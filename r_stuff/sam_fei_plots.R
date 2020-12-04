library(tidyverse)

df <- tibble(
  metric = c("Burned Area", "CO2", "CO", "CH4", "PM2.5"),
  MLFEI = c(7554, 2.68e8, 2.15e7, 1.18e6, 3.65e6),
  WFIES = c(5718, 6.11e6, 4.12e5, 2.00e4, 4.86e4),
  FINN  = c(6542, 2.64e6, 1.39e5, 5.51e3, 1.83e4),
  GFED  = c(6804, 4.53e10, 2.42e9, 9.24e7, 3.55e8)
)

df_long <- df %>%
  pivot_longer(cols = c(MLFEI:GFED), names_to = "FEI", values_to = "value") %>%
  mutate(metric = factor(metric),
         FEI = factor(FEI))

df_long %>%
  ggplot(aes(metric, value, fill = FEI)) +
  geom_col(position = "dodge") +
  scale_y_log10(breaks = 10^seq(3, 12, 3),
                minor_breaks = 10^seq(3, 12, 1)) +
  labs(title = "2013")

