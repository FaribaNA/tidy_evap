## extract_evap_data.R: Download and extract GLEAM evaporation data at site locations

# Source main script for library imports and path definitions
source("source/main.R")

# Download GLEAM v4.1a daily evaporation data (variable 'e')
download_data(
  data_name = "gleam-v4-1a",
  path      = file.path(RAW_DATA_PATH, "gleam"),
  domain    = "land",
  time_res  = "daily",
  variable  = "e"
)

# Read site locations
sites <- readRDS(file.path(PROCESSED_PATH, "site_locations.rds"))

# Build file path to the downloaded NetCDF
nc_file <- list.files(
  path    = file.path(RAW_DATA_PATH, "gleam"),
  pattern = "gleam-v4-1a_e_.*\.nc$",
  full.names = TRUE
)

# Load the NetCDF as a RasterBrick
evap_brick <- raster::brick(nc_file)

# Extract evaporation values at site coordinates
evap_gleam <- raster::extract(
  evap_brick,
  cbind(x = sites$lon, y = sites$lat)
)

# make data tabular in lon, lat, date, value columns
evap_gleam <- as.data.table(evap_values)
evap_gleam <- cbind(sites$lon, sites$lat, evap_values)
setnames(evap_values, c("V1", "V2"), c("lon", "lat"))
evap_gleam_tidy <- as.data.table(melt(evap_values, id.vars = c("lon", "lat")))
setnames(evap_gleam_tidy, colnames(evap_gleam_tidy), c('lon','lat','date','evap'))
evap_gleam_tidy[, date := as.Date(date, format = "X%Y.%m.%d")]
gc(); rm(evap_values)
# Save tabular tidy data
saveRDS(evap_gleam_tidy, paste0(PROCESSED_PATH, "evap_gleam_1980_2023.rds"))

