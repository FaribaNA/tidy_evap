# ساخت نقشه GLEAM و FLUXNET با شمارش رخدادهای اکستریم
gleam_map <- final_gleam_evap[extreme == TRUE, .N, by = .(lon, lat)]
fluxnet_map <- final_fluxnet_evap[extreme == TRUE, .N, by = .(lon, lat)]

# ترکیب دو نقشه برای مقایسه
comp_map <- merge(
  gleam_map[, .(lon, lat, gleam_N = N)],
  fluxnet_map[, .(lon, lat, fluxnet_N = N)],
  by = c("lon", "lat"),
  all = TRUE
)

# محاسبه تفاوت
comp_map[, diff := gleam_N - fluxnet_N]

# بارگذاری نقشه خشکی‌ها
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
land <- ne_countries(scale = "medium", returnclass = "sf")

# نقشه نهایی با رنگ‌های معنادار و نقاط واضح
ggplot() +
  geom_sf(data = land, fill = "gray95", color = "gray80", size = 0.2) +  # پس‌زمینه خشکی
  geom_point(
    data = comp_map,
    aes(x = lon, y = lat, fill = diff),
    shape = 21, size = 4, color = "black", stroke = 0.3
  ) +
  scale_fill_gradient2(
    low = "#2166ac",    # آبی = FLUXNET بیشتر
    mid = "white", 
    high = "#b2182b",   # قرمز = GLEAM بیشتر
    midpoint = 0,
    name = expression(Delta~ExEvE~"(GLEAM - FLUXNET)")
  ) +
  coord_sf(expand = FALSE) +
  labs(
    title = "Difference in Extreme Evaporation Events",
    subtitle = "GLEAM minus FLUXNET",
    x = "Longitude", y = "Latitude"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 13),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold")
  )
