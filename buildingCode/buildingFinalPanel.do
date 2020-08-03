cd "C:\Users\kras\Dropbox\_work\_papers\publ\"

use "data/policies/baseCities.dta", clear
g day = mdy(01, 01, 2019)
format day %d

encode city,g(city_factor)
drop city
tsset city_factor day
tsappend, add(1000)

decode city_factor, g(city)
drop city_factor

save "data/policies/baseCitiesLong.dta",replace


use "data/policies/policiesInfra.dta", clear
replace measure_amount = "0.7" if measure_amount == "0,7"
replace measure_amount = "0.6" if measure_amount == "0,6"

gen byte notnumeric = real(measure_amount)==. /*makes indicator for obs w/o numeric values*/
tab notnumeric /*==1 where nonnumeric characters*/
list measure_amount if notnumeric==1 /*will show which have nonnumeric*/

destring measure_amount, replace

drop if mi(city)

replace measure_amount = . if measure_unit != "km"

preserve
drop if mi(date_of_implementation)
g numMeasuresImplemented = 1 if !mi(date_of_implementation)
gcollapse (nansum) measure_amount numMeasuresImplemented,by(city date_of_implementation)

rename measure_amount kmOnDay
rename date_of_implementation day 

merge 1:1 city day using "data/policies/baseCitiesLong.dta"
drop if _merge == 1
drop _merge

sort city day

bys city (day): g implementedKM = sum(kmOnDay)
bys city (day): g implementedMeasures = sum(numMeasuresImplemented)

drop kmOnDay numMeasuresImplemented
save "data/policies/implementedKMall.dta", replace
restore

preserve
drop if mi(date_of_implementation)
replace measure_amount = . if measure_type != "cycle lanes/tracks"
g numMeasuresImplemented = 1 if !mi(date_of_implementation)
gcollapse (nansum) measure_amount numMeasuresImplemented,by(city date_of_implementation)

rename measure_amount kmOnDay
rename date_of_implementation day 

merge 1:1 city day using "data/policies/baseCitiesLong.dta"
drop if _merge == 1
drop _merge

sort city day

bys city (day): g implementedKMpubl = sum(kmOnDay)
bys city (day): g implementedMeasurespubl = sum(numMeasuresImplemented)

drop kmOnDay numMeasuresImplemented
save "data/policies/implementedKMpubl.dta", replace
restore


preserve
drop if mi(date_of_announcement) | !mi(date_of_implementation) | status_1 != "announced"
gcollapse (nansum) measure_amount,by(city)

g announcedOnlyAny = 1

drop measure_amount

save "data/policies/announcedOnlyAny.dta", replace
restore


use "data\counters\baseCitiesURAU.dta", clear
drop if urau_code == "ES027C1"
* replace city = "Bilbao" if urau_code == "ES019C1"

merge 1:m city using "data/policies/implementedKMall.dta"
drop if _merge == 2
drop _merge

* Saving for heatmap

merge 1:1 city day using "data/policies/implementedKMpubl.dta"
drop if _merge == 2
drop _merge


merge m:1 city using "data/policies/announcedOnlyAny.dta"
drop if _merge == 2
drop _merge

gcollapse (nansum) implementedKM implementedMeasures implementedKMpubl implementedMeasurespubl (max) announcedOnlyAny, by(urau_code day)

merge 1:m urau_code day using "data/counters/timestampsURAU.dta"
drop _merge

preserve
keep if inrange(day,21975,22104)
bys urau_code: egen implementedKMMax = max(implementedKM)
g counterAny = 1 if !mi(counter_id)
gcollapse (mean) implementedKMMax counterAny,by(urau_code)
save "data/policies/policiesUrauTotal.dta",replace
restore

g cCode = substr(urau_code,1,2)
encode cCode,gen(country_code)

drop if mi(counter_id)
preserve
keep if inrange(day,21975,22104)
keep cCode implementedKM urau_code urau_name day
duplicates drop
gen year = year(day)
replace urau_name = subinstr(urau_name,"City of ","",.)
save "data/policies/policiesUrauHeatmap.dta",replace
restore


drop if counter_id == "100041252"

// Greenwich has half counts
drop if counter_id == "100034645"

// London does not have adequate coverage
drop if inlist(urau_name,"Camden","Hackney")


// Dropping counters with high values from tourism or organized bike events
/* fasterxtile count_tile = count,nq(100)
drop if inlist(count_tile,1,100) */
* drop if count > 20000

replace implementedKM = 0 if mi(implementedKM) & mi(implementedMeasures)
replace implementedMeasures = 0 if implementedKM == 0 & mi(implementedMeasures)


replace implementedKMpubl = 0 if implementedKM == 0 & implementedMeasures == 0
replace implementedMeasurespubl = 0 if implementedKM == 0 & implementedMeasures == 0



merge m:1 urau_code day using "data/weather/weatherURAU.dta"
drop if _merge == 2
drop _merge

merge m:1 counter_id using "data/counters/_meta/countersGADM.dta"
drop if _merge == 2
drop _merge

merge 1:1 counter_id day using "data/movement/fbMovementCounter.dta"
drop if _merge == 2
drop _merge




bys urau_code: egen treatedKM = max(implementedKM)
bys urau_code: egen treatedMeasures = max(implementedMeasures)


g treatedNoMeasures = 1 if (treatedKM > 0 & !mi(treatedKM))
replace treatedNoMeasures = 0 if treatedKM == 0

g treated = 1 if (treatedKM > 0 & !mi(treatedKM)) | (treatedMeasures > 0 & !mi(treatedMeasures))
replace treated = 0 if treatedKM == 0 & treatedMeasures == 0

/* g treated = 1 if (treatedKM > 0 & !mi(treatedKM))
replace treated = 0 if treatedKM == 0 & treatedMeasures == 0 */

g tobeTreated = 1 if treated == 0 & announcedOnlyAny == 1

bys counter_id (day): egen firstTreatDayKM = min(cond(implementedKM != 0,day, .))
format firstTreatDayKM %d

bys counter_id (day): egen firstTreatDayMeasures = min(cond(implementedMeasures != 0,day, .))
format firstTreatDayMeasures %d

g firstTreatDay = min(firstTreatDayKM,firstTreatDayMeasures)
format firstTreatDay %d

g firstTreatWeek = wofd(firstTreatDay)
format firstTreatWeek %tw

g firstTreatMonth = mofd(firstTreatDay)
format firstTreatMonth %tm

g firstTreatQuarter = qofd(firstTreatDay)
format firstTreatQuarter %tq

g treatPost = 1 if inrange(day,firstTreatDay,.)
replace treatPost = 0 if day < firstTreatDay

g treatedInd = treated*treatPost

encode urau_code,g(urau_code_factor)
encode counter_id,g(counter_id_factor)

encode GID_1,gen(GID_1_factor)

xtset counter_id_factor day

gen year = year(day)
gen calendarWeek = week(day)
gen calendarMonth = month(day)
gen calendarQuarter = quarter(day)

gen day_raw = day

gen int week_year = wofd(day)
format week_year %tw

gen int month_year = mofd(day)
format month_year %tm

gen int month_year_raw = mofd(day)

gen int quarter_year = qofd(day)
format quarter_year %tq

bys urau_code day: egen numCounters = count(counter_id)

save "data\counters\panelAll.dta", replace 
