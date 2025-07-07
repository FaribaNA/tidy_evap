# GLEAM
gleam_example <- gleam_evap_extreme_filtered[
  grid_id == 17 & date >= as.Date("2006-04-01") & date <= as.Date("2006-09-30")
]

# FLUXNET
fluxnet_example <- fluxnet_evap_extreme[
  grid_id == 17 & date >= as.Date("2006-04-01") & date <= as.Date("2006-09-30")
]
p_gleam <- plot_exeve(
  gleam_example,
  exeve_pal = c("#4D648D", "#337BAE", "#a9cce0"),
  title = "Extreme Evaporation Events - Summer 2006 (GLEAM - Grid 17)",
  shapes = c(0, 16, 15)
)
p_fluxnet <- plot_exeve(
  fluxnet_example,
  exeve_pal = c("#4D648D", "#337BAE", "#a9cce0"),
  title = "Extreme Evaporation Events - Summer 2006 (FLUXNET - Grid 17)",
  shapes = c(0, 16, 15)
)
(p_gleam | p_fluxnet) +
  plot_annotation(
    title = "Comparison of Extreme Evaporation Events: GLEAM vs FLUXNET (Grid 17)",
    theme = theme(plot.title = element_text(size = 14, face = "bold"))
  )
ggsave("gleam_fluxnet_exeve_comparison_grid17.png", width = 14, height = 6, dpi = 300)
