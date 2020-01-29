library(tidyverse)
library(readxl)

s1 <- read_xlsx("RAM Compat.xlsx", sheet = 1)
s2 <- read_xlsx("RAM Compat.xlsx", sheet = 2)

colnames(s1)[-10]

s1.1 <- s1 %>%
  unite(id, -`Zen+`) %>%
  mutate(`Zen+` = TRUE)

s2.1 <- s2 %>%
  unite(id, -`Zen2`) %>%
  mutate(`Zen2` = TRUE)

s3 <- full_join(s1.1, s2.1, "id")
s3$`Zen+`[which(is.na(s3$`Zen+`))] <- FALSE
s3$`Zen2`[which(is.na(s3$`Zen2`))] <- FALSE

s3.1 <- s3 %>%
  separate(id, into = colnames(s1)[-10], sep = "_", remove = TRUE)

s3.2 <- s3.1 %>%
  mutate_at(
    .vars = vars(
      Vendor,
      `SPD Speed`,
      `RAM Speed`,
      `Supported Speed`,
      Chipset,
      Voltage,
      Size),
    as.factor)

s3.2$Size <- as.integer(str_remove(s3.2$Size, "GB"))
s3.2$Voltage <- as.numeric(str_remove(s3.2$Voltage, "v"))
s3.2$Side[s3.2$Side == "SS"] <- "SINGLE"
s3.2$Side[s3.2$Side == "DS"] <- "DOUBLE"
s3.2$Side[s3.2$Side == "DUAL"] <- "DOUBLE"

s3.3 <- s3.2 %>%
  filter(
    `Zen+` == T,
    Zen2 == T,
    Vendor %in% c("Corsair", "Crucial", "G.Skill", "HyperX"),
    Size >= 8,
    Voltage < 1.35) %>%
  arrange(desc(`Supported Speed`), desc(Size)) %>%
  select(Vendor, Model, `RAM Speed`, `Supported Speed`, Chipset, Side, Size)

s3.3$cas <- str_extract(s3.3$Model, "(C1[3-8]|G1[3-8]|\\.1[3-8])")
s3.3$cas <- as.integer(str_remove(s3.3$cas, "C|G|\\."))

s3.3 %>%
  filter(cas <= 16, Size >= 16, str_detect(Chipset, "N/A", T)) %>%
  arrange(desc(`Supported Speed`), cas, desc(Size), ) %>%
  print(n = 30)

