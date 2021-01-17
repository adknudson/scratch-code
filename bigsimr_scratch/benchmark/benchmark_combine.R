args <- commandArgs(trailingOnly = TRUE)
subdir <- args[1]
out <- paste0(subdir, "/benchmark_combined.rds")

library(tidyverse)
library(microbenchmark)

cpu0 <- readRDS(paste0(subdir, "/benchmark_bigsimr-cpu.rds"))
gpu0 <- readRDS(paste0(subdir, "/benchmark_bigsimr-gpu.rds"))

cpu <- summary(cpu0) %>%
  as.data.frame() %>%
  add_column(type = "CPU", .before = 1) %>%
  separate(expr, c("dims", "cores"), sep = "_") %>%
  mutate(across(.cols = c("dims", "cores"),
                .fns = str_remove,
                pattern = regex("\\D+")),
         across(.cols = c("dims", "cores"), as.integer))

gpu <- summary(gpu0) %>%
  as.data.frame() %>%
  add_column(type = "GPU", .before = 1) %>%
  separate(expr, c("dims", "cores"), sep = "_") %>%
  mutate(across(.cols = c("dims", "cores"),
                .fns = str_remove,
                pattern = regex("\\D+")),
         across(.cols = c("dims", "cores"), as.integer))

dev <- bind_rows(cpu, gpu) %>%
  mutate(type = factor(type))

saveRDS(dev, out)
