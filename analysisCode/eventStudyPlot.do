cd "C:\Users\kras\Dropbox\_work\_papers\publ\"

use "data\counters\panelAll.dta", clear
g event_t = month_year - 722
keep if inrange(event_t,-12,5)
recode event_t (3/5 = 3)
* recode event_t (-1000/-10 = -10)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* ppmlhdfe count treated##ib1.event_t_factor, abs(counter_id country_code#day) cluster(urau_code)

ppmlhdfe count treated##ib4.event_t_factor, abs(urau_code country#day) cluster(urau_code)

regsave, ci level(95) 						

g year_t = .

keep if ///
var == "1.treated#1.event_t_factor" | ///
var == "1.treated#2.event_t_factor" | ///
var == "1.treated#3.event_t_factor" | ///
var == "1.treated#5.event_t_factor" | ///
var == "1.treated#6.event_t_factor" | ///
var == "1.treated#7.event_t_factor" | ///
var == "1.treated#8.event_t_factor" | ///
var == "1.treated#9.event_t_factor" | ///
var == "1.treated#10.event_t_factor" | ///
var == "1.treated#11.event_t_factor" | ///
var == "1.treated#12.event_t_factor" | ///
var == "1.treated#13.event_t_factor" | ///
var == "1.treated#14.event_t_factor" | ///
var == "1.treated#15.event_t_factor" | ///
var == "1.treated#16.event_t_factor"

replace year_t = -1 if var == "1.treated#1.event_t_factor"
replace year_t = -10 if var == "1.treated#2.event_t_factor"
replace year_t = -11 if var == "1.treated#3.event_t_factor"
replace year_t = -2 if var == "1.treated#5.event_t_factor"
replace year_t = -3 if var == "1.treated#6.event_t_factor"
replace year_t = -4 if var == "1.treated#7.event_t_factor"
replace year_t = -5 if var == "1.treated#8.event_t_factor"
replace year_t = -6 if var == "1.treated#9.event_t_factor"
replace year_t = -7 if var == "1.treated#10.event_t_factor"
replace year_t = -8 if var == "1.treated#11.event_t_factor"
replace year_t = -9 if var == "1.treated#12.event_t_factor"
replace year_t = 0 if var == "1.treated#13.event_t_factor"
replace year_t = 1 if var == "1.treated#14.event_t_factor"
replace year_t = 2 if var == "1.treated#15.event_t_factor"
replace year_t = 3 if var == "1.treated#16.event_t_factor"
								
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
xlabel(-11(1)3)




// 13 No pooling base category
use "data\counters\panelAll.dta", clear

fasterxtile count_tile = count,nq(100)
drop if inlist(count_tile,1,100)

g event_t = month_year - 722
keep if inrange(event_t,-13,3)
recode event_t (3/5 = 3)
* recode event_t (-1000/-13 = -13)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

g eventPost = 1 if inrange(event_t,0,.)
replace eventPost = 0 if event_t < 0 
ppmlhdfe count treated##eventPost, abs(counter_id country_code#day) cluster(urau_code)


ppmlhdfe count treated##ib5.event_t_factor, abs(urau_code country#day) cluster(urau_code)

regsave, ci level(95) 						

g year_t = .

keep if ///
var == "1.treated#1.event_t_factor" | ///
var == "1.treated#2.event_t_factor" | ///
var == "1.treated#3.event_t_factor" | ///
var == "1.treated#4.event_t_factor" | ///
var == "1.treated#6.event_t_factor" | ///
var == "1.treated#7.event_t_factor" | ///
var == "1.treated#8.event_t_factor" | ///
var == "1.treated#9.event_t_factor" | ///
var == "1.treated#10.event_t_factor" | ///
var == "1.treated#11.event_t_factor" | ///
var == "1.treated#12.event_t_factor" | ///
var == "1.treated#13.event_t_factor" | ///
var == "1.treated#14.event_t_factor" | ///
var == "1.treated#15.event_t_factor" | ///
var == "1.treated#16.event_t_factor" | ///
var == "1.treated#17.event_t_factor"


replace year_t = -1 if var == "1.treated#1.event_t_factor"
replace year_t = -10 if var == "1.treated#2.event_t_factor"
replace year_t = -11 if var == "1.treated#3.event_t_factor"
replace year_t = -12 if var == "1.treated#4.event_t_factor"
replace year_t = -2 if var == "1.treated#6.event_t_factor"
replace year_t = -3 if var == "1.treated#7.event_t_factor"
replace year_t = -4 if var == "1.treated#8.event_t_factor"
replace year_t = -5 if var == "1.treated#9.event_t_factor"
replace year_t = -6 if var == "1.treated#10.event_t_factor"
replace year_t = -7 if var == "1.treated#11.event_t_factor"
replace year_t = -8 if var == "1.treated#12.event_t_factor"
replace year_t = -9 if var == "1.treated#13.event_t_factor"
replace year_t = 0 if var == "1.treated#14.event_t_factor"
replace year_t = 1 if var == "1.treated#15.event_t_factor"
replace year_t = 2 if var == "1.treated#16.event_t_factor"
replace year_t = 3 if var == "1.treated#17.event_t_factor"
							
/* local new = _N + 1
	set obs `new'

replace year_t = -13 if mi(coef)
replace coef = 0 if year_t == -13
replace ci_lower = 0 if year_t == -1
replace ci_upper = 0 if year_t == -1 */

label var year_t "Months relative to begin of pop-up rollout"
label var coef "`chart_title' estimate"

sort year_t

set scheme plotplain
twoway ///
rarea ci* year_t, lcolor(white) lwidth(vvthin) color(gs12) fin(30) || ///
connected coef year_t, cmissing(y) lcolor(gray) lpattern(solid) lwidth(thick) yline(0, lcolor(black)) xline(-0.5, lcolor(black)) xsize(10) ytitle("Estimate") legend(off) aspect(0.5) ///
xlabel(-12(1)3)

graph export "outputs/eventStudyPlot.pdf",replace


// 13 Pooling base category
use "data\counters\panelAll.dta", clear

fasterxtile count_tile = count,nq(100)
drop if inlist(count_tile,1,100)

g event_t = month_year - 722
recode event_t (3/5 = 3)
recode event_t (-1000/-13 = -13)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* ppmlhdfe count treated##ib1.event_t_factor, abs(counter_id country_code#day) cluster(urau_code)

ppmlhdfe count treated##ib5.event_t_factor, abs(urau_code country#day) cluster(urau_code)

regsave, ci level(95) 						

g year_t = .

keep if ///
var == "1.treated#1.event_t_factor" | ///
var == "1.treated#2.event_t_factor" | ///
var == "1.treated#3.event_t_factor" | ///
var == "1.treated#4.event_t_factor" | ///
var == "1.treated#6.event_t_factor" | ///
var == "1.treated#7.event_t_factor" | ///
var == "1.treated#8.event_t_factor" | ///
var == "1.treated#9.event_t_factor" | ///
var == "1.treated#10.event_t_factor" | ///
var == "1.treated#11.event_t_factor" | ///
var == "1.treated#12.event_t_factor" | ///
var == "1.treated#13.event_t_factor" | ///
var == "1.treated#14.event_t_factor" | ///
var == "1.treated#15.event_t_factor" | ///
var == "1.treated#16.event_t_factor" | ///
var == "1.treated#17.event_t_factor"


replace year_t = -1 if var == "1.treated#1.event_t_factor"
replace year_t = -10 if var == "1.treated#2.event_t_factor"
replace year_t = -11 if var == "1.treated#3.event_t_factor"
replace year_t = -12 if var == "1.treated#4.event_t_factor"
replace year_t = -2 if var == "1.treated#6.event_t_factor"
replace year_t = -3 if var == "1.treated#7.event_t_factor"
replace year_t = -4 if var == "1.treated#8.event_t_factor"
replace year_t = -5 if var == "1.treated#9.event_t_factor"
replace year_t = -6 if var == "1.treated#10.event_t_factor"
replace year_t = -7 if var == "1.treated#11.event_t_factor"
replace year_t = -8 if var == "1.treated#12.event_t_factor"
replace year_t = -9 if var == "1.treated#13.event_t_factor"
replace year_t = 0 if var == "1.treated#14.event_t_factor"
replace year_t = 1 if var == "1.treated#15.event_t_factor"
replace year_t = 2 if var == "1.treated#16.event_t_factor"
replace year_t = 3 if var == "1.treated#17.event_t_factor"
							
/* local new = _N + 1
	set obs `new'

replace year_t = -13 if mi(coef)
replace coef = 0 if year_t == -13
replace ci_lower = 0 if year_t == -1
replace ci_upper = 0 if year_t == -1 */

label var year_t "Months relative to begin of popup rollout"
label var coef "`chart_title' estimate"

sort year_t

set scheme plotplain
twoway ///
rarea ci* year_t, lcolor(white) lwidth(vvthin) color(gs12) fin(30) || ///
connected coef year_t, cmissing(y) lcolor(gray) lpattern(solid) lwidth(thick) yline(0, lcolor(black)) xline(-0.5, lcolor(black)) xsize(10) ytitle("Estimate") legend(off) aspect(0.66) ///
xlabel(-12(1)3)




// 13 Treated no measures
use "data\counters\panelAll.dta", clear
g event_t = month_year - 722
keep if inrange(event_t,-13,5)
recode event_t (3/5 = 3)
* recode event_t (-1000/-13 = -13)
tostring event_t,g(event_t_str)
encode event_t_str,gen(event_t_factor)

* ppmlhdfe count treated##ib1.event_t_factor, abs(counter_id country_code#day) cluster(urau_code)

ppmlhdfe count treatedNoMeasures##ib5.event_t_factor, abs(urau_code country#day) cluster(urau_code)

regsave, ci level(95) 						

g year_t = .

keep if ///
var == "1.treatedNoMeasures#1.event_t_factor" | ///
var == "1.treatedNoMeasures#2.event_t_factor" | ///
var == "1.treatedNoMeasures#3.event_t_factor" | ///
var == "1.treatedNoMeasures#4.event_t_factor" | ///
var == "1.treatedNoMeasures#6.event_t_factor" | ///
var == "1.treatedNoMeasures#7.event_t_factor" | ///
var == "1.treatedNoMeasures#8.event_t_factor" | ///
var == "1.treatedNoMeasures#9.event_t_factor" | ///
var == "1.treatedNoMeasures#10.event_t_factor" | ///
var == "1.treatedNoMeasures#11.event_t_factor" | ///
var == "1.treatedNoMeasures#12.event_t_factor" | ///
var == "1.treatedNoMeasures#13.event_t_factor" | ///
var == "1.treatedNoMeasures#14.event_t_factor" | ///
var == "1.treatedNoMeasures#15.event_t_factor" | ///
var == "1.treatedNoMeasures#16.event_t_factor" | ///
var == "1.treatedNoMeasures#17.event_t_factor"


replace year_t = -1 if var == "1.treatedNoMeasures#1.event_t_factor"
replace year_t = -10 if var == "1.treatedNoMeasures#2.event_t_factor"
replace year_t = -11 if var == "1.treatedNoMeasures#3.event_t_factor"
replace year_t = -12 if var == "1.treatedNoMeasures#4.event_t_factor"
replace year_t = -2 if var == "1.treatedNoMeasures#6.event_t_factor"
replace year_t = -3 if var == "1.treatedNoMeasures#7.event_t_factor"
replace year_t = -4 if var == "1.treatedNoMeasures#8.event_t_factor"
replace year_t = -5 if var == "1.treatedNoMeasures#9.event_t_factor"
replace year_t = -6 if var == "1.treatedNoMeasures#10.event_t_factor"
replace year_t = -7 if var == "1.treatedNoMeasures#11.event_t_factor"
replace year_t = -8 if var == "1.treatedNoMeasures#12.event_t_factor"
replace year_t = -9 if var == "1.treatedNoMeasures#13.event_t_factor"
replace year_t = 0 if var == "1.treatedNoMeasures#14.event_t_factor"
replace year_t = 1 if var == "1.treatedNoMeasures#15.event_t_factor"
replace year_t = 2 if var == "1.treatedNoMeasures#16.event_t_factor"
replace year_t = 3 if var == "1.treatedNoMeasures#17.event_t_factor"
							
/* local new = _N + 1
	set obs `new'

replace year_t = -13 if mi(coef)
replace coef = 0 if year_t == -13
replace ci_lower = 0 if year_t == -1
replace ci_upper = 0 if year_t == -1 */

label var year_t "Months relative to begin of popup rollout"
label var coef "`chart_title' estimate"

sort year_t

set scheme plotplain
twoway ///
rarea ci* year_t, lcolor(white) lwidth(vvthin) color(gs12) fin(30) || ///
connected coef year_t, cmissing(y) lcolor(gray) lpattern(solid) lwidth(thick) yline(0, lcolor(black)) xline(-0.5, lcolor(black)) xsize(10) ytitle("Estimate") legend(off) aspect(0.66) ///
xlabel(-12(1)3)
