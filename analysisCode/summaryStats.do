cd "C:\Users\kras\Dropbox\_work\_papers\publ\"
use "data\counters\panelAll.dta", clear

fasterxtile count_tile = count,nq(100)
drop if inlist(count_tile,1,100)

g area_ha = area_sqm/10000

* global controls x2m_temperature uv_radiation x10m_u_component_of_wind x10m_v_component_of_wind total_precipitation

label var count "Daily number of cyclists"
label var area_ha "City size (ha)" 
label var year "Year"
label var numCounters "Number of counters in the same city"
label var mobility "Facebook mobility index"

eststo clear
eststo: quietly estpost summarize count area_ha year numCounters mobility, detail

esttab using "outputs/sumStatsCounters.tex", replace booktabs cells("mean(fmt(a2 a2 0 a2) label(Mean)) sd(fmt(a2 a2 0 a2) label(Std.\ Dev.)) p25(fmt(a2 a2 0 a2) label(25\%)) p50(fmt(a2 a2 0 a2) label(50\%)) p75(fmt(a2 a2 0 a2) label(75\%)) p95(fmt(a2 a2 0 a2) label(95\%)) min(fmt(a2 a2 0 a2) label(Min.)) max(fmt(a2 a2 0 a2) label(Max.))") label nonumbers nomtitles nonote 







eststo clear
keep if treatedInd == 1
gcollapse (max) implementedKM implementedKMpubl implementedMeasures,by(urau_code)

replace implementedKM = . if implementedKM == 0

label var implementedKM "Total length of bike infrastructures"
label var implementedKMpubl "Total lenght of bike lanes"
label var implementedMeasures "Number of measures"

eststo clear
eststo: quietly estpost summarize implementedKM implementedKMpubl implementedMeasures, detail

esttab using "outputs/sumStatsPolicies.tex", replace booktabs cells("mean(fmt(a2) label(Mean)) sd(fmt(a2) label(Std.\ Dev.)) p25(fmt(a2) label(25\%)) p50(fmt(a2) label(50\%)) p75(fmt(a2) label(75\%)) p95(fmt(a2) label(95\%)) max(fmt(a2) label(Max.))") label nonumbers nomtitles nonote 


esttab using "analysis/output/tables/plants_summary.tex", booktabs drop("Total:") ///
		label cells("mean(fmt(a2) label(Mean)) p50(fmt(a2) label(Median)) sd(fmt(a2) label(Std.\ Dev.))") ///
		unstack noobs nomtitles nonumbers nonote replace ///
		refcat(tfp6co22l_mlpr "\emph{Firm performance:}" workers_total_imp2 "\emph{Labor:}" input_ct "\emph{Inputs:}" output_ct "\emph{Product portfolio:}", nolabel)


eststo clear
eststo: quietly estpost tab 

esttab using "outputs/sumStatsPolicyTypes.tex", replace booktabs label nonumbers nomtitles nonote 
