## Load source files

source("source/main.R")
# Load site table
dt_sites <- readRDS(paste0(PROCESSED_PATH, "site_locations.rds"))

# Load world map and exclude Antarctica
world_map <- map_data("world")
world_map <- world_map[world_map$region != "Antarctica", ]

# Plot map with site locations
p <- ggplot() +
  geom_polygon(
    data = world_map,
    aes(x = long, y = lat, group = group),
    fill = "white", color = "black", size = 0.2
  ) +
  geom_point(
    data = dt_sites,
    aes(x = lon, y = lat),
    color = "red", size = 1, alpha = 0.9
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(10, 10, 10, 10),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
  ) +
  labs(title = "FLUXNET sites")

# Save plot
ggsave(filename = paste0(RESULTS_PATH, "site_map.png"), plot = p,
       width = 8, height = 5, dpi = 300)

