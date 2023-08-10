library(tidyverse)
library(readxl)
library(lubridate)
# 3 datasets from Jacob for package
# Zoops & WQ -------------------------------------------------------------------
zoop_raw <- read_csv('data-raw/metadata/F4F2019_Complete2019ZoopsPerM3andWaterQuality.csv') %>% glimpse
metadata <- read_excel('data-raw/metadata/F4F2019_metadata.xlsx', sheet = "attribute")

summary(zoop_raw)
# Check why colnames not aligning (where is the x1 coming from ?, missing Embryo)
# TODO ask Jacob about Embryo and removal of x1 column
sort(colnames(zoop_raw)) == sort(metadata$attribute_name)

zoop_data <- zoop_raw %>%
  mutate(DATE = as.Date(DATE, format = '%d/%m/%Y')) %>%
  select(-`...1`) %>% glimpse()

unique(zoop_data$LOCATION)

# zoops 2021:
zoop_raw_2021 <- read_csv('data-raw/metadata/2021_update/F4F2021_Complete2021ZoopsPerM3andWaterQuality.csv') %>% glimpse

setdiff(unique(names(zoop_data)),
        unique(names(zoop_raw_2021)))
setdiff(unique(names(zoop_raw_2021)),
        unique(names(zoop_data)))

# TODO: remove temp, do, environmental columns from zoop_raw_2021

# Continuous Temp --------------------------------------------------------------
temp_raw <- read_csv('data-raw/metadata/F4F2019_ContinuousTempDO.csv') %>% glimpse

unique(temp_raw$LOCATION)

# Temp range 46.51 - 68.97
summary(temp_raw)

temp_data <- temp_raw %>%
  mutate(DateTime = mdy_hm(DateTime))

# temp 2021
temp_raw_2021 <- read_csv('data-raw/metadata/2021_update/F4F2021_ContinuousTempDO.csv') %>% glimpse


# Fish Growth ------------------------------------------------------------------
fish_raw <- read_xlsx('data-raw/metadata/F4F2019_FishGrowth.xlsx') %>% glimpse

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

# fish 2021
fish_raw_2021 <- read_csv('data-raw/metadata/2021_update/F4F2021_FishGrowth.csv') %>% glimpse

# Location lookup table
locations <- read_excel("data-raw/metadata/F4F2019_LocationLookupTable.xlsx") %>% glimpse

# locations 2021
locations_raw_2021 <- read_excel('data-raw/metadata/2021_update/F4F2021_LocationLookupTable.xlsx') %>% glimpse

# TODO: add new columns to metadata/double check

# save cleaned data to `data/`
#write_csv(temp_data, 'data/F4F2019_ContinuousTempDO.csv')
#write_csv(fish_data, 'data/F4F2019_FishGrowth.csv')
#write_csv(zoop_data, 'data/F4F2019_Complete2019ZoopsPerM3andWaterQuality.csv')
write_csv(locations, "data//F4F2019_LocationLookupTable.csv")

