library(EMLaide)
library(tidyverse)

# Load in all the documents
datatable_metadata <- tibble(filepath = c("data/F4F2019&2021_FishGrowth.csv",
                                          "data/F4F2019&2021_ContinuousTempDO.csv",
                                          "data/F4F_Complete2019&2021ZoopsPerM3andWaterQuality.csv",
                                          "data/F4F2019&2021_LocationLookupTable.csv"
                                          ),
                             attribute_info = c("data-raw/metadata/F4F2019_FishGrowth_AttributesTable.xlsx",
                                                "data-raw/metadata/F4F2019_ContinuousTempDO_AttributesTable.xlsx",
                                                "data-raw/metadata/F4F2021_metadata.xlsx",
                                                "data-raw/metadata/Location_attributes.xlsx"
                                                ),
                             datatable_description = c("Fish Growth Data",
                                                       "Continuous Temperature Data",
                                                       "Zooplankton Density and Water Quality Data",
                                                       "Location Lookup Table for Sample Site"
                                                       ),
                             datatable_url = paste0("https://raw.githubusercontent.com/FlowWest/edi.996.1/v2.0/",
                                                 c("data/F4F2019&2021_FishGrowth.csv",
                                                   "data/F4F2019&2021_ContinuousTempDO.csv",
                                                   "data/F4F_Complete2019&2021ZoopsPerM3andWaterQuality.csv",
                                                   "data/F4F2019&2021_LocationLookupTable.csv"
                                                 )))


# TODO Check warnings when reading in excel sheets
excel_path <- "data-raw/metadata/F4F2021_metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/metadata/F4F2019_abstract_updatedthrough2021.docx"
methods_docx <- "data-raw/metadata/F4F2019_methods_updatedthrough2021.docx"

# edi_number <- reserve_edi_id(user_id = Sys.getenv("user_id"), password = Sys.getenv("password"),
#                              environment = "staging")


edi_number = "edi.996.2"
# edi_number = "edi.946.1"
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

EML::write_eml(eml, "edi.996.2.xml")
EML::eml_validate("edi.996.2.xml")

evaluate_edi_package(eml_file_path = "edi.996.2.xml", Sys.getenv("user_id"), Sys.getenv("password"), environment = "production")

upload_edi_package(eml_file_path = "edi.946.1.xml", Sys.getenv("user_id"), Sys.getenv("password"), environment = "staging")
