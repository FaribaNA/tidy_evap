
## Load source files

source("source/main.R")
# Read PDF
pdf_text_data <- pdf_text(paste0(RAW_PATH, "essd-2024-460.pdf"))

# Extract lines from relevant pages
lines_25 <- strsplit(pdf_text_data[25], "\n")[[1]]
lines_26 <- strsplit(pdf_text_data[26], "\n")[[1]]

# Remove empty and header lines
lines_25 <- lines_25[lines_25 != ""]
lines_26 <- lines_26[lines_26 != ""]
lines_26 <- lines_26[!grepl("Appendix|Site\\s+IGBP", lines_26)]

# Combine lines from both pages
all_lines <- c(lines_25, lines_26)

# Split lines into 8-column table, remove rows with too many blanks
split_lines <- str_split_fixed(trimws(all_lines), "\\s{2,}", 8)
split_lines <- split_lines[rowSums(split_lines == "") < 2, ]

# Convert to data.table
dt <- as.data.table(split_lines[-1, ])

# Assign column names
setnames(
  dt,
  c(
    "Site", "IGBP", "Latitude", "Longitude",
    "Start_year", "End_year", "Time_cover_after_2000", "Missing_ratio"
  )
)

# Keep only required columns
dt_sites <- dt[, .(site_id = Site, lat = as.numeric(Latitude), lon = as.numeric(Longitude))]

# Save site table
saveRDS(dt_sites, file = file.path(PROCESSED_PATH, "site_locations.rds"))

