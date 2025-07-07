source("source/main.R")

#load metric data

metrics <- readRDS(paste0(PROCESSED_PATH, "metrics_200002_202212.rds"))


# load
metrics <- readRDS(paste0(PROCESSED_PATH, "metrics_200002_202212.rds"))
world   <- ne_countries(scale="medium", returnclass="sf")


# 1) Compute min & 95th‐percentile for each metric
lims <- metrics %>% summarise(
  rmse_daily   = list(c(min(rmse_daily,   na.rm=TRUE), quantile(rmse_daily,   .95, na.rm=TRUE))),
  rmse_monthly = list(c(min(rmse_monthly, na.rm=TRUE), quantile(rmse_monthly, .95, na.rm=TRUE))),
  rmse_yearly  = list(c(min(rmse_yearly,  na.rm=TRUE), quantile(rmse_yearly,  .95, na.rm=TRUE))),
  cc_daily     = list(c(min(cc_daily,     na.rm=TRUE), quantile(cc_daily,     .95, na.rm=TRUE))),
  cc_monthly   = list(c(min(cc_monthly,   na.rm=TRUE), quantile(cc_monthly,   .95, na.rm=TRUE))),
  cc_yearly    = list(c(min(cc_yearly,    na.rm=TRUE), quantile(cc_yearly,    .95, na.rm=TRUE)))
)

# 2) Individual plots:

p1 <- ggplot() +
  geom_sf(data = world, fill = "white", color = "lightgray", size = 0.05) +
  geom_point(aes(lon, lat, color = rmse_daily), data = metrics, size = 1.5) +
  scale_color_distiller(
    palette    = "RdBu",
    direction  = -1,
    name       = "RMSE (Daily)",
    limits     = lims$rmse_daily[[1]],
    oob        = squish,
    na.value   = "grey80"
  ) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude", y = "Latitude")+
  theme_minimal() +
  theme(
    plot.margin = unit(c(2, 2, 2, 2), "mm"),  # top, right, bottom, left
    panel.grid  = element_blank())

p2 <- ggplot() +
  geom_sf(data = world, fill = "white", color = "lightgray", size = 0.05) +
  geom_point(aes(lon, lat, color = rmse_monthly), data = metrics, size = 1.5) +
  scale_color_distiller(
    palette    = "RdBu",
    direction  = -1,
    name       = "RMSE (Monthly)",
    limits     = lims$rmse_monthly[[1]],
    oob        = squish,
    na.value   = "grey80"
  ) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude", y = "Latitude")+
  theme_minimal() +
  theme(
    plot.margin = unit(c(2, 2, 2, 2), "mm"),  # top, right, bottom, left
    panel.grid  = element_blank())

p3 <- ggplot() +
  geom_sf(data = world, fill = "white", color = "lightgray", size = 0.05) +
  geom_point(aes(lon, lat, color = rmse_yearly), data = metrics, size = 1.5) +
  scale_color_distiller(
    palette    = "RdBu",
    direction  = -1,
    name       = "RMSE (Yearly)",
    limits     = lims$rmse_yearly[[1]],
    oob        = squish,
    na.value   = "grey80"
  ) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude", y = "Latitude")+
  theme_minimal() +
  theme(
    plot.margin = unit(c(2, 2, 2, 2), "mm"),  # top, right, bottom, left
    panel.grid  = element_blank())

p4 <- ggplot() +
  geom_sf(data = world, fill = "white", color = "lightgray", size = 0.05) +
  geom_point(aes(lon, lat, color = cc_daily), data = metrics, size = 1.5) +
  scale_color_distiller(
    palette    = "RdBu",
    direction  = 1,
    name       = "Corr (Daily)",
    limits     = lims$cc_daily[[1]],
    oob        = squish,
    na.value   = "grey80"
  ) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude", y = "Latitude")+
  theme_minimal() +
  theme(
    plot.margin = unit(c(2, 2, 2, 2), "mm"),  # top, right, bottom, left
    panel.grid  = element_blank())

p5 <- ggplot() +
  geom_sf(data = world, fill = "white", color = "lightgray", size = 0.05) +
  geom_point(aes(lon, lat, color = cc_monthly), data = metrics, size = 1.5) +
  scale_color_distiller(
    palette    = "RdBu",
    direction  = 1,
    name       = "Corr (Monthly)",
    limits     = lims$cc_monthly[[1]],
    oob        = squish,
    na.value   = "grey80"
  ) +
  labs(x = "Longitude", y = "Latitude")+
  coord_sf(expand = FALSE) +
  theme_minimal() +
  theme(
    plot.margin = unit(c(2, 2, 2, 2), "mm"),  # top, right, bottom, left
    panel.grid  = element_blank())
 

p6 <- ggplot() +
  geom_sf(data = world, fill = "white", color = "lightgray", size = 0.05) +
  geom_point(aes(lon, lat, color = cc_yearly), data = metrics, size = 1.5) +
  scale_color_distiller(
    palette    = "RdBu",
    direction  = 1,
    name       = "Corr (Yearly)",
    limits     = lims$cc_yearly[[1]],
    oob        = squish,
    na.value   = "grey80"
  ) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude", y = "Latitude")+
  theme_minimal() +
  theme(
    plot.margin = unit(c(2, 2, 2, 2), "mm"),  # top, right, bottom, left
    panel.grid  = element_blank())


final_plots <- ggarrange(
  # first column: p1, p2, p3
  # second column: p5, p4, p6
  p1, p5,
  p2, p4,
  p3, p6,
  ncol          = 2,
  nrow          = 3,
  align         = "hv",
  widths        = rep(1, 2),
  heights       = rep(1, 3)
)
ggsave(
  filename = file.path(RESULTS_PATH,
                       "metric_map.png"),
  plot   = final_plots,
  width  = 12,
  height = 8,
  dpi    = 600,
  units = "in", bg="white"
)
