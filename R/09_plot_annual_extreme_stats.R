source("source/main.R")


# Read in the extreme‐event datasets
extreme_fluxnet <- readRDS(file.path(
  PROCESSED_PATH, "fluxnet_extreme_events_20000218_20221231.rds"
))
extreme_gleam <- readRDS(file.path(
  PROCESSED_PATH, "gleam_extreme_events_20000218_20221231.rds"
))

# Summarize annual counts of extreme events for each dataset
fluxnet_counts <- extreme_fluxnet[extreme == TRUE,
                                  .(n_extremes = .N),
                                  by = .(year = year(date))
][order(year)]
# Summarize annual counts of extreme events for each dataset
fluxnet_counts <- extreme_fluxnet[extreme == TRUE,
                                  .(n_extremes = .N),
                                  by = .(year = year(date))
][order(year)]
fluxnet_counts[, dataset := "FLUXNET"]

gleam_counts <- extreme_gleam[extreme == TRUE,
                              .(n_extremes = .N),
                              by = .(year = year(date))
][order(year)]
gleam_counts[, dataset := "GLEAM"]

# Combine for plotting
ts_counts <- rbindlist(list(fluxnet_counts, gleam_counts))

# Plot and save annual extreme‐event counts
p1 <- ggplot(ts_counts, aes(x = year, y = n_extremes, color = dataset)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = seq(min(ts_counts$year), max(ts_counts$year), by = 2)) +
  labs(
    title = "Global Annual Extreme Evaporation Events",
    x = "Year",
    y = "Number of Extreme Events",
    color = "Dataset"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title      = element_text(face = "bold", hjust = 0.5),
    legend.position = "top"
  )

ggsave(
  filename = file.path(RESULTS_PATH, "n_extreme_gleam_vs_fluxnet.png"),
  plot     = p1,
  width    = 10,
  height   = 6,
  dpi      = 600,
  bg       = "white"
)

# Compute mean annual sum of extreme‐event evaporation for FLUXNET
fluxnet_sum <- extreme_fluxnet[evap_event == TRUE,
                                    .(extreme_sum = sum(value, na.rm = TRUE)),
                                    by = .(year = year(date), grid_id)
]
fluxnet_sum <- fluxnet_sum[
  , .(mean_extreme_sum = mean(extreme_sum, na.rm = TRUE)),
  by = year
]
fluxnet_sum[, dataset := "FLUXNET"]

# Compute mean annual sum of extreme‐event evaporation for GLEAM
gleam_sum <- extreme_gleam[evap_event == TRUE,
                                         .(extreme_sum = sum(value, na.rm = TRUE)),
                                         by = .(year = year(date), grid_id)
]
gleam_sum <- gleam_sum[
  , .(mean_extreme_sum = mean(extreme_sum, na.rm = TRUE)),
  by = year
]
gleam_sum[, dataset := "GLEAM"]

# Combine datasets for sum plotting
ts_sums <- rbindlist(list(fluxnet_sum, gleam_sum))

# Plot and save mean annual evaporation sums during extreme events
p2 <- ggplot(ts_sums, aes(x = year, y = mean_extreme_sum, color = dataset)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = seq(min(ts_sums$year), max(ts_sums$year), by = 2)) +
  labs(
    title = "Annual Total Evaporation During Extreme Events",
    x = "Year",
    y = "Mean Total ET in Extreme Events (mm/year)",
    color = "Dataset"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title      = element_text(face = "bold", hjust = 0.5),
    legend.position = "top"
  )

ggsave(
  filename = file.path(RESULTS_PATH, "annual_extreme_et_sums.png"),
  plot     = p2,
  width    = 10,
  height   = 6,
  dpi      = 600,
  bg       = "white"
)
