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
locations_2021 <- read_csv('data/F4F2019_2021_LocationLookupTable.csv')
unique(locations_2021$Location)
unique(lookup_2022$Location)
setdiff(unique(locations_2021$Location), unique(lookup_2022$Location))

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

# compare to 2019, 2021 files
zoops_21 <- read_csv('data/F4F_Complete2019_2021ZoopsPerM3andWaterQuality.csv')
min(zoops_21$DATE, na.rm = TRUE)
max(zoops_21$DATE, na.rm = TRUE)

# bind rows with 2019, 2021 files
all_zoops <- bind_rows(zoops_wq, zoops_21 |> rename(Illyocypris = Ilyocypris,
                                                  Hyallela = Hyalella,
                                                  Oliogochaete = Oligochaete) ) |>
  arrange(DATE)
unique(lubridate::year(all_zoops$DATE))

# make sure columns align between data and metadata:
zoop_cols <- colnames(all_zoops)
metadata_cols <- readxl::read_excel("data-raw/metadata/2022_update/F4F2021_metadata2022.xlsx", sheet = "attribute") |>
  pull(attribute_name)

setdiff(zoop_cols, metadata_cols)
setdiff(metadata_cols, zoop_cols)

# F4F2021_ContinuousTempDO_AttributesTable2022 ----------------------------
# F4F2021_ContinuousTempDO2022
temp_do_raw <- read_csv('data-raw/metadata/2022_update/F4F2021_ContinuousTempDO2022.csv')

temp_do <- temp_do_raw |>
  mutate(DateTime = as_datetime(mdy_hm(DateTime))) |>
 # mutate(DateTime = mdy_hm(DateTime)) |>
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

temp_do_2019_2021 <- read_csv('data/F4F2019_2021_ContinuousTempDO.csv')

all_temp_do <- bind_rows(temp_do_2019_2021, temp_do) |> arrange(DateTime) |> glimpse()

ggplot(all_temp_do) +
  geom_line(aes(x = DateTime, y = DO.mgL)) +
  facet_wrap(~LOCATION)



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

fish_growth_2019_2021 <- read_csv('data/F4F2019_2021_FishGrowth.csv') |> glimpse()
all_fish_growth <- bind_rows(fish_growth, fish_growth_2019_2021) |> arrange(Date) |>
  mutate(Date = lubridate::as_date(Date),
         Length.mm = as.numeric(Length.mm),
         Weight.g = as.numeric(Weight.g)) |>
  glimpse()

ggplot(all_fish_growth, aes(x = Date, y = Weight.g)) +
  geom_point() +
  facet_wrap(~LOCATION)

# write data --------------------------------------------------------------
write_csv(lookup_2022, "data/2022_update/F4F2021_LocationLookupTable_2019_2021_2022.csv")
write_csv(all_fish_growth, "data/2022_update/F4F2021_FishGrowth_2019_2021_2022.csv")
write_csv(all_temp_do, "data/2022_update/F4F2021_ContinuousTempDO_2019_2021_2022.csv")
write_csv(all_zoops, 'data/2022_update/F4F2021_Complete2021ZoopsPerM3andWaterQuality_2019_2021_2022.csv')


