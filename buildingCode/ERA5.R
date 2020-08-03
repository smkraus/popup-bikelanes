rm(list = ls())

# List all packages needed for session
neededPackages = c("ecmwfr","raster","rlist", "sf", "exactextractr", "geojsonsf", "purrr", "dplyr","janitor") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

# Enter your user ID. Get User ID and API key registering at CDS
user_id <- "45297"
API_key <- "1805c77e-cfc3-44d5-8fbf-c295e61298d0"
local_storage <- "C:/Users/kras/Downloads/era5/"

# set a key to the keychain
wf_set_key(user = user_id,
           key = API_key,
           service = "cds")

# Alternatively you can input your login info with an interactive request
#wf_set_key(service = "cds")


variables <- c('10m_u_component_of_wind', '10m_u_component_of_wind_daytime', 
               '10m_v_component_of_wind', '10m_v_component_of_wind_daytime',
               '2m_temperature', '2m_temperature_daytime', 
               'downward_uv_radiation_at_the_surface', 'downward_uv_radiation_at_the_surface_daytime')
var_list <- list('10m_u_component_of_wind' = list(),
                 '10m_u_component_of_wind_daytime' = list(),
                 '10m_v_component_of_wind' = list(),
                 '10m_v_component_of_wind_daytime' = list(),
                 '2m_temperature' = list(),
                 '2m_temperature_daytime' = list(),
                 'downward_uv_radiation_at_the_surface' = list(),
                 'downward_uv_radiation_at_the_surface_daytime' = list()
                 )

# starting_date <- as.Date("2007/01/13")
starting_date <- as.Date("2019/09/27")
end_date <- as.Date("2019/12/31")

dates <- seq(starting_date,end_date,by="days")
urauAll <- st_read("data/geo/admin/urbanAudit/ref-urau-2020-100k.geojson/URAU_RG_100K_2020_4326_CITIES.geojson") %>% dplyr::select(URAU_CODE,URAU_NAME,geometry)

t1 <- Sys.time()
for(date in as.list(dates)){
  files_date <- c()
  print(date)
  for (i in 1:length(variables)){ 
    month <- format(date,"%m")
    year <- format(date,"%Y")
    day <- format(date, "%d")
    if(year == 2008) break
    var <- variables[i]
    file_on_disk <- paste0(variables[i],".nc") # paste0(year,month,day,variables[i],".nc")
    files_date <- c(files_date, paste0(local_storage, file_on_disk))
    if(!stringr::str_sub(var, -7, -1) == 'daytime'){
      request <- list(
        "product_type" = "reanalysis",
        "variable" = variables[i],
        "year" = year,
        "month" = month,
        "day" = day,
        "time" = c("00:00","01:00", "02:00", "03:00", "04:00", "05:00",
                   "06:00", "07:00", "08:00", "09:00", "10:00", 
                   "11:00", "12:00", "13:00", "14:00", "15:00",
                   "16:00", "17:00", "18:00", "19:00", "20:00", 
                   "21:00", "22:00", "23:00"),
        "format" = "netcdf",
        "dataset_short_name" = "reanalysis-era5-single-levels",
        "target" = file_on_disk)
    } else {
      request <- list(
        "product_type" = "reanalysis",
        "variable" = stringr::str_sub(variables[i], 1, -9),
        "year" = year,
        "month" = month,
        "day" = day,
        "time" = c("06:00", "07:00", "08:00", "09:00", "10:00", 
                   "11:00", "12:00", "13:00", "14:00", "15:00",
                   "16:00", "17:00", "18:00", "19:00", "20:00", 
                   "21:00", "22:00"),
        "format" = "netcdf",
        "dataset_short_name" = "reanalysis-era5-single-levels",
        "target" = file_on_disk)
    }
    file <- wf_request( user = user_id,   # user ID (for authentification)
                        request  = request,  # the request
                        transfer = TRUE,     # download the file
                        path = local_storage)      # set download path
  }
  if(year == 2008) break
    r <- map(files_date, brick)
    reducedBricks <- map(r, ~ calc(.x, mean))
    reducedBricks_filenames <- paste0(files_date, ".tif")
    map2(reducedBricks, reducedBricks_filenames, ~ writeRaster(.x, .y, ".tif", format="GTiff", overwrite=T))
    var_list <- map2(var_list, 
                     map(reducedBricks_filenames, function(x){
                       urau_var <- urauAll
                       urau_var$varValue <- exact_extract(crop(raster(x), urauAll), urauAll, 'mean')
                       st_geometry(urau_var) <- NULL
                       urau_var$date <- date
                       return(urau_var)
                     }),
                     function(x, y){
                       rbind(x, y)
                     })
                   
  # r <- map(files_date, raster)
  # names(r) <- variables
  # var_list <- map2(var_list,
  #                  map2(var_list, r, function(x, y) {
  #                     varIDN <- crop(y, urauAll)
  #                     urau_var <- urauAll
  #                     urau_var["value_daily"] <- exact_extract(varIDN, urau_var, 'mean')
  #                     st_geometry(urau_var) <- NULL
  #                     urau_var$date <- date
  #                     return(urau_var)
  #                     }),
  #                  function(x, y){
  #                    rbind(x, y)
  #                  })
}
t2 <- Sys.time()
print(t2-t1)
saveRDS(var_list, "data/weather/var_list2019_6.rds")

first <- var_list2019_5[[1]]

precipDF <- `var_list_until_2020-07-09` %>% select(URAU_CODE,day=date,total_precipitation)

for (i in 1:length(var_list_2020)) {
  varName <- quo_name(names(var_list_2020)[i])
  var_list_2020[[i]] <- var_list_2020[[i]] %>% select(URAU_CODE,date,varValue) %>% rename(!!varName := varValue)
  # baseERA5 <- inner_join(baseERA5,varDF,by=c("URAU_CODE","date"))
}

weatherURAU <- reduce(var_list_2020, full_join, by = c('URAU_CODE',"date")) %>% rename("day" = "date") %>% 
  rename(uv_radiation = downward_uv_radiation_at_the_surface) %>%
  rename(uv_radiation_daytime = downward_uv_radiation_at_the_surface_daytime)

weatherURAU <- left_join(precipDF,weatherURAU,by = c('URAU_CODE',"day")) %>% clean_names()

haven::write_dta(weatherURAU,"data/weather/weatherURAU.dta")
#tempDF <- var_list_2020[["2m_temperature"]] %>% rename("2m_temperature" = varValue)



### OLD
# u_compOfWind <- var_list$`10m_u_component_of_wind` %>% 
#   rename(`10m_u_component_of_wind_daily` = value_daily)
# v_compOfWind <- var_list$`10m_v_component_of_wind` %>% 
#   rename(`10m_v_component_of_wind_daily` = value_daily)
# temperature <- var_list$`2m_temperature` %>% 
#   rename(`2m_temperature_daily` = value_daily)
# radiation <- var_list$downward_uv_radiation_at_the_surface %>% 
#   rename(downward_uv_radiation_at_the_surface_daily = value_daily)
# temperature_daytime <- var_list$`2m_temperature_daytime` %>% 
#   rename(`2m_temperature_daytime_daily` = value_daily)
# full <- left_join(u_compOfWind, v_compOfWind, temperature, radiation, temperature_daytime, by=c("URAU_NAME", "date"), )
