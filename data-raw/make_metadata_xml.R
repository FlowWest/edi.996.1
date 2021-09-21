library(EMLaide)
library(tidyverse)

# Read in needed files ---------------------------------------------------------
datatable_metadata <- dplyr::tibble(filepath = c("data/fish_data.csv",
                                                 "data/temp_data.csv",
                                                 "data/zoop_data.csv"),
                                    attribute_info = c("data-raw/metadata/F4F2019_FishGrowth_AttributesTable.xlsx",
                                                       "data-raw/metadata/F4F2019_ContinuousTempDO_AttributesTable.xlsx",
                                                       "data-raw/metadata/F4F2019_metadata.xlsx"),
                                    datatable_description = c("Fish Growth Data",
                                                              "Continuious Temperature Data",
                                                              "Zooplankton Data"))
excel_path <- "data-raw/metadata/F4F2019_metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/metadata/F4F2019_abstract.docx"
methods_docx <- "data-raw/metadata/F4F2019_methods.docx"

# Reserve EDI number or get from EDI portal ------------------------------------
# edi_number <- reserve_edi_id(user_id = Sys.getenv("EDI_user"), password = Sys.getenv("EDI_pass"))
edi_number <- "edi.996.1"

# Use EMLaide functions to compile nested list of elements
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

# Create xml
eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset)
EML::write_eml(eml, "edi.996.1.xml")
EML::eml_validate("edi.996.1.xml")

# test it on EDI portal, and upload
