library(purrr)

d <- 8
score <- rep(c(-1, 1), length = d) * 1:d
E_single_roll <- sum(score) / d
E_number_rolls <- sum(1:d) / d

E_step_1_2 <- sum(1:d * E_single_roll / d)

P_sum_zero <- 0
for (i in 1:d) {
  rolls <- do.call("expand.grid", rep(list(score), i))
  P_sum_zero <- P_sum_zero + mean(rowSums(rolls) == 0) / 6
}

1 / P_sum_zero
E_step_1_2 / P_sum_zero

# Simulation =================================================================

d <- 6
score <- rep(c(-1, 1), length = d) * 1:d
sim <- replicate(10000, expr = {
  hist <- c()
  roll_sum <- NA
  while(roll_sum != 0 || is.na(roll_sum)) {
    roll_a_die <- sample(1:d, 1)
    rolls <- sample(score, roll_a_die, TRUE)
    roll_sum <- sum(rolls)
    hist <- c(hist, roll_sum)
  }
  hist
}, simplify = "list")


# Expected Steps
trials <- unlist(map(sim, ~ length(.x)))
# Expected Score
scores <- unlist(map(sim, ~ sum(.x)))
