library(BayesPsychometric)
library(FangPsychometric)
library(tidyverse)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

dat <- audiovisual %>%
  filter(trial %in% c("baseline", "adapt1")) %>%
  mutate(trial = droplevels(trial),
         subject_id = factor(subject_id)) %>%
  select(response, soa, subject_id, age_group, trial)

fs <- f2stan(response ~ soa + subject_id + age_group + trial, dat, "logit", TRUE)

dat_ls <- fs$data
dat_ls$soa <- dat$soa

fit <- stan(file = "tmp_model.stan", data = dat_ls, chains = 2, cores = 2,
            warmup = 2000, iter = 4000)

post <- rstan::extract(fit)
