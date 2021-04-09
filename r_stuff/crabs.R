library(tidyverse)
library(lubridate)

df <- read_csv("~/Downloads/bugs.csv") %>%
  mutate(across(`row`:`Orius (pirate bug)`, as.integer),
         date = dmy(date)) %>%
  select(transect, row, positionX, position, date, julian, week,
         `Thomisidae (crab spider)`) %>%
  rename(count = `Thomisidae (crab spider)`) %>%
  mutate(across(c(transect, row, positionX, position), factor))

glimpse(df)

df %>%
  ggplot(aes(x = row, y = count)) +
  geom_point() +
  facet_grid(. ~ transect, scales = "free_x")

df %>%
  ggplot(aes(position, row)) +
  geom_point() +
  facet_grid(transect ~ positionX, scales = "free")

ggplot(df, aes(julian, count)) +
  geom_point() +
  facet_grid(~ transect + position, scales = "free_x")
