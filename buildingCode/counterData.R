rm(list = ls())

# List all packages needed for session
neededPackages = c("xlsx","sf","RJSONIO","rjson","jsonlite","tidyjson","dplyr","readr") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

# counterJson <- tidyjson::read_json("data/counters/all_counter_details.json")
# counterJson <- stream_in(file("data/counters/all_counter_details.json"))
# counterJson <- fromJSON(readLines("data/counters/all_counter_details.json"), flatten = TRUE)$dokumentstatus
# counters <- readLines("data/counters/all_counter_details.json")
# counterJson <- tidyjson::read_json(counters)

# NUTS3 <- st_read("data/geo/admin/NUTS_RG_01M_2013_4326_LEVL_3.shp/NUTS_RG_01M_2013_4326_LEVL_3.shp",stringsAsFactors = FALSE)
# countersNUTS3SF <- st_join(countersSF,NUTS3,left = TRUE) 
# 
# st_write(countersNUTS3SF,"data/counters/countersNUTS3.geojson")
# st_geometry(countersNUTS3SF) <- NULL
# write.csv(countersNUTS3SF,"data/counters/countersNUTS3.csv")
# 
# parisCountersSF <- st_read("data/counters/comptage-velo-compteurs.geojson")
# parisCountersSF <- parisCounters
# st_geometry(countersNUTS3SF) <- NULL

counterPath <- "data/counters/eco_counter/"
counterFiles <- list.files(path=counterPath, pattern="*.json", full.names=FALSE, recursive=FALSE)

counterDFList <- list()

for (i in seq_along(counterFiles)) {
  filePath <- paste0(counterPath,counterFiles[i])
  counterDF <- fromJSON(filePath, flatten = TRUE)
  counterID <- gsub(".json","",counterFiles[i])
  counterDF$id <- counterID 
  if (is.data.frame(counterDF)) {
    counterDFList[[i]] <- counterDF
  }
}

countersAll <- do.call(rbind, counterDFList)

# counterDetails <- read_csv('data/counters/_meta/all_counter_details.csv',col_types = cols(
#   id = col_character())) %>% dplyr::select(-logo,-photos,-url,"total_count" = "count")

# counterDataCombined <- readRDS("data/counters/eco-counter/data_combined.rds") %>% dplyr::select(-logo,-photos,-url,-timestamps,"total_count" = "count","instruments" = "instruments;...1")

counterDataCombined <- readRDS("data/counters/eco-counter/data_combined.rds") %>% dplyr::select(-logo,-photos,-url,-timestamps,"total_count" = "count","instruments" = "instruments;...1")


countersAllDetails <- left_join(counterDataCombined,countersAll,by=c("counter_id" = "id"))
haven::write_dta(countersAllDetails,'data/counters/counterPanel.dta')

countersSF <- st_as_sf(counterDataCombined, coords = c('longitude', 'latitude'), crs=4326)
countersAllDetailsSF <- inner_join(countersAll,countersSF,by=c("id" = "counter_id"))
st_write(countersAllDetailsSF,'data/counters/counterPanel.geojson')

# parisOld <- read_csv("data/counters/paris_old/comptage-velo-donnees-sites-comptage.csv")


