library(tidyverse)
library(readxl)
library(lubridate)


# which files -------------------------------------------------------------
update_2022 <- list.files('data-raw/metadata/2022_update/')
update_2021 <- list.files('data-raw/metadata/2021_update/')

file_comparison <- data.frame(file_2021 = c(update_2021, NA),
           file_2022 = update_2022)

# lookup tables -----------------------------------------------------------
# Two lookup tables for 2022
## TODO: do we need this non-2022 file?
lookup <- readxl::read_excel('data-raw/metadata/2022_update/F4F2021_LocationLookupTable.xlsx')

lookup_2022_raw <- readxl::read_excel('data-raw/metadata/2022_update/F4F2021_LocationLookupTable_2022.xlsx')
head(lookup_2022_raw)
lookup_2022 <- lookup_2022_raw |>
  select(-`...3`) |> glimpse()
unique(lookup_2022$Location)

write_csv(lookup_2022, "data/2022_update/F4F2021_LocationLookupTable_2022.csv")


# F4F2021_Complete2021ZoopsPerM3andWaterQuality2022 -----------------------
zoops_wq_raw <- read_csv('data-raw/metadata/2022_update/F4F2021_Complete2021ZoopsPerM3andWaterQuality2022.csv') |> glimpse()

# `...1` column not included in metadata. will remove.
zoops_wq <- zoops_wq_raw |>
  mutate(DATE = lubridate::mdy(DATE)) |>
  select(-`...1`) |>
  glimpse()

# TODO: BGA has negative values. what is BGA? blue-green algae fluorescence
# of water at time of sample collection

ggplot(zoops_wq) +
  geom_point(aes(x = DATE, y = BGA...g.L.))

write_csv(zoops_wq, 'data/2022_update/F4F2021_Complete2021ZoopsPerM3andWaterQuality2022.csv')

# F4F2021_ContinuousTempDO_AttributesTable2022 ----------------------------
# F4F2021_ContinuousTempDO2022
temp_do_attr <- readxl::read_excel('data-raw/metadata/2022_update/F4F2021_ContinuousTempDO_AttributesTable2022.xlsx')
temp_do_raw <- read_csv('data-raw/metadata/2022_update/F4F2021_ContinuousTempDO2022.csv')

temp_do <- temp_do_raw |>
  mutate(DateTime = mdy_hm(DateTime)) |> glimpse()

# huge DO spike in April
ggplot(temp_do) +
  geom_line(aes(x = DateTime, y = DO.mgL)) +
  facet_wrap(~LOCATION)

# temperature also has noise in April
ggplot(temp_do) +
  geom_line(aes(x = DateTime, y = Temp.F)) +
  facet_wrap(~LOCATION)

# TODO: ask Jacob about anomalies starting April 1

write_csv(temp_do, "data/2022_update/F4F2021_ContinuousTempDO2022.csv")


# F4F2021_FishGrowth2022 --------------------------------------------------
fish_growth <- readxl::read_excel('data-raw/metadata/2022_update/F4F2021_FishGrowth2022.xlsx') |> glimpse()

ggplot(fish_growth, aes(x = Date, y = Length.mm)) +
  geom_point() +
  facet_wrap(~LOCATION)

ggplot(fish_growth, aes(x = Date, y = Weight.g)) +
  geom_point() +
  facet_wrap(~LOCATION)

unique(fish_growth$PIT)

write_csv(fish_growth, "data/2022_update/F4F2021_FishGrowth2022.csv")



