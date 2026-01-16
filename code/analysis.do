clear
capture log close
* Setting Working Directory
cd "/Users/abhishekbaraili/Documents/data/stata/NLFS_Mocrodata"

log using "abhishek_BECO414.log", replace



**Part A
*level of Education Data and Cleaning Data
use "S02_rc.dta",clear



*Identify the variable that contains information of level of education and remove observation with unreasonable values
*Removing the category of professional degree, literate(levelless) and illiterate
gen schoo_yrs = .
replace schoo_yrs = 0 if grade_comp == 0
replace schoo_yrs = 1 if grade_comp == 1
replace schoo_yrs = 2 if grade_comp == 2
replace schoo_yrs = 3 if grade_comp == 3
replace schoo_yrs = 4 if grade_comp == 4
replace schoo_yrs = 5 if grade_comp == 5
replace schoo_yrs = 6 if grade_comp == 6
replace schoo_yrs = 7 if grade_comp == 7
replace schoo_yrs = 8 if grade_comp == 8
replace schoo_yrs = 9 if grade_comp == 9
replace schoo_yrs = 10 if grade_comp == 10
replace schoo_yrs = 10 if grade_comp == 11
replace schoo_yrs = 12 if grade_comp == 12
replace schoo_yrs = 16 if grade_comp == 13
replace schoo_yrs = 18 if grade_comp == 14



* Checking for missing values
count if missing(schoo_yrs)
misstable summarize schoo_yrs
drop if missing(schoo_yrs)
save "edu.dta", replace

*Checking for missing values
* Summarize missing values for schoo_yrs
misstable summarize schoo_yrs, all

* Optionally see which observations are missing
list grade_comp if missing(schoo_yrs)

* Drop missing observations in one line
drop if missing(schoo_yrs)

* Save dataset
save "edu.dta", replace

*Wage data and Cleaning for unreasonable values of Wage
use "S06_rc.dta",clear
count if missing(amt_cashrs)
misstable summarize amt_cashrs
save"wage.dta", replace


*merging
use"edu.dta",clear
merge 1:1 personid using "wage.dta"
drop _merge



*Involved in wage jobs

* Total observations
count
local N_total = r(N)

* People involved in wage jobs
count if rcvd_cash == 1
local N_wage = r(N)

* Proportion
display "Proportion of wage job workers: " %6.3f (`N_wage'/`N_total')


*Receiving amount on daily, weekly and monthly basis
gen monthly = (prd_remu==1)
gen weekly  = (prd_remu==2)
gen daily   = (prd_remu==3)
summarize monthly weekly daily if rcvd_cash==1


gen wage_month = amt_cashrs
replace wage_month = 0 if rcvd_cash ==.
replace wage_month = 0 if rcvd_cash != 1
replace wage_month = amt_cashrs*365/12 if prd_remu==1   // daily
replace wage_month = amt_cashrs*52/12  if prd_remu==2   // weekly
replace wage_month = amt_cashrs        if prd_remu==3   // monthly


*Creating logarithmic of the monthly wage
gen ln_wage = ln(wage_month) if wage_month>0

*Running Regression
reg ln_wage schoo_yrs if wage_month > 0 & age >=15 & age <= 60


*Running Full Regression after assigning wage_month=0 for non-wage workers
gen full_ln_wage = ln(wage_month+1)
reg full_ln_wage schoo_yrs if age >=15 & age <= 60


save"Part_A.dta", replace







**Part B
use "Part_A", clear

merge m:1 psu hhld using "S01_rc.dta"
drop _merge





*Creating Dummies for multiple variables
gen piped_water = (source_water == 1)
gen impro_toilet = (type_toilet == 1 | type_toilet == 2)
gen clean_light = (source_light == 1 | source_light == 2)
gen own_house = (house_own == 1)






reg ln_wage schoo_yrs i.piped_water i.impro_toilet i.clean_light i.own_house if wage_month > 0 & age >=15 & age <= 60

reg full_ln_wage schoo_yrs i.piped_water i.impro_toilet i.clean_light i.own_house if age >=15 & age <= 60

log close



