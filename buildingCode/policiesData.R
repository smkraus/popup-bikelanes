rm(list = ls())

# List all packages needed for session
neededPackages = c("xlsx","sf","tidyr","dplyr","eeptools","janitor","lubridate") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

policiesInfra <- read.xlsx("data/policies/ECF_Cycling_Beyond_COVID19-20200708.xlsx",2,encoding="UTF-8")
policiesInfra <- policiesInfra %>% 
  mutate(City=replace(City, City=="Barcelona metropolitan area","Barcelona")) %>%
  select(-Country,-e.mail,-name,-position,-organisation,-Measure.description,-Sources,-Announcement,-Implementation,-Removal,-to.add.to.cities) %>%
  select(-NA.,-NA..1,-NA..2,-NA..3,-NA..4,-NA..5,-NA..6,-NA..7,-NA..8,-NA..9,-NA..10) %>%
  clean_names()
haven::write_dta(policiesInfra, "data/policies/policiesInfra.dta")


# policiesOther <- read.xlsx("data/policies/ECF_Cycling_Beyond_COVID19-20200708.xlsx",3,encoding="UTF-8")

baseCities <- read.xlsx("data/policies/ECF_Cycling_Beyond_COVID19-20200708.xlsx",7,encoding="UTF-8") 
baseCities <- baseCities %>%
  dplyr::select(City,lat.long) %>%
  dplyr::filter(!is.na(lat.long)) %>%
  tidyr::separate(lat.long, c("lat", "lon"),sep=",")

# Changing coordinates
# policiesCities <- policiesCities %>% 
#   mutate(lat=replace(lat, City=="Barcelona metropolitan area","41.3579970446532")) %>% 
#   mutate(lon=replace(lon, City=="Barcelona metropolitan area","41.3579970446532")) %>% 

baseCitiesSF <- baseCities %>% st_as_sf(coords = c('lon', 'lat'), crs=4326)

baseCities_dta <- baseCitiesSF %>% clean_names() %>% select(city)

st_geometry(baseCities_dta) <- NULL
haven::write_dta(baseCities_dta, "data/policies/baseCities.dta")


citiesURAU <- st_read("data/geo/admin/urbanAudit/ref-urau-2020-100k.geojson/URAU_RG_100K_2020_4326_CITIES.geojson")
isid(citiesURAU,"URAU_CODE", verbose = FALSE)
citiesURAU <- citiesURAU %>%
  select(URAU_CODE,URAU_NAME,AREA_SQM,geometry)
citiesURAU_dta <- citiesURAU
st_geometry(citiesURAU_dta) <- NULL
haven::write_dta(citiesURAU_dta,"data/geo/admin/urbanAudit/citiesURAU.dta")


baseCitiesURAU <- st_join(citiesURAU,baseCitiesSF,left=FALSE) %>% clean_names() %>% select(-area_sqm)
baseCitiesURAU_dta <- baseCitiesURAU
st_geometry(baseCitiesURAU_dta) <- NULL
haven::write_dta(baseCitiesURAU_dta, "data/counters/baseCitiesURAU.dta")

counters <- haven::read_dta("data/counters/_meta/counter-details.dta") %>%
  dplyr::select(-logo,-photos,-url,"total_count" = "count") %>%
  st_as_sf(coords = c('longitude', 'latitude'), crs=4326)

countersURAU <- st_join(counters,citiesURAU,left=FALSE) %>% clean_names()
save(countersURAU, file = "data/counters/_meta/countersURAU.RData")

# citiesURAUCounters <- st_join(counters,citiesSFURAU,left=FALSE) %>% clean_names()
# save(citiesURAUCounters, file = "data/counters/citiesURAUCounters.RData")
# load("data/counters/citiesURAUCounters.RData")
# st_geometry(citiesURAUCounters) <- NULL
# haven::write_dta(citiesURAUCounters, "data/counters/citiesURAUCounters.dta")

# Merge by city and day here
# policiesInfraURAU <- left_join(citiesURAUCounters,policiesInfra,by = c("city"="city"))
# policiesInfraURAU <- policiesInfraURAU %>% 
#   select(-organisation,-counter_name,-period_start,-period_end,-instruments,-country) %>%
#   select(counter_id,urau_code,area_sqm,measure_type,status_1,status_2,measure_unit,measure_amount,date_of_announcement,date_of_implementation,date_of_removal)

# policiesInraURAUnarrow <- policiesInfraURAU %>% select(City,URAU_NAME,geometry) %>% filter(is.na(URAU_NAME))
# haven::write_dta(policiesInfraURAU, "data/counterPolicies.dta")

counts <- haven::read_dta("data/counters/timestamps.dta") %>% filter(day != 1)
counts <- counts %>% mutate(day=ydm(day))
countersGeo <- counters %>% select(counter_id,geometry)

countsGeo <- inner_join(countersGeo,counts,by="counter_id")

countsURAU <- st_join(countsGeo,citiesURAU,left=FALSE) %>% clean_names()
st_geometry(countsURAU) <- NULL
haven::write_dta(countsURAU,"data/counters/timestampsURAU.dta")




