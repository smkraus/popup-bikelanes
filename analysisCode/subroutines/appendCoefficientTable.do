preserve
regsave, cmdline

keep if inlist(var,"implementedKM","treatedInd","1.postEvent#c.implementedKM")

g date = "$S_DATE"
g time = "$S_TIME"

g poisson = 1 if strpos(cmdline,"ppmlhdfe")
replace poisson = 0 if poisson != 1

g ols = 1 if strpos(cmdline,"reghdfe")
replace ols = 0 if ols != 1

g tobeTreated = 1 if strpos(cmdline,"tobeTreated == 1")
replace tobeTreated = 0 if tobeTreated != 1

g treatedControl = 1 if strpos(cmdline,"treated == 1") & tobeTreated != 1 & !strpos(cmdline,"treatedInd")
replace treatedControl = 0 if treatedControl != 1

g time_var_only = 1 if strpos(cmdline,"treatedInd")
replace time_var_only = 0 if time_var_only != 1

g event_study = 1 if var == "1.postEvent#c.implementedKM"
replace event_study = 0 if event_study != 1

if "$timingOnly" == "timingOnlyTRUE" {
	replace coef = coef/$implementedKMmean
	replace stderr = stderr/$implementedKMmean
}

g counter_fe = 1 if strpos(cmdline,"counter_id") & !strpos(cmdline,"counter_id_factor#week_year")
replace counter_fe = 0 if counter_fe != 1

g counter_week = 1 if strpos(cmdline,"counter_id_factor#week_year")
replace counter_week = 0 if counter_week != 1

g day_fe = 1 if strpos(cmdline,"day") & !strpos(cmdline,"country_code#day")
replace day_fe = 0 if day_fe != 1

g city_week_fe = 1 if strpos(cmdline,"urau_code_factor#week_year")
replace city_week_fe = 0 if city_week_fe != 1

g city_cWeek_fe = 1 if strpos(cmdline,"urau_code_factor#calendarWeek")
replace city_cWeek_fe = 0 if city_cWeek_fe != 1

g city_cMonth_fe = 1 if strpos(cmdline,"urau_code_factor#calendarMonth")
replace city_cMonth_fe = 0 if city_cMonth_fe != 1

g state_week_fe = 1 if strpos(cmdline,"GID_1_factor#week_year")
replace state_week_fe = 0 if state_week_fe != 1

g country_day_fe = 1 if strpos(cmdline,"country_code#day")
replace country_day_fe = 0 if country_day_fe != 1

g mobility_control = 1 if strpos(cmdline,"mobility")
replace mobility_control = 0 if mobility_control != 1

g temperature_control = 1 if strpos(cmdline,"x2m_temperature")
replace temperature_control = 0 if temperature_control != 1

g sunshine_control = 1 if strpos(cmdline,"uv_radiation")
replace sunshine_control = 0 if sunshine_control != 1

g wind_control = 1 if strpos(cmdline,"x10m_u_component_of_wind x10m_v_component_of_wind")
replace wind_control = 0 if wind_control != 1

g precipitation_control = 1 if strpos(cmdline,"total_precipitation")
replace precipitation_control = 0 if precipitation_control != 1

g num_counter_control = 1 if strpos(cmdline,"numCounters")
replace num_counter_control = 0 if num_counter_control != 1

g noOutliers = 1 if "$noOutliers" == "noOutliersTRUE"
replace noOutliers = 0 if noOutliers != 1

drop var N cmdline
rename stderr se

replace coef = (exp(coef)-1)*100
replace se = (exp(se)-1)*100

append using "outputs/specchart_coefficient_table.dta"
sort coef
save "outputs/specchart_coefficient_table.dta", replace
restore
