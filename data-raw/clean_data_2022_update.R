library(tidyverse)
library(readxl)
library(lubridate)


# which files -------------------------------------------------------------
update_2022 <- list.files('data-raw/metadata/2022_update/')
update_2021 <- list.files('data-raw/metadata/2021_update/')

file_comparison <- data.frame(file_2021 = c(update_2021, NA, NA, NA),
           file_2022 = update_2022)

# lookup tables -----------------------------------------------------------
# Two lookup tables for 2022
## TODO: do we need this non-2022 file?
lookup <- readxl::read_excel('data-raw/metadata/2022_update/F4F2021_LocationLookupTable.xlsx')

lookup_2022_raw <- readxl::read_excel('data-raw/metadata/2022_update/F4F2021_LocationLookupTable_2022.xlsx')
head(lookup_2022_raw)
lookup_2022 <- lookup_2022_raw |>
  rename(`Lat Long UTM` = `Lat, lon (UTM)`) |>
  mutate(`Lat Long UTM` = gsub(",", " ", `Lat Long UTM`)) |>
  glimpse()
unique(lookup_2022$Location)


location_cols <- colnames(lookup_2022)
metadata_cols <- readxl::read_excel("data-raw/metadata/2022_update/Location_attributes_2022.xlsx", sheet = "attribute") |>
  pull(attribute_name)

setdiff(location_cols, metadata_cols)
setdiff(metadata_cols, location_cols)


# Compare to 2021 locations lookup
locations_2021 <- read_csv('data/F4F2019_LocationLookupTable.csv')
unique(locations_2021$Location)
unique(lookup_2022$Location)
setdiff(unique(locations_2021$Location), unique(lookup_2022$Location))

write_csv(lookup_2022, "data/2022_update/F4F2021_LocationLookupTable_2022.csv")


# F4F2021_Complete2021ZoopsPerM3andWaterQuality2022 -----------------------
zoops_wq_raw <- read_csv('data-raw/metadata/2022_update/F4F2021_Complete2021ZoopsPerM3andWaterQuality2022.csv') |> glimpse()

# `...1` column not included in metadata. will remove.
zoops_wq <- zoops_wq_raw |>
  mutate(DATE = lubridate::mdy(DATE)) |>
  select(-`...1`) |>
  rename(Illyocypris = Ilyocypris,
         Hyallela = Hyalella) |>
  glimpse()

# TODO: BGA has negative values. what is BGA? blue-green algae fluorescence
# of water at time of sample collection

ggplot(zoops_wq) +
  geom_point(aes(x = DATE, y = BGA...g.L.))

# make sure columns align between data and metadata:
zoop_cols <- colnames(zoops_wq)
metadata_cols <- readxl::read_excel("data-raw/metadata/2022_update/F4F2021_metadata2022.xlsx", sheet = "attribute") |>
  pull(attribute_name)

setdiff(zoop_cols, metadata_cols)
setdiff(metadata_cols, zoop_cols)

write_csv(zoops_wq, 'data/2022_update/F4F2021_Complete2021ZoopsPerM3andWaterQuality2022.csv')


# F4F2021_ContinuousTempDO_AttributesTable2022 ----------------------------
# F4F2021_ContinuousTempDO2022
temp_do_raw <- read_csv('data-raw/metadata/2022_update/F4F2021_ContinuousTempDO2022.csv')

temp_do <- temp_do_raw |>
  mutate(DateTime = mdy_hm(DateTime)) |>
  filter(DateTime <= '2022-03-29')

# huge DO spike in April
ggplot(temp_do) +
  geom_line(aes(x = DateTime, y = DO.mgL)) +
  facet_wrap(~LOCATION)

# temperature also has noise in April
ggplot(temp_do) +
  geom_line(aes(x = DateTime, y = Temp.F)) +
  facet_wrap(~LOCATION)

# remove anomalies and cut filter data < 3/29

cols <- colnames(temp_do)
metadata_cols <- readxl::read_excel("data-raw/metadata/2022_update/F4F2021_ContinuousTempDO_AttributesTable2022.xlsx", sheet = "attribute") |>
  pull(attribute_name)

setdiff(cols, metadata_cols)
setdiff(metadata_cols, cols)


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

cols <- colnames(fish_growth)
metadata_cols <- readxl::read_excel("data-raw/metadata/2022_update/F4F2021_FishGrowth_AttributesTable2022.xlsx", sheet = "attribute") |>
  pull(attribute_name)

setdiff(cols, metadata_cols)
setdiff(metadata_cols, cols)

write_csv(fish_growth, "data/2022_update/F4F2021_FishGrowth2022.csv")



