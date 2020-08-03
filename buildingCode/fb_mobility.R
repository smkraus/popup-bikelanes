# Prepare Facebook Data

rm(list = ls())

# List all packages needed for session"foreign",
neededPackages = c("rjson","purrr","readr","sf","dplyr") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

gadmStates <- st_read("data/geo/admin/GADM1/gadm_states.shp") %>% 
  st_transform(crs = 5243)

load("data/counters/_meta/countersURAU.RData")
countersURAU <- countersURAU %>% st_transform(crs = 5243) %>% select(counter_id,counter_name,geometry)
countersGADM <- st_join(countersURAU,gadmStates) %>% select(counter_id,geometry,GID_1)
st_geometry(countersGADM) <- NULL
haven::write_dta(countersGADM,"data/counters/_meta/countersGADM.dta")


mobility <- read_tsv("data/movement/movement-range-2020-07-12.txt")
fbMobilityCounter <- inner_join(countersGADM,mobility,by=c("GID_1"="polygon_id")) %>% 
    rename(day=ds,mobility=all_day_bing_tiles_visited_relative_change,share_immobile=all_day_ratio_single_tile_users) %>% select(-country,-polygon_source,-polygon_name) %>%
    select(-GID_1)

haven::write_dta(fbMobilityCounter,"data/movement/fbMovementCounter.dta")
