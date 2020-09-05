cd "C:\Users\kras\Dropbox\_work\_papers\publ\"
use "data\counters\panelAll.dta", clear

global controls_daytime x2m_temperature_daytime uv_radiation_daytime x10m_u_component_of_wind_daytime x10m_v_component_of_wind_daytime
global controls x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation

ppmlhdfe count implementedKMpubl, abs(counter_id urau_code_factor#calendarWeek GID_1_factor#month_year) cluster(urau_code)

ppmlhdfe count implementedKM, cluster(urau_code)
ppmlhdfe count treatedInd, cluster(urau_code)

ppmlhdfe count implementedKM $controls mobility numCounters, abs(counter_id urau_code_factor#year GID_1_factor#month_year country_code#day) cluster(urau_code)

ppmlhdfe count treatedInd, abs(counter_id country_code#day) cluster(urau_code)

ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#year country_code#day) cluster(urau_code)

ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#year GID_1_factor#calendarMonth country_code#day) cluster(urau_code)

ppmlhdfe count implementedKM $controls mobility numCounters, abs(counter_id urau_code_factor#calendarWeek country_code#day) cluster(urau_code)


ppmlhdfe count implementedKM $controls mobility numCounters, abs(counter_id urau_code_factor#week_year country_code#day) cluster(urau_code)



ppmlhdfe count implementedKM $controls mobility numCounters, abs(counter_id urau_code_factor#calendarWeek) cluster(urau_code)



ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#year country_code#day) cluster(urau_code)
ppmlhdfe count implementedKM, abs(urau_code treated#calendarMonth country_code#day) cluster(urau_code)

ppmlhdfe count treatedInd, abs(counter urau_code_factor#calendarMonth country_code#day) cluster(urau_code)

ppmlhdfe count treatedInd, abs(urau_code country_code#day) cluster(urau_code)

ppmlhdfe count treatedInd, abs(urau_code treated#calendarMonth country_code#day) cluster(urau_code)
reghdfe count treatedInd, abs(urau_code treated#calendarMonth country_code#day) cluster(urau_code)

ppmlhdfe count implementedKM if inrange(year,2019,2020), abs(urau_code treated#calendarMonth country_code#day) cluster(urau_code)

ppmlhdfe count treatedInd if inrange(day,21950,.), abs(urau_code_factor country_code#day) cluster(urau_code)
ppmlhdfe count implementedKMpubl, abs(counter_id urau_code_factor#month country_code#day) cluster(urau_code)


ppmlhdfe count implementedKM $controls_daytime mobility numCounters if inrange(day,22000,.), abs(counter_id country_code#day) cluster(urau_code)


/* ppmlhdfe count implementedKM, abs(counter_id_factor#year country_code#day) cluster(urau_code)

ppmlhdfe count implementedKM if treated == 1, abs(urau_code country_code#week) cluster(urau_code)


ppmlhdfe count implementedKM, abs(counter_id_factor#year country_code#day) cluster(urau_code)

ppmlhdfe count implementedKM, abs(urau_code country_code#day) cluster(urau_code)
ppmlhdfe count implementedKM, abs(counter_id urau_code_factor#year country_code#day) cluster(urau_code)

ppmlhdfe count implementedMeasures, abs(counter_id country_code#day) cluster(urau_code)

ppmlhdfe count treatedInd, abs(counter_id country_code#day) cluster(urau_code) */


preserve
/* reghdfe count, absorb(counter_id_factor) res
rename _reghdfe_resid count_hat */

keep if inrange(year,2018,2020)

drop if year == 2020 & calendarMonth == 7

gcollapse (nansum) count,by(treated month_year)
bytwoway (line count month_year), by(treated)
* graph export "_outputs/charts/raw/line_treated`cT'_`dType'.png", replace
restore


preserve
keep if inrange(year,2016,2020)
keep if inrange(calendarMonth,1,6)
/* reghdfe count, noabs res
rename _reghdfe_resid count_hat */

* drop if count > 20000

gcollapse (mean) count,by(treated year)
bytwoway (line count year), by(treated)
* graph export "_outputs/charts/raw/line_treated`cT'_`dType'.png", replace
restore


use "data\counters\panelAll.dta", clear
g event_t = day - 21990

drop if year == 2020 & calendarMonth == 7

drop if event_t < -500
binsreg count event_t,line(3 3) cb(3 3) nbins(50) by(treated)

binscatter count event_t, absorb(calendarMonth)


use "data\counters\panelAll.dta", clear
g event_t = day - firstTreatDay

tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

g postEvent = 1 if inrange(event_t,0,.)
replace postEvent = 0 if event_t < 0 

replace event_t = -1 if treated == 0

ppmlhdfe count i.event_t_factor, abs(treated calendarMonth year) cluster(urau_code)


ppmlhdfe count postEvent, abs(counter_id urau_code_factor#week_year country_code#day) cluster(urau_code)

ppmlhdfe count c.implementedKM#postEvent $controls mobility numCounters, abs(counter_id day) cluster(urau_code)


use "data\counters\panelAll.dta", clear
g event_t = month_year - 722
* keep if inrange(year,2016,2020)
drop if event_t < -40

binsreg count event_t calendarMonth, nbins(10) by(treated)



use "data\counters\panelAll.dta", clear
g event_t = month_year - 722
keep if inrange(event_t,-10,5)
recode event_t (3/5 = 3)
* recode event_t (-1000/-10 = -10)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* ppmlhdfe count treated##ib1.event_t_factor, abs(counter_id country_code#day) cluster(urau_code)

ppmlhdfe count treated##ib2.event_t_factor, abs(urau_code country#day) cluster(urau_code)

regsave, ci level(95) 						

g year_t = .

keep if ///
	var == "1.treated#1.event_t_factor" 	| ///
	var == "1.treated#3.event_t_factor" 	| ///
	var == "1.treated#4.event_t_factor" 	| ///
	var == "1.treated#5.event_t_factor" 	| ///
	var == "1.treated#6.event_t_factor" 	| ///
	var == "1.treated#7.event_t_factor" 	| ///
	var == "1.treated#8.event_t_factor" 	| ///
	var == "1.treated#9.event_t_factor" 	| ///
	var == "1.treated#10.event_t_factor" 	| ///
	var == "1.treated#11.event_t_factor" 	| ///
	var == "1.treated#12.event_t_factor" 	| ///
	var == "1.treated#13.event_t_factor" 	| ///
	var == "1.treated#14.event_t_factor"


replace year_t = -1 if var == "1.treated#1.event_t_factor"
replace year_t = -2 if var == "1.treated#3.event_t_factor"
replace year_t = -3 if var == "1.treated#4.event_t_factor"
replace year_t = -4 if var == "1.treated#5.event_t_factor"
replace year_t = -5 if var == "1.treated#6.event_t_factor"
replace year_t = -6 if var == "1.treated#7.event_t_factor"
replace year_t = -7 if var == "1.treated#8.event_t_factor"
replace year_t = -8 if var == "1.treated#9.event_t_factor"
replace year_t = -9 if var == "1.treated#10.event_t_factor"
replace year_t = 0 if var == "1.treated#11.event_t_factor"
replace year_t = 1 if var == "1.treated#12.event_t_factor"
replace year_t = 2 if var == "1.treated#13.event_t_factor"
replace year_t = 3 if var == "1.treated#14.event_t_factor"
								
/* local new = _N + 1
	set obs `new'

replace year_t = -1 if mi(coef)
replace coef = 0 if year_t == -1
replace ci_lower = 0 if year_t == -1
replace ci_upper = 0 if year_t == -1 */

label var year_t "Months relative to begin of popup rollout"
label var coef "`chart_title' estimate"

sort year_t

set scheme plotplain
twoway ///
rarea ci* year_t, lcolor(white) lwidth(vvthin) color(gs12) fin(30) || ///
connected coef year_t, cmissing(y) lcolor(gray) lpattern(solid) lwidth(thick) yline(0, lcolor(black)) xline(-0.5, lcolor(black)) xsize(10) ytitle("Estimate") legend(off) aspect(0.66) ///
xlabel(-9(1)3)

* graph export "_outputs/charts/esplot_treated`cT'_`dType'_`feI'.pdf", replace

use "data\counters\panelAll.dta", clear
g event_t = month_year - 722
keep if inrange(event_t,-20,5)
recode event_t (3/5 = 3)
* recode event_t (-1000/-10 = -10)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

ppmlhdfe count treated##ib13.event_t_factor, abs(urau_code country#day) cluster(urau_code)

regsave, ci level(95) 						

g year_t = .

keep if ///
	var == "1.treated#1.event_t_factor" | ///
	var == "1.treated#2.event_t_factor" | ///
	var == "1.treated#3.event_t_factor" | ///
	var == "1.treated#4.event_t_factor" | ///
	var == "1.treated#5.event_t_factor" | ///
	var == "1.treated#6.event_t_factor" | ///
	var == "1.treated#7.event_t_factor" | ///
	var == "1.treated#8.event_t_factor" | ///
	var == "1.treated#9.event_t_factor" | ///
	var == "1.treated#10.event_t_factor" | ///
	var == "1.treated#11.event_t_factor" | ///
	var == "1.treated#12.event_t_factor" | ///
	var == "1.treated#14.event_t_factor" | ///
	var == "1.treated#15.event_t_factor" | ///
	var == "1.treated#16.event_t_factor" | ///
	var == "1.treated#17.event_t_factor" | ///
	var == "1.treated#18.event_t_factor" | ///
	var == "1.treated#19.event_t_factor" | ///
	var == "1.treated#20.event_t_factor" | ///
	var == "1.treated#21.event_t_factor" | ///
	var == "1.treated#22.event_t_factor" | ///
	var == "1.treated#23.event_t_factor" | ///
	var == "1.treated#24.event_t_factor"

replace year_t = -1 if var == "1.treated#1.event_t_factor"
replace year_t = -10 if var == "1.treated#2.event_t_factor"
replace year_t = -11 if var == "1.treated#3.event_t_factor"
replace year_t = -12 if var == "1.treated#4.event_t_factor"
replace year_t = -13 if var == "1.treated#5.event_t_factor"
replace year_t = -14 if var == "1.treated#6.event_t_factor"
replace year_t = -15 if var == "1.treated#7.event_t_factor"
replace year_t = -16 if var == "1.treated#8.event_t_factor"
replace year_t = -17 if var == "1.treated#9.event_t_factor"
replace year_t = -18 if var == "1.treated#10.event_t_factor"
replace year_t = -19 if var == "1.treated#11.event_t_factor"
replace year_t = -2 if var == "1.treated#12.event_t_factor"
replace year_t = -3 if var == "1.treated#14.event_t_factor"
replace year_t = -4 if var == "1.treated#15.event_t_factor"
replace year_t = -5 if var == "1.treated#16.event_t_factor"
replace year_t = -6 if var == "1.treated#17.event_t_factor"
replace year_t = -7 if var == "1.treated#18.event_t_factor"
replace year_t = -8 if var == "1.treated#19.event_t_factor"
replace year_t = -9 if var == "1.treated#20.event_t_factor"
replace year_t = 0 if var == "1.treated#21.event_t_factor"
replace year_t = 1 if var == "1.treated#22.event_t_factor"
replace year_t = 2 if var == "1.treated#23.event_t_factor"
replace year_t = 3 if var == "1.treated#24.event_t_factor"
								
local new = _N + 1
	set obs `new'

replace year_t = -1 if mi(coef)
replace coef = 0 if year_t == -1
replace ci_lower = 0 if year_t == -1
replace ci_upper = 0 if year_t == -1

label var year_t "Months relative to begin of popup rollout"
label var coef "`chart_title' estimate"

sort year_t

set scheme plotplain
twoway ///
rarea ci* year_t, lcolor(white) lwidth(vvthin) color(gs12) fin(30) || ///
connected coef year_t, cmissing(y) lcolor(gray) lpattern(solid) lwidth(thick) yline(0, lcolor(black)) xline(-0.5, lcolor(black)) xsize(10) ytitle("Estimate") legend(off) aspect(0.66) ///
xlabel(-19(1)3)

* graph export "_outputs/charts/esplot_treated`cT'_`dType'_`feI'.pdf", replace





/* gcollapse (nansum) count (mean) treatedInd implementedKM treated,by(month_year counter_id urau_code)
encode counter_id,g(counter_id_factor)
encode urau_code,g(urau_code_factor)
xtset counter_id_factor month_year

replace treatedInd = 1 if treatedInd > 0 & !mi(treatedInd)

reghdfe count F(1/4).implementedKM L(0/4).implementedKM, noabs cluster(urau_code) */

* keep if inrange(year,2019,2020)
use "data\counters\panelAll.dta", clear
gcollapse (mean) count treatedInd implementedKM treated $controls mobility year firstTreatWeek firstTreatMonth calendarMonth,by(month_year urau_code counter_id)

encode counter_id,g(counter_id_factor)
encode urau_code,g(urau_code_factor)
xtset counter_id_factor month_year

g cCode = substr(urau_code,1,2)
encode cCode,gen(country_code)

replace treatedInd = 1 if treatedInd > 0 & !mi(treatedInd)



g event_t = month_year - 

* keep if inrange(calendarMonth,1,7)

replace event_t = -5 if treated == 0
recode event_t (-1000/-5 = -5)

tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* keep if inrange(calendarMonth,1,7)

g postEvent = 1 if inrange(event_t,0,.)
replace postEvent = 0 if event_t < 0 

keep if inrange(event_t,-36,5)

ppmlhdfe count ib5.event_t_factor $controls mobility, abs(treated calendarMonth country_code#month_year) cluster(urau_code)


ppmlhdfe count postEvent, abs(urau_code calendarMonth) cluster(urau_code)


/* use "data\counters\panelAll.dta", clear
gcollapse (mean) count treatedInd implementedKM treated $controls_daytime mobility year firstTreatWeek calendarWeek,by(week_year urau_code counter_id)

encode counter_id,g(counter_id_factor)
encode urau_code,g(urau_code_factor)
xtset counter_id_factor week_year

g cCode = substr(urau_code,1,2)
encode cCode,gen(country_code)

replace treatedInd = 1 if treatedInd > 0 & !mi(treatedInd)

g event_t = week_year - firstTreatWeek

* keep if inrange(calendarMonth,1,7)

replace event_t = -1 if treated == 0
recode event_t (-1000/-15 = -15)



tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* keep if inrange(calendarMonth,1,7)

g postEvent = 1 if inrange(event_t,0,.)
replace postEvent = 0 if event_t < 0 

ppmlhdfe count i.event_t_factor, abs(counter_id calendarWeek year) cluster(urau_code)

ppmlhdfe count postEvent, abs(urau_code calendarMonth) cluster(urau_code) */




/* use "data\counters\panelAll.dta", clear
gcollapse (mean) count treatedInd implementedKM treated $controls_daytime mobility year firstTreatQuarter calendarQuarter,by(quarter_year urau_code counter_id)

encode counter_id,g(counter_id_factor)
encode urau_code,g(urau_code_factor)
xtset counter_id_factor quarter_year

g cCode = substr(urau_code,1,2)
encode cCode,gen(country_code)

replace treatedInd = 1 if treatedInd > 0 & !mi(treatedInd)

g event_t = quarter_year - firstTreatQuarter

* keep if inrange(calendarMonth,1,7)

replace event_t = -1 if treated == 0
recode event_t (-1000/-10 = -10)

tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* keep if inrange(calendarMonth,1,7)

g postEvent = 1 if inrange(event_t,0,.)
replace postEvent = 0 if event_t < 0 

ppmlhdfe count i.event_t_factor, abs(counter_id quarter_year year) cluster(urau_code)

ppmlhdfe count postEvent, abs(urau_code calendarQuarter) cluster(urau_code)
 */



/* use "data\counters\panelAll.dta", clear

gcollapse (mean) count treatedInd implementedKM treated $controls_daytime mobility firstTreatWeek firstTreatMonth calendarMonth,by(year urau_code counter_id)

encode counter_id,g(counter_id_factor)
encode urau_code,g(urau_code_factor)
xtset counter_id_factor year

g cCode = substr(urau_code,1,2)
encode cCode,gen(country_code)

replace treatedInd = 1 if treatedInd > 0 & !mi(treatedInd)

g event_t = year - 2020



replace event_t = -1 if treated == 0
recode event_t (-1000/-5 = -5)

tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* keep if inrange(calendarMonth,1,7)

g postEvent = 1 if inrange(event_t,0,.)
replace postEvent = 0 if event_t < 0 

ppmlhdfe count i.event_t_factor, abs(counter_id treated year) cluster(urau_code)
ppmlhdfe count postEvent, abs(urau_code calendarMonth) cluster(urau_code) */

