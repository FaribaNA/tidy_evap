# compare_extremes_map_plot.R: Difference in extreme events map

source("source/main.R")

# prepare data
gleam_map <- gleam_extremes[extreme == TRUE, .N, by = .(lon, lat)]
setnames(gleam_map, "N", "gleam_n")
fluxnet_map <- fluxnet_extremes[extreme == TRUE, .N, by = .(lon, lat)]
setnames(fluxnet_map, "N", "fluxnet_n")
comp_map <- merge(
  gleam_map, fluxnet_map,
  by  = c("lon", "lat"),
  all = TRUE
)
comp_map[is.na(gleam_n),    gleam_n := 0]
comp_map[is.na(fluxnet_n), fluxnet_n := 0]
comp_map[, diff := gleam_n - fluxnet_n]

# load world map
world <- map_data("world") %>%
  dplyr::filter(region != "Antarctica")

# plot
extreme_map <- ggplot() +
  geom_polygon(
    data    = world,
    aes(x = long, y = lat, group = group),
    fill    = "white",
    colour  = "black",
    size    = 0.2
  ) +
  geom_point(
    data        = comp_map,
    aes(x = lon, y = lat, fill = diff),
    inherit.aes = FALSE,
    shape       = 21,
    size        = 3,
    colour      = "black",
    stroke      = 0.2,
    alpha       = 0.8
  ) +
  scale_fill_gradient2(
    low      = "#2166ac",
    mid      = "white",
    high     = "#b2182b",
    midpoint = 0,
    name     = expression(Delta~ExEvE~"(GLEAM - FLUXNET)")
  ) +
  scale_x_continuous(
    name   = "Longitude (°)",
    breaks = seq(-180, 180, by = 60),
    labels = function(x) paste0(x, "°")
  ) +
  scale_y_continuous(
    name   = "Latitude (°)",
    breaks = seq(-90, 90, by = 30),
    labels = function(x) paste0(x, "°")
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(colour = "grey90"),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.background  = element_rect(fill = "white", colour = NA),
    plot.margin      = margin(10, 10, 10, 10),
    axis.title       = element_text(face = "bold"),
    plot.title       = element_text(hjust = 0.5, size = 14,
                                    face = "bold")
  ) +
  labs(title = "Difference in Extreme Evaporation Events")

# save the figure
ggsave(
  filename = file.path(RESULTS_PATH,
                       "extreme_evaporation_diff_map.png"),
  plot   = extreme_map,
  width  = 12,
  height = 8,
  dpi    = 300
)

