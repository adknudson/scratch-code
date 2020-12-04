library(tidyverse)

sp <- "/mnt/Data/Videos/Handbrake Default/South Park/"
old_names <- list.files(sp)

df <- tibble(old = old_names) %>%
  mutate(new = str_remove(old, regex("^South[\\.| ]Park[\\.| ]")),
         SE = str_extract(new, regex("^S[0-9]{1,2}E[0-9]{1,2}")),
         ext = str_extract(old, regex("(?<=\\.)\\S{3}$"))) %>%
  mutate(name = str_remove(new, regex("^S[0-9]{1,2}E[0-9]{1,2}[\\.| ]")),
         name = str_remove(name, regex("\\.\\S{3}$"))) %>%
  separate(SE, into = c("Season", "Episode"), sep = "E", remove = TRUE) %>%
  mutate(Season = str_remove(Season, "S")) %>%
  mutate(across(where(is.character), trimws),
         Season_no = as.integer(Season),
         Episode_no = as.integer(Episode)) %>%
  mutate(name = str_remove(name, regex("\\.UNCENSORED.*")),
         name = str_remove(name, regex("\\.1080p.*"))) %>%
  arrange(Season_no, Episode_no) %>%
  mutate(name = if_else(Season_no <= 20 & Season_no >= 1,
                        name,
                        str_replace_all(name, pattern = "\\.", replacement = " "))) %>%
  mutate(new = paste0("South Park_S", Season, "E", Episode, "_", name, ".", ext))


file.rename(from = paste0(sp, df$old), to = paste0(sp, df$new))
