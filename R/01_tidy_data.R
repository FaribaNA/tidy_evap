# Tidy up hydroclimate variables 

## Load source files

source("source/main.R")

unzip(paste0(RAW_PATH,"prolonged_daily_2000-2022.zip"), exdir = RAW_PATH)

csv_files <- list.files(RAW_PATH, full.names = TRUE, pattern = ".csv")

## Reading all at once and create a single dt

all_data <- rbindlist(lapply(csv_files, function(file) {
  dt <- fread(file)
  dt[, SITE_ID := gsub("_daily_prolonged", "", tools::file_path_sans_ext(basename(file)))]
  return(dt)
}))

# Melting data
tidy_data <- melt(
  all_data,
  id.vars = c("TIMESTAMP", "SITE_ID"),  
  variable.name = "variable",           
  value.name = "value"                   
)

setnames(tidy_data, old= c("TIMESTAMP", "SITE_ID", "variable", "value"),
         new= c("timestamp", "site_id", "variable", "value"))

# save data 
saveRDS(tidy_data, paste0(PROCESSED_PATH,"tidy_data.rds"))

