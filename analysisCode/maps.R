rm(list = ls())

# List all packages needed for session
neededPackages = c("sf","dplyr","jsonlite") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

ParisBerlinURAU <- st_read("data/geo/admin/urbanAudit/ref-urau-2020-100k.geojson/URAU_RG_100K_2020_4326_CITIES.geojson") %>% filter (URAU_CODE == "FR001P1" | URAU_CODE == "DE001C1")
st_write(ParisBerlinURAU,"data/geo/admin/urbanAudit/ref-urau-2020-100k.geojson/URAU_RG_100K_2020_4326_CITIES_PARIS_BERLIN.geojson")

fmb <- fromJSON("C:/Users/kras/Downloads/berlin_projects.json")

fmbProjects <- fmb[[4]]
