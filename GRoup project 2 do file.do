clear
import delimited "C:\Users\Alex\Documents\Stata Folder\hate_crime.csv" 
drop adult_offender_count
drop juvenile_offender_count
drop total_offender_count
drop pub_agency_unit
drop agency_type_name
drop division_name
drop adult_victim_count
drop juvenile_victim_count
ren state_name state
drop victim_types
drop multiple_offense
drop multiple_bias
tempfile hateCrime
drop ori
drop pub_agency_name
drop offender_ethnicity
save `hateCrime'


import excel "C:\Users\Alex\Documents\Stata Folder\racePercentageByState.xls", sheet("racePercentageByState") firstrow clear
ren Location state
drop in 34
tempfile raceByState
save `raceByState'

import excel "C:\Users\Alex\Documents\Stata Folder\PopulationReport.xlsx", sheet("Sheet1") firstrow clear
drop in 1
ren Name state
tempfile statePop
save `statePop'


*Merge raceByState and statePop
use `raceByState', clear
merge 1:1 state using `statePop', nogen keep(3)
drop Pop1990
drop Pop2000
drop Pop2010
ren Pop2019 Population
drop Change201019
gen numOfWhite = WhiteofTotalPopulation * Population
gen numOfBlack = BlackofTotalPopulation * Population
gen numOfHispanic = HispanicofTotalPopulation * Population
gen numOfAsian = AsianofTotalPopulation* Population



*Prepare FBI crime data for analysis
use `hateCrime', clear
sort state
bysort offense_name: keep if _N >= 1000
bysort location_name: keep if _N >= 100
tabulate offense_name
tabulate location_name


*Drop observation if offender_race = unkown (Deletes 284 observations)
drop if offender_race == "Unknown"
destring data_year,replace
bysort region_name: keep if _N >= 100
encode region_name, gen(region_name_)
reg victim_count region_name_
graph twoway (scatter victim_count region_name_) (lfit victim_count region_name_), ytitle("Victim Count") xtitle("Region") xlabel(1 2 3 4, valuelabel)
tabulate region_name
reg victim_count region_name_
tabulate region_name_
graph twoway (scatter victim_count region_name_) (lfit victim_count region_name_), ytitle("Victim Count") xtitle("Region") xlabel(1 2 3 4, valuelabel)
drop if victim_count >= 80
twoway (lfit victim_count region_name_) (scatter victim_count region_name_), xlabel(1 2 3 4, valuelabel)
reg victim_count region_name_