library(tidyverse)

# part 1

df <- read_table2("scratch-code/advent_of_code2020/day2_input.txt",
                  col_names = FALSE) %>%
  separate(X1, c("lo", "hi"), sep="-") %>%
  mutate(X2 = str_remove(X2, ":")) %>%
  mutate(lo = as.integer(lo),
         hi = as.integer(hi)) %>%
  rename(chr = X2, pwd = X3)

df_p1 <- df %>%
  mutate(ccount = str_count(pwd, chr),
         valid = lo <= ccount & ccount <= hi)

sum(df_p1$valid)


# part 2

df_p2 <- df %>%
  rename(p1 = lo, p2 = hi) %>%
  mutate(chr_in_p1 = str_sub(pwd, start = p1, end=p1) == chr,
         chr_in_p2 = str_sub(pwd, start = p2, end=p2) == chr,
         valid = xor(chr_in_p1, chr_in_p2))

sum(df_p2$valid)
