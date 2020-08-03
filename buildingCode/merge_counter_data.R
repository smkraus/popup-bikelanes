library(jsonlite)
library(readr)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)

# Helper function for unnesting
na_if_null <- function(x){
  if(is_null(x)){
    return(NA)
  } else {
    return(x)
  }
}

# Read files
orgfiles = list.files("output/orgdetails", pattern="*.json", full.names = T)
timestampfiles = list.files("output/timestamps", pattern="*.json", full.names=T)
timestampids = str_sub(timestampfiles, 19, 27)

# Convert jsons to list of data frames
# Map variant
orgJson <- map_dfr(orgfiles, function(x) {
  y <- rbind(fromJSON(x)) %>%
    as_tibble %>% 
    mutate(url=map(url, ~na_if_null(.x)),
           count=map(count, ~na_if_null(.x)),
           photos=map(photos, ~na_if_null(.x))) %>% 
    unnest(id, name, url, count, periodStart, periodEnd, logo, keep_empty=T) %>%
    rename(counter_id=id, 
           counter_name = name) %>% 
    unnest_wider(coordinates) %>% 
    unnest_wider(organisation) %>% 
    rename(organisation_id = id, 
           organisation = name) %>% 
    unnest_wider(instruments, names_sep=";") %>% 
    unnest(photos, logo, keep_empty=T)
  return(y[1,])
  })


# Loop Variant (mostly for debugging)
l <- list()
for(i in 1:length(orgfiles)){
  print(i)
  y <- rbind(fromJSON(orgfiles[i])) %>%
    as_tibble %>%
    unnest(photos, keep_empty=T) %>% 
    unnest(instruments, keep_empty=T) %>% 
    mutate(url=map(url, ~na_if_null(.x)),
           count=map(count, ~na_if_null(.x)),
           photos=map(photos, ~na_if_null(.x)),
           instruments=map(instruments, ~na_if_null(.x))) %>% 
    unnest(id, name, url, count, periodStart, periodEnd, logo, photos, instruments, keep_empty=T) %>%
    rename(counter_id=id, 
           counter_name = name) %>% 
    unnest_wider(coordinates) %>% 
    unnest_wider(organisation) %>% 
    rename(organisation_id = id, 
           organisation = name) %>% 
    unnest_wider(instruments, names_sep=";") %>% 
    unnest(photos, logo, keep_empty=T)
    l[[i]] <- y[1,]
}

counter_details <- bind_rows(l)

write_rds(counter_details, "counter-details.rds")

timestampJson <- map2_dfr(timestampfiles, timestampids, function(x, y) {
  z <- rbind(fromJSON(x))
  z$counter_id <- y
  return(z)
})

timestampJson <- timestampJson %>% 
  nest(timestamps=c(day, count))

data_combined <- counter_details %>% 
  left_join(timestampJson, by="counter_id")
write_rds(data_combined, "data_combined.rds")
