# load libraries and paths
source("source/main.R")

# import and clean FLUXNET
fluxnet_raw <- readRDS(file.path(PROCESSED_PATH, "tidy_data.rds"))
fluxnet_raw[, site_id := gsub("_daily$", "", site_id)]
setnames(fluxnet_raw, "timestamp", "date")

fluxnet_le_ta <- fluxnet_raw[variable %in% c("LE", "TA")]
site_locations <- readRDS(file.path(PROCESSED_PATH,
                                    "site_locations.rds"))
fluxnet_le_ta <- merge(
  fluxnet_le_ta,
  site_locations,
  by    = "site_id",
  all.x = TRUE
)

# reshape and convert units
fluxnet_wide <- dcast(
  fluxnet_le_ta,
  lon + lat + date ~ variable,
  value.var = "value"
)
setnames(fluxnet_wide, c("TA", "LE"), c("tavg", "le"))
fluxnet_wide[, le := le * 0.0864]

saveRDS(
  fluxnet_wide,
  file.path(PROCESSED_PATH, "fluxnet_tidy_data.rds")
)

# compute evapotranspiration and detect extremes
fluxnet_et       <- le_2_et(x = fluxnet_wide)

saveRDS(
  fluxnet_et,
  file.path(PROCESSED_PATH, "evap_fluxnet_20000218_20221231.rds")
)
fluxnet_extremes <- detect_exeve(fluxnet_et)

# load GLEAM, align date range, detect extremes
gleam_evap <- readRDS(file.path(PROCESSED_PATH,
                                "evap_gleam_1980_2023.rds"))
setnames(gleam_evap, "evap", "value")

fluxnet_et[, date := as.Date(date)]
gleam_evap[, date := as.Date(date)]
date_range <- range(fluxnet_et$date)

gleam_evap <- gleam_evap[
  date >= date_range[1] &
    date <= date_range[2]
]
gleam_extremes <- detect_exeve(gleam_evap)

# assign grid IDs and merge coords for FLUXNET extremes
fluxnet_coords <- copy(fluxnet_et)[order(lon, lat)]
fluxnet_coords[, grid_id := .GRP, by = .(lon, lat)]
lookup_fluxnet <- unique(fluxnet_coords[, .(grid_id, lon, lat)])
fluxnet_extremes <- merge(
  fluxnet_extremes,
  lookup_fluxnet,
  by    = "grid_id",
  all.x = TRUE
)

# assign grid IDs and merge coords for GLEAM extremes
gleam_coords <- copy(gleam_evap)[order(lon, lat)]
gleam_coords[, grid_id := .GRP, by = .(lon, lat)]
lookup_gleam <- unique(gleam_coords[, .(grid_id, lon, lat)])
gleam_extremes <- merge(
  gleam_extremes,
  lookup_gleam,
  by    = "grid_id",
  all.x = TRUE
)

# save results
saveRDS(
  fluxnet_extremes,
  file.path(PROCESSED_PATH,
            "fluxnet_extreme_events_20000218_20221231.rds")
)
saveRDS(
  gleam_extremes,
  file.path(PROCESSED_PATH,
            "gleam_extreme_events_20000218_20221231.rds")
)
