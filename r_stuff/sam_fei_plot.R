library(tidyverse)
library(readxl)

read_modis_viiris <- function(sheet_no, sheet_id="") {
  read_excel(
    path = "~/Downloads/MODIS_VIIRIS_Info.xlsx",
    sheet = sheet_no,
    skip = 1
  ) %>% rename(Date = `...1`) %>% add_column(ID = sheet_id, .before = 1)
}

MODIS      <- read_modis_viiris(1, "MODIS")
MODIS_Rim  <- read_modis_viiris(2, "MODIS_Rim")
VIIRIS     <- read_modis_viiris(3, "VIIRIS")
VIIRIS_Rim <- read_modis_viiris(4, "VIIRIS_Rim")

colnames(MODIS_Rim) <- colnames(VIIRIS) <- colnames(VIIRIS_Rim) <- colnames(MODIS)

dat <- bind_rows(MODIS, MODIS_Rim, VIIRIS, VIIRIS_Rim) %>%
  mutate(ID = factor(ID))

write_csv(dat, "~/Downloads/MODIS_VIIRIS_Info.csv")

