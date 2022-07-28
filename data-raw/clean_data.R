library(tidyverse)
library(readxl)
library(lubridate)
# 3 datasets from Jacob for package
# Zoops & WQ -------------------------------------------------------------------
zoop_raw_2019 <- read_csv('data-raw/metadata/F4F2019_Complete2019ZoopsPerM3andWaterQuality.csv') %>%
  rename(Oligochaete = Oliogochaete) %>% glimpse
metadata <- read_excel('data-raw/metadata/F4F2019_metadata.xlsx', sheet = "attribute")

summary(zoop_raw_2019)
# Check why colnames not aligning (where is the x1 coming from ?, missing Embryo)
# TODO ask Jacob about Embryo and removal of x1 column
sort(colnames(zoop_raw_2019)) == sort(metadata$attribute_name)

zoop_data_2019 <- zoop_raw_2019 %>%
  mutate(DATE = as.Date(DATE, format = '%d/%m/%Y')) %>%
  select(-1) %>% glimpse()

zoop_raw_2021 <- read_csv('data-raw/metadata/F4F2021_Complete2021ZoopsPerM3andWaterQuality.csv') %>%
  rename(Cladocera.embryo = Embryo,
         ID = `RRCAN_11/9/2020_10:00`,
         Ilyocypris = Illyocypris,
         Hyalella = Hyallela) %>%
  glimpse

zoop_data_2021 <- zoop_raw_2021 %>%
  mutate(DATE = as.Date(DATE, format = '%d/%m/%Y')) %>%
  select(-1) %>% glimpse()

zoop_data <- bind_rows(zoop_data_2021, zoop_data_2019) %>% glimpse

unique(zoop_data$LOCATION)

# Continuous Temp --------------------------------------------------------------
temp_raw_2019 <- read_csv('data-raw/metadata/F4F2019_ContinuousTempDO.csv')

unique(temp_raw_2019$LOCATION)

# Temp range 46.51 - 68.97
summary(temp_raw_2019)

temp_data_2019 <- temp_raw_2019 %>%
  mutate(DateTime = as_datetime(mdy_hm(DateTime))) %>%
  glimpse

# Add 2021 data
temp_raw_2021 <- read_csv('data-raw/metadata/F4F2021_ContinuousTempDO.csv') %>% glimpse

unique(temp_raw_2021$LOCATION)

# Temp range 46.51 - 68.97
summary(temp_raw_2021)

temp_data_2021 <- temp_raw_2021 %>%
  mutate(DateTime = as_datetime(DateTime)) %>%
  select(-...1) %>%
  rename(DO.mgL = DO.mg) %>% glimpse

temp_data <- bind_rows(temp_data_2019, temp_data_2021) %>% glimpse

# Fish Growth ------------------------------------------------------------------
fish_raw_2019 <- read_xlsx('data-raw/metadata/F4F2019_FishGrowth.xlsx') %>% glimpse

unique(fish_raw_2019$LOCATION)

fish_data_2019 <- fish_raw_2019 %>%
  mutate(Date = as_date(Date),
         Length.mm = as.numeric(Length.mm),
         Weight.g = as.numeric(Weight.g)) %>%
  glimpse

# Check that I didn't not create any new NA (warning)
sum(fish_raw$Length.mm == "NA")
sum(is.na(fish_data$Length.mm))

sum(fish_raw$Weight.g == "NA")
sum(is.na(fish_data$Weight.g))

fish_raw_2021 <- read_csv('data-raw/metadata/F4F2021_FishGrowth.csv') %>% glimpse

unique(fish_raw_2021$LOCATION)

fish_data_2021 <- fish_raw_2021 %>%
  mutate(Date = as_date(Date, format = "%m/%d/%Y"),
         Length.mm = as.numeric(Length.mm),
         Weight.g = as.numeric(Weight.g)) %>%
  glimpse

# Combine
fish_data <- bind_rows(fish_data_2019, fish_data_2021) %>% glimpse

# Location lookup table
# locations_2019 <- read_excel("data-raw/metadata/F4F2019_LocationLookupTable.xlsx") %>% glimpse

locations <- read_excel("data-raw/metadata/F4F2021_LocationLookupTable.xlsx") %>% glimpse

# save cleaned data to `data/`
write_csv(temp_data, 'data/F4F2019&2021_ContinuousTempDO.csv')
write_csv(fish_data, 'data/F4F2019&2021_FishGrowth.csv')
write_csv(zoop_data, 'data/F4F_Complete2019&2021ZoopsPerM3andWaterQuality.csv')
write_csv(locations, "data//F4F2019&2021_LocationLookupTable.csv")

