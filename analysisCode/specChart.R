rm(list = ls())
# List all packages needed for session
neededPackages = c("haven","dplyr","readr") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

# Load specification chart function
source("dependencies/spec_chart_function.R")

coeffsPubl <- haven::read_dta("outputs/specchart_coefficient_table.dta") %>% dplyr::select(-date,-time,-r2,-noOutliers,-state_week_fe)
# coeffs <- read_csv("outputs/specchart_coefficient_table.csv") %>% select(-date,-time)

coeffsPubl <- as.data.frame(coeffsPubl)

labelsPubl <- list("Model:" = c("Poisson","OLS"),
               "Control group:" = c("To be treated","Treated only","Timing variation only","Event study"),
               "Fixed effects:" = c("Counter FE","Counter-week FE","Day FE","City-week FE","City-calendar week FE","Country-day FE"),
               "Control variables:" = c("Overall mobility","Temperature","Sunshine","Wind","Precipitation","Number of counters")
               )

# Looks better when there is an outer margins
par(oma=c(0.2,0,0.3,0.7))

# schart(coeffsPubl, labelsPubl, order="increasing",
#        heights=c(.6,1),
#        pch.dot=c(15,15,15,15),ci=c(0.9,.95),
#        cex=c(0.5,0.47),
#        highlight=c(3,10,13), 
#        col.est=c("grey80","royalblue"),
#        col.est2=c("grey90","lightblue"),
#        col.dot=c("grey60","grey95","grey95","royalblue"),
#        adj=c(0,0), offset=c(10.4,10.1),
#        leftmargin = 5.5,
#        ylab = "% change per km bikelane",
#        lwd.est = 2.8,
#        lwd.symbol = 1.5,
#        pch.est=20
#        )
# 
# dev.print(pdf, "outputs/publSpecs.pdf")


# Trying with transparency
schart(coeffsPubl, labelsPubl, order="increasing",
       heights=c(.6,1),
       pch.dot=c(15,15,15,15),ci=c(0.9,.95),
       cex=c(0.5,0.47),
       highlight=c(2,3), 
       col.est=c(rgb(0,0,0,0.1),rgb(0,0.2,0.6, 0.1)),
       col.est2=c(rgb(0,0,0,0.08),"lightblue"),
       col.dot=c(rgb(0,0,0,0.12),"grey95","grey95",rgb(0,0.4,0.6,0.3)),
       bg.dot=c(rgb(0,0,0,0.12),"grey95","grey95",rgb(0,0.4,0.6,0.3)),
       adj=c(0,0), offset=c(10.4,10.1),
       leftmargin = 5,
       ylab = "% change per km bikelane",
       lwd.est = 5.8,
       lwd.symbol = 0.1,
       pch.est=20
)

dev.print(pdf, "outputs/publSpecs.pdf")
