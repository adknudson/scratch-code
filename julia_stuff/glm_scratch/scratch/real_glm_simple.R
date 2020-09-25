library(tidyverse)
library(readr)
library(psyphy)

df <- read_csv("~/projects/scratch-code/julia_stuff/glm_scratch/data/motion_coherence_data.csv")

df2 <- df %>%
  select(correct, condition1) %>%
  transmute(y = as.integer(correct),
            x = condition1)

glm(y ~ 1 + x, data = df2, family = binomial(link = mafc.probit(2)))
