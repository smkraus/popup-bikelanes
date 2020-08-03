cd "C:\Users\kras\Dropbox\_work\_papers\publ\"

use "data\counters\panelAll.dta", clear

est clear
global controls x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation

local treatmentVars implementedKM implementedKMpubl implementedMeasures treatedInd

fasterxtile count_tile = count,nq(100)
drop if inlist(count_tile,1,100)

foreach var of varlist `treatmentVars' {
	rename `var' treatment
	eststo: ppmlhdfe count treatment $controls mobility numCounters, abs(counter_id urau_code_factor#week_year country_code#day) cluster(urau_code)
/* 	estadd local mobility Y	"FB Mobility = mobility" ///
	estadd local numCounters Y 
	estadd local temperature Y 
	estadd local sunshine Y 
	estadd local wind Y 
	estadd local total_precipitation Y */
	rename treatment `var'
}


/* estfe est*, /// 
	labels(counter_id "Counter FE" day "Day FE" )

global indicate_fe "`r(indicate_fe)'" */

esttab est* using "outputs/mainTable.tex", replace ///
		keep(treatment) ///
		varl(treatment "Pop-up treatment") ///
		se ///
		nonotes ///
		booktabs compress gaps ///
		mgroups( ///
			"Outcome: Cyclist count", ///
			pattern(1 0 0 0) ///
			prefix(\multicolumn{@span}{c}{) suffix(})   ///
			span erepeat(\cmidrule(lr){@span})) ///
		mtitles( ///
			"\shortstack{All km}" ///
			"\shortstack{Bike lane km}" ///
			"\shortstack{Num of measures}" ///
			"\shortstack{Any treatment}" ///
			) ///
		b(3) se(3) alignment(S) ///
		stats(N_clust N,label("City clusters" "N") layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") fmt(%5.0f)) ///
		star(* 0.10 ** 0.05 *** 0.01)


/* 		indicate( ///
			"FB Mobility = mobility" ///
			"Number of counters = numCounters" ///
			"Temperature = x2m_temperature" ///
			"Sunshine = uv_radiation" ///
			"Wind = x10m_v_component_of_wind" ///
			"Precipitation = total_precipitation" ///
			) ///

		scalars( ///
			"Number of counters numCounters" ///
			"Temperature temperature" ///
			"Sunshine sunshine" ///
			"Wind wind" ///
			"Precipitation total_precipitation") /// */
