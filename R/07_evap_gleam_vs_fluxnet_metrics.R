source("source/main.R")


evap_gleam <- readRDS(paste0(PROCESSED_PATH, "evap_gleam_1980_2023.rds"))
evap_fluxnet <- readRDS(paste0(PROCESSED_PATH, "evap_fluxnet_20000218_20221231.rds"))

#get range of evap_fluxnet and filter gleam 
date_range <- range(evap_fluxnet$date)

evap_gleam <- evap_gleam[
  date >= date_range[1] &
    date <= date_range[2]
]

#merge two evap datasets
evap_merged <- evap_gleam[
  evap_fluxnet,
  on      = .(lon, lat, date),  # columns to match
  nomatch = 0                    # drop non‐matches
]

# then rename
setnames(evap_merged,
         old = c("evap", "value"),
         new = c("sim",  "obs"))


# ensure date is IDate
evap_merged[, date := as.IDate(date)]

# 1) DAILY metrics per (lon,lat)
daily_metrics <- evap_merged[, .(
  rmse_daily = sqrt(mean((sim - obs)^2, na.rm = TRUE)),
  cc_daily = {
    sim_sd <- sd(sim, na.rm = TRUE)
    obs_sd <- sd(obs, na.rm = TRUE)
    if (.N < 2 || is.na(sim_sd) || is.na(obs_sd) || sim_sd == 0 || obs_sd == 0) {
      NA_real_
    } else {
      cor(sim, obs, use = "complete.obs")
    }
  }
), by = .(lon, lat)]

# monthly totals by lon/lat
evap_monthly <- evap_merged[
  , .(
    sim_monthly = sum(sim, na.rm=TRUE),
    obs_monthly = sum(obs, na.rm=TRUE)
  ),
  by = .(
    lon,
    lat,
    year  = format(date, "%Y"),
    month = format(date, "%m")
  )
]
saveRDS(evap_monthly, paste0(PROCESSED_PATH, "evap_monthly_200002_202212.rds"))

# Compute monthly metrics from evap_monthly
monthly_metrics <- evap_monthly[
  , .(
    rmse_monthly = sqrt(mean((sim - obs)^2, na.rm = TRUE)),
    cc_monthly = {
      sim_sd <- sd(sim, na.rm = TRUE)
      obs_sd <- sd(obs, na.rm = TRUE)
      if (.N < 2 || is.na(sim_sd) || is.na(obs_sd) || sim_sd == 0 || obs_sd == 0) {
        NA_real_
      } else {
        cor(sim, obs, use = "complete.obs")
      }
    }
  ),
  by = .(lon, lat)
]


# yearly totals by lon/lat
evap_yearly <- evap_merged[
  , .(
    sim = sum(sim, na.rm=TRUE),
    obs = sum(obs, na.rm=TRUE)
  ),
  by = .(
    lon,
    lat,
    year = format(date, "%Y")
  )
]

saveRDS(evap_yearly, paste0(PROCESSED_PATH, "evap_yearly_200002_202212.rds"))

# Compute yearly metrics from evap_yearly
yearly_metrics <- evap_yearly[
  , .(
    rmse_yearly = sqrt(mean((sim - obs)^2, na.rm = TRUE)),
    cc_yearly = {
      sim_sd <- sd(sim, na.rm = TRUE)
      obs_sd <- sd(obs, na.rm = TRUE)
      if (.N < 2 || is.na(sim_sd) || is.na(obs_sd) || sim_sd == 0 || obs_sd == 0) {
        NA_real_
      } else {
        cor(sim, obs, use = "complete.obs")
      }
    }
  ),
  by = .(lon, lat)
]

# Step 1: Merge daily and monthly metrics
metrics_1 <- merge(
  daily_metrics,
  monthly_metrics,
  by = c("lon", "lat"),
  all = TRUE
)

# Step 2: Merge the result with yearly metrics
final_metrics <- merge(
  metrics_1,
  yearly_metrics,
  by = c("lon", "lat"),
  all = TRUE
)


saveRDS(final_metrics, paste0(PROCESSED_PATH, "metrics_200002_202212.rds"))

