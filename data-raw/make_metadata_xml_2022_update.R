#remotes::install_github("CVPIA-OSC/EMLaide")
library(EMLaide)
library(tidyverse)

# Load in all the documents
datatable_metadata <- tibble(filepath = c("data/2022_update/F4F_FishGrowth_2019_2021_2022.csv",
                                          "data/2022_update/F4F_ContinuousTempDO_2019_2021_2022.csv",
                                          "data/2022_update/F4F_Complete2021ZoopsPerM3andWaterQuality_2019_2021_2022.csv",
                                          "data/2022_update/F4F_LocationLookupTable_2019_2021_2022.csv"),
                             attribute_info = c("data-raw/metadata/2022_update/F4F2021_FishGrowth_AttributesTable2022.xlsx",
                                               "data-raw/metadata/2022_update/F4F2021_ContinuousTempDO_AttributesTable2022.xlsx",
                                               "data-raw/metadata/2022_update/F4F2021_metadata2022.xlsx",
                                                "data-raw/metadata/2022_update/Location_attributes_2022.xlsx"),
                             datatable_description = c("Fish Growth Data",
                                                      "Continuous Temperature Data",
                                                     "Zooplankton Density and Water Quality Data",
                                                      "Location Lookup Table for Sample Site"),
                             datatable_url = paste0("https://raw.githubusercontent.com/FlowWest/edi.996.1/v3.0/data/2022_update/",
                                                    c("F4F_FishGrowth_2019_2021_2022.csv",
                                                      "F4F_ContinuousTempDO_2019_2021_2022.csv",
                                                      "F4F_Complete2021ZoopsPerM3andWaterQuality_2019_2021_2022.csv",
                                                      "F4F_LocationLookupTable_2019_2021_2022.csv"
                                                      )))


# TODO Check warnings when reading in excel sheets
excel_path <- "data-raw/metadata/2022_update/F4F2021_metadata2022.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/metadata/2022_update/F4F2019_abstract_updatedthrough2022.docx"
methods_docx <- "data-raw/metadata/2022_update/F4F2019_methods_updatedthrough2022.docx"

# edi_number <- reserve_edi_id(user_id = Sys.getenv("user_id"), password = Sys.getenv("password"), environment = "staging")

# FOR STAGING:
edi_number <- 'edi.1087.3'

# FOR PRODUCTION:
# edi_number = "edi.996.3"

dataset <- list() %>%
  add_pub_date() %>%
  add_title(metadata$title) %>%
  add_personnel(metadata$personnel) %>%
  add_keyword_set(metadata$keyword_set) %>%
  add_abstract(abstract_docx) %>%
  add_license(metadata$license) %>%
  add_method(methods_docx) %>%
  add_maintenance(metadata$maintenance) %>%
  add_project(metadata$funding) %>%
  add_coverage(metadata$coverage, metadata$taxonomic_coverage) %>%
  add_datatable(datatable_metadata)

custom_units <- data.frame(id = c("microseimens per centimeter", "parts per thousand", "percent saturation", "pH",
                                  "Nephelometric Turbidity unit", "rotation start", "rotation end", "rank score"),
                           unitType = c("density", "density", "dimensionless", "dimensionless", "dimensionless",
                                        "dimensionless", "dimensionless", "dimensionless"),
                           parentSI = c(NA, NA, NA, NA, NA, NA, NA, NA),
                           multiplierToSI = c("siemensPerCentimeter", NA, NA, NA, NA, NA, NA, NA),
                           description = c("Number of microsiemens per centimeter, conductivity measurement",
                                           "Salinity measure of parts per thousand",
                                           "Percent saturation of disolved oxygen",
                                           "Measure of potential hydrogen",
                                           "Turbidity Units",
                                           "The start number of the flowmeter rotor",
                                           "The end number of the flowmeter rotor",
                                           "Subjective rank score of zooplankton density"))

unitList <- EML::set_unitList(custom_units)
eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(
              unitList = unitList)))

EML::write_eml(eml, paste0(edi_number, ".xml"))
EML::eml_validate(paste0(edi_number, ".xml"))

evaluate_edi_package(eml_file_path = paste0(edi_number, ".xml"), Sys.getenv("user_id"), Sys.getenv("password"), environment = "staging")

update_edi_package(eml_file_path = paste0(edi_number, ".xml"), existing_package_identifier = edi_number,
                   Sys.getenv("user_id"), Sys.getenv("password"),
                   environment = "staging")
