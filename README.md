[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![DOI](https://zenodo.org/badge/284724283.svg)](https://zenodo.org/badge/latestdoi/284724283)


# Effect of pop-up bike lanes on cycling in European cities
This repository contains code and data necessary to replicate the findings of [Kraus and Koch (2020)](https://smkraus.github.io/files/kk_popup-bikelanes.pdf). The paper investigates the effects of pop-up bike lanes in European cities rolled out during the COVID-19 pandemic.

## Dependencies
Dependencies in R are installed directly within the respective scripts. Stata dependencies can be installed with:

`ssc install ppmlhdfe`

`ssc install gtools`

## Data
The final panel for the replication of our results can be found at `data/counters/panelAll.dta`

Raw data is from municipal bike counter APIs, which we access either directly through cities' Open Data Portals or using the [Eco-Counter-Client](https://github.com/derhuerst/eco-counter-client), and the European Cyclists' Federation's [COVID 19 Measures Tracker](https://datastudio.google.com/u/0/reporting/ba90a08c-9841-4beb-9e26-7d4f7d002709/page/yMRTB).


