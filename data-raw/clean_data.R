library(tidyverse)
library(readxl)
library(lubridate)
# 3 datasets from Jacob for package
# Zoops & WQ -------------------------------------------------------------------
zoop_raw <- read_csv('data-raw/metadata/F4F2019_Complete2019ZoopsPerM3andWaterQuality.csv')
metadata <- read_excel('data-raw/metadata/F4F2019_metadata.xlsx', sheet = "attribute")

# Check why colnames not aligning (where is the x1 coming from ?)
sort(colnames(zoop_raw)) == sort(metadata$attribute_name)

zoop_data <- zoop_raw %>%
  mutate(DATE = as.Date(DATE, format = '%d/%m/%Y')) %>%
  select(-X1)

# Still not working...look more into this
sort(colnames(zoop_data)) == sort(metadata$attribute_name)

# Continuous Temp --------------------------------------------------------------
temp_raw <- read_csv('data-raw/metadata/F4F2019_ContinuousTempDO.csv')

unique(temp_raw$LOCATION)

# Temp range 46.51 - 68.97
summary(temp_raw)

temp_data <- temp_raw %>%
  mutate(DateTime = mdy_hm(DateTime))

# Fish Growth ------------------------------------------------------------------
fish_raw <- read_xlsx('data-raw/metadata/F4F2019_FishGrowth.xlsx')

unique(fish_raw$LOCATION)

fish_data <- fish_raw %>%
  mutate(Date = as_date(Date),
         Length.mm = as.numeric(Length.mm),
         Weight.g = as.numeric(Weight.g))

# Check that I didn't not create any new NA (warning)
sum(fish_raw$Length.mm == "NA")
sum(is.na(fish_data$Length.mm))

sum(fish_raw$Weight.g == "NA")
sum(is.na(fish_data$Weight.g))

# save cleaned data to `data/`
write_csv(temp_data, 'data/temp_data.csv')
write_csv(fish_data, 'data/fish_data.csv')
write_csv('data/')
