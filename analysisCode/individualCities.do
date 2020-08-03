cd "C:\Users\kras\Dropbox\_work\_papers\publ\"

use "data\counters\panelAll.dta", clear

keep if urau_name == "Berlin" | treated == 0
keep if inlist(year,2019,2020)

drop if counter_id == "100053586"

* reghdfe count,noabs residuals(countDemeaned)

* sum countDemeaned if urau_name == "Berlin", detail

g berlin = 1 if urau_name == "Berlin"
replace berlin = 0 if urau_name != "Berlin"

bys berlin week_year year: egen countDemeaned = mean(count)

keep berlin week_year year countDemeaned
duplicates drop

/* gcollapse countDemeaned,by(berlin week_year year) */

su countDemeaned if year == 2019 & berlin == 1, detail
su countDemeaned if year == 2020 & berlin == 1, detail

replace countDemeaned = countDemeaned/4343.045*100

keep if berlin == 1
tsset week_year

tsline countDemeaned,xsize(10) ytitle("Veränderung Radverkehr | Max 2019 = 100") ttitle("") tmticks(#10)

line countDemeaned week_year if berlin == 1, xsize(10) ytitle("Veränderung Radverkehr | Max 2019 = 100") xtitle("") xmticks(##10)
graph export "outputs/berlinTimeSeries.png"


bytwoway (line countDemeaned week_year), by(berlin) 


// Export to R

cd "C:\Users\kras\Dropbox\_work\_papers\publ\"
use "data\counters\panelAll.dta", clear

/* fasterxtile count_xtile = count,by(urau_name) nq(1000)
drop if inlist(count_xtile,1,1000)
 */
replace urau_name = subinstr(urau_name,"City of ","",.)
replace urau_name = subinstr(urau_name,"M. ","",.)

replace urau_name = "București" if urau_name == "MUNICIPIUL BUCURESTI"

drop if inlist(urau_name,"Camden","Hackney")

keep if inlist(year,2019,2020)

save "data\counters\countURAULines.dta",replace
