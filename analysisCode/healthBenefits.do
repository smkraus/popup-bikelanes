cd "C:\Users\kras\Dropbox\_work\_papers\publ\"

// Base sample
* Use final sample? Use policies sample?
use "data\counters\baseCitiesURAU.dta", clear
drop if urau_code == "ES027C1"
keep urau_code urau_name
duplicates drop
save "data/transportStats/baseURAU.dta", replace

// SrV stats
import excel using "data/transportStats/UrbanAudit/urauSrV.xlsx", clear first
drop if mi(SrV_name)
save "data/transportStats/UrbanAudit/urauSrV.dta", replace

import excel using "data/transportStats/SrV/modalShareKM.xlsx", clear first
drop B F I J K L M

rename A SrV_name
rename ZuFuß pedKMDay
rename Fahrrad bikeKMDay
rename MIV motorKMDay
rename ÖV ptKMDay
rename Gesamt totalKMDay

merge 1:1 SrV_name using "data/transportStats/UrbanAudit/urauSrV.dta"
drop _merge
drop if mi(urau_code)

save "data/transportStats/SrV/modalShareKMUrau.dta", replace



//// Urban Audit stats
// Population
import excel using "data/population/urb_cpop1.xls", clear first sheet("Data")


local popYears B C D E F G H I J K
foreach var of varlist `popYears' {
	replace `var' = subinstr(`var',":","",.)
	destring `var', replace
}

rename K popRecent
local popYears B C D E F G H I J
foreach var of varlist `popYears' {
	replace popRecent = `var' if mi(popRecent)
}

drop if mi(popRecent)
rename CITIESTIME urau_name
keep urau_name popRecent

duplicates drop

bys urau_name: egen popRecentMin = min(popRecent)
keep urau_name popRecentMin

duplicates drop
save "data/population/urb_cpop1.dta", replace

// Modal split
import excel using "data/transportStats/UrbanAudit/urb_ctran.xls", clear first sheet("Data4")
local modalSplitYears B C D E F G H I J K

foreach var of varlist `modalSplitYears' {
	replace `var' = subinstr(`var',":","",.)
	destring `var', replace
}

egen bikeModalShare = rowmax(B C D E F G H I J K)

drop B C D E F G H I J K
rename CITIESTIME urau_name

drop if mi(urau_name)
drop if mi(bikeModalShare)

duplicates drop

merge 1:m urau_name using "data/transportStats/baseURAU.dta"
drop _merge

drop if mi(urau_name,urau_code)

merge 1:1 urau_code using "data/transportStats/SrV/modalShareKMUrau.dta"
drop _merge

replace urau_name = subinstr(urau_name,"City of ","",.)

merge 1:1 urau_name using "data/population/urb_cpop1.dta"
drop _merge

replace popRecentMin = 582378 if urau_code == "PL006C"
replace popRecentMin = 119098 if urau_code == "FI007C2"

drop if mi(urau_code)

reg bikeKMDay bikeModalShare popRecentMin
predict bikeKMDayHatMS

reg bikeKMDayHatMS popRecentMin
predict bikeKMDayHatPop

replace bikeKMDay = bikeKMDayHatMS if mi(bikeKMDay)
replace bikeKMDay = bikeKMDayHatPop if mi(bikeKMDay)

merge 1:1 urau_code using "data/policies/policiesUrauTotal.dta"
drop _merge
drop if inlist(implementedKMMax,.,0)

egen bikeKMDayMedian = median(bikeKMDay)
replace bikeKMDay = bikeKMDayMedian if mi(bikeKMDay)

g dailyAdditionalCyclingKMpp = bikeKMDay * 0.006 * implementedKMMax
g additionalCyclingNow = dailyAdditionalCyclingKMpp * popRecentMin * 90
g additionalCyclingYear = dailyAdditionalCyclingKMpp * popRecentMin * 365

g socialBenefitsNow = 0.62*additionalCyclingNow
g socialBenefitsYear = 0.62*additionalCyclingYear

replace urau_name = subinstr(urau_name,"City of ","",.)
replace urau_name = subinstr(urau_name,"M. ","",.)
replace urau_name = "București" if urau_name == "MUNICIPIUL BUCURESTI"

gcollapse (mean) dailyAdditionalCyclingKMpp (nansum) additionalCyclingNow additionalCyclingYear socialBenefitsNow socialBenefitsYear


