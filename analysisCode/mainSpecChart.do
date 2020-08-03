cd "C:\Users\kras\Dropbox\_work\_papers\publ\"

clear
g date = "$S_DATE"
g time = "$S_TIME"
save "outputs/specchart_coefficient_table.dta", replace

use "data\counters\panelAll.dta", clear

global appendTable "do "analysisCode/subroutines/appendCoefficientTable.do""

sum implementedKM if implementedKM != 0
return list
global implementedKMmean = r(mean)

/* // Not Dropping outliers
global noOutliers "noOutliersTRUE"
ppmlhdfe count implementedKM, abs(counter_id day) cluster(urau_code)
$appendTable
global noOutliers */

fasterxtile count_tile = count,nq(100)
drop if inlist(count_tile,1,100)

// No controls
ppmlhdfe count implementedKM, cluster(urau_code)
$appendTable

// Baseline TWFE
ppmlhdfe count implementedKM, abs(counter_id day) cluster(urau_code)
$appendTable

// Baseline TWFE with controls
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id day) cluster(urau_code)
$appendTable

// Calendar week
* ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation numCounters, abs(counter_id urau_code_factor#calendarWeek) cluster(urau_code)
ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#calendarWeek country_code#day) cluster(urau_code)
$appendTable

// Calendar week
ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#calendarWeek) cluster(urau_code)
$appendTable

/* // Calendar month coutry-day
ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#calendarMonth country#day) cluster(urau_code)
$appendTable

// Calendar month
ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#calendarMonth) cluster(urau_code)
$appendTable
 */
// Treated only
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters if treated == 1, abs(counter_id day) cluster(urau_code)
$appendTable

// Treated and to be treated only
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters if treated == 1 | tobeTreated == 1, abs(counter_id day) cluster(urau_code)
$appendTable

// Treated only, variation in timing only
global timingOnly "timingOnlyTRUE"
ppmlhdfe count treatedInd x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters if treated == 1, abs(counter_id day) cluster(urau_code)
$appendTable
global timingOnly

// Country-level confounders
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id country_code#day) cluster(urau_code)
$appendTable

/* // State-level confounders
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id GID_1_factor#week_year day) cluster(urau_code)
$appendTable */

// City-level estimate
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id urau_code_factor#week_year day) cluster(urau_code)
$appendTable

// Counter-level estimate
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id_factor#week_year day) cluster(urau_code)
$appendTable

// Max controls
ppmlhdfe count implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id urau_code_factor#week_year country_code#day) cluster(urau_code)
$appendTable

// Normal OLS
g lcount = ln(count)
reghdfe lcount implementedKM x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id day) cluster(urau_code)
$appendTable

// Event study
g event_t = day - firstTreatDay

tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

g postEvent = 1 if inrange(event_t,0,.)
replace postEvent = 0 if event_t < 0 

replace event_t = -1 if treated == 0
ppmlhdfe count c.implementedKM#postEvent x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation mobility numCounters, abs(counter_id day) cluster(urau_code)
$appendTable

/* // Hard coding treatment in March
use "data\counters\panelAll.dta", clear

g event_t = month_year - 722
* keep if inrange(event_t,-13,3)
* recode event_t (3/5 = 3)
* recode event_t (-1000/-13 = -13)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

g eventPost = 1 if inrange(event_t,0,.)
replace eventPost = 0 if event_t < 0 
ppmlhdfe count treated##eventPost, abs(counter_id country_code#day) cluster(urau_code)
ppmlhdfe count treated##eventPost, abs(urau_code country_code#day) cluster(urau_code) */

