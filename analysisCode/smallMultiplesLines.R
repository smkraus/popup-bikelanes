rm(list = ls())

# List all packages needed for session
neededPackages = c("ggplot2","dplyr","haven","ggthemes","tidyverse","lubridate","scales") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

counts <- haven::read_dta("data/counters/countURAULines.dta")

countsTreatedWeek <- counts %>% filter(treated == 1) %>% group_by(urau_name,week = floor_date(day,"1 week")) %>% summarise(count = mean(count)) 
countsUntreatedWeek <- counts %>% filter(treated != 1) %>% group_by(urau_name,week = floor_date(day,"1 week")) %>% summarise(count = mean(count)) 

treated <- ggplot(countsTreatedWeek,aes(x = week, y=count, group = 1)) +
  geom_line() +
  facet_wrap(. ~ urau_name,ncol=5) + 
  theme_tufte() +
  scale_x_date(date_breaks = "6 month", date_labels =  "%b %Y") + 
  theme(text = element_text(family = "Arial")) + 
  xlab("") + ylab("Weekly average bike count")

ggsave("outputs/smallMultiplesCountTreated.png", treated, width=12.5,height=13.5, units="in")

untreated <- ggplot(countsUntreatedWeek,aes(x = week, y=count, group = 1)) +
  geom_line() +
  facet_wrap(. ~ urau_name,ncol = 6)+
  theme_tufte() +
  scale_x_date(date_breaks = "6 month", date_labels =  "%b %Y") + 
  theme(text = element_text(family = "Arial")) + 
  xlab("") + ylab("Weekly average bike count") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 3))

ggsave("outputs/smallMultiplesCountUntreated.png", untreated, width=12.5,height=15.5, units="in")

