rm(list = ls())

# List all packages needed for session
neededPackages = c("xlsx","sf","tidyr","dplyr","eeptools","janitor","ggthemes","ggplot2","viridis","extrafont") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

policiesUrau <- haven::read_dta("data/policies/policiesUrauHeatmap.dta") %>%
  arrange(cCode,implementedKM,day) %>%
  mutate(implementedKM=replace(implementedKM,implementedKM == 0,NA))

# DF for plotting
pUrau <- policiesUrau %>% 
  group_by(cCode) %>% 
  mutate(urau_name=as.character(urau_name)) %>%
  arrange(day) 

# %>%
#   filter(!is.na(implementedKM))

pUrau$urau_fac <- factor(pUrau$urau_name, levels=c(unique(pUrau$urau_name)))

my_breaks <- c(0, 0.01, 0.1, 1, 10, 80)
Sys.setlocale("LC_ALL", "English")

cityLabels <- c("Manchester","Dublin","Helsinki","London","Budapest", "Paris", "Berlin","Wien","Basel","Bilbao","Nantes","München","Karlsruhe")

gControls <- ggplot(pUrau, aes(day,urau_fac, fill= implementedKM)) + 
  geom_tile() +
  scale_fill_viridis(name = "km",option="magma", trans = scales::pseudo_log_trans(sigma = 0.001),
                     direction = -1,na.value = "white", breaks=my_breaks) +
  facet_grid(cCode ~ .,switch = "y", scales = "free_y", space = "free_y") +
  theme_tufte() + 
  theme(text = element_text(family = "Arial"),strip.text.y = element_text(size = 7),axis.line.y=element_line(),axis.title.x = element_blank(),axis.title.y = element_blank()) +
  scale_y_discrete(breaks = unique(pUrau$urau_fac[pUrau$urau_fac %in% cityLabels]))
# Sys.setlocale("LC_ALL", "German")

ggsave("outputs/policyHeatmapControls.png", gControls, width=5.5,height=12.5, units="in")

pUrauTreated <- pUrau %>%
  filter(!is.na(implementedKM))

g <- ggplot(pUrauTreated, aes(day,urau_fac, fill= implementedKM)) + 
  geom_tile() +
  scale_fill_viridis(name = "km",option="magma", trans = scales::pseudo_log_trans(sigma = 0.001),
                     direction = -1,na.value = "white", breaks=my_breaks) +
  facet_grid(cCode ~ .,switch = "y", scales = "free_y", space = "free_y") +
  theme_tufte() + 
  theme(text = element_text(family = "Arial"),strip.text.y = element_text(size = 8),axis.line.y=element_line(),axis.title.x = element_blank(),axis.title.y = element_blank())

ggsave("outputs/policyHeatmap.png", g, width=5.5,height=5.5, units="in")
