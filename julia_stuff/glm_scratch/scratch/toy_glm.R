# Define the sampling scheme
x <- sample(rep(seq(0.04, 0.32, by=0.04), each=20))
N <- length(x)

a <- -4.5
b <- 25
mu <- a + b*x

f <- function(x) 0.5 + 0.5 * pnorm(x)
p <- f(mu)

# simulate a bernoulli process
y <- rbinom(N, 1, p)

library(ggplot2)
ggplot(data.frame(y=y, x=x), aes(x,y)) +
  geom_point(size = 5, alpha = 0.05)

library(dplyr)
data.frame(y, x) %>%
  group_by(x) %>%
  summarise(p = mean(y)) %>%
  ggplot(aes(x, p)) +
  geom_point(size = 5) +
  stat_function(fun = function(x) f(a + b*x), lty="dashed")

# fit the model
library(psyphy)
m <- glm(y ~ 1 + x, family = binomial(link = mafc.probit(2)))
summary(m)

a_hat <- coef(m)[1]
b_hat <- coef(m)[2]

data.frame(y, x) %>%
  group_by(x) %>%
  summarise(p = mean(y)) %>%
  ggplot(aes(x, p)) +
  geom_point(size = 5) +
  stat_function(fun = function(x) f(a + b*x), lty="dashed") +
  stat_function(fun = function(x) f(a_hat + b_hat*x),
                col="blue")
