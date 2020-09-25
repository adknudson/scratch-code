library(tidyverse)
library(readr)
library(psyphy)

df <- read_csv("data/motion_coherence_data.csv")

df2 <- df %>%
  select(correct, condition1) %>%
  transmute(y = as.integer(correct),
            x = condition1)

m_p <- glm(y ~ 1 + x, data = df2, family = binomial(link = mafc.probit(2)))
m_l <- glm(y ~ 1 + x, data = df2, family = binomial(link = mafc.logit(2)))

coef(m_p)
coef(m_l)

a_p <- coef(m_p)[1]
b_p <- coef(m_p)[2]
a_l <- coef(m_l)[1]
b_l <- coef(m_l)[2]

# 2afc probit link
p <- function(x) 0.5 + 0.5 * pnorm(x)
# 2afc logit link
l <- function(x) 0.5 + 0.5 * plogis(x)

df2 %>%
  group_by(x) %>%
  summarise(p = mean(y)) %>%
  ggplot(aes(x, p)) +
  geom_point(size = 4, shape = 15) +
  stat_function(fun = function(x) p(a_p + b_p*x),
                aes(color = "Probit")) +
  stat_function(fun = function(x) l(a_l + b_l*x),
                aes(color = "Logit")) +
  labs(x = "Condition 1",
       y = "Observed Proportion Correct",
       color = "Fitted Curve") +
  scale_y_continuous(limits = c(0, 1))
