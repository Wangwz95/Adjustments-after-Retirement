global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# 2011
***********************************************************************
** 2011 CHARLS: dependent variables (ind income)                         
***********************************************************************
use "$rawdatapath\2011\individual_income.dta", clear
keep ID householdID ga001 ga002 ga002_1 ga002_a ga002_b ga003s1 - ga004_b_1_
order householdID ID
rename (householdID ID) (hhid id)

gen wage = (ga001==1) if ga001<., after(ga001)
replace ga002 = ga002_1 * 12            if (ga002>=.) & (ga002_1<.)
replace ga002 = (ga002_a + ga002_b) / 2 if (ga002>=.) & (ga002_a<.) & (ga002_b<.)
replace ga002 = ga002_a                 if (ga002>=.) & (ga002_a<.) & (ga002_b>=.)
replace ga002 = ga002_b                 if (ga002>=.) & (ga002_b<.) & (ga002_a>=.)
rename ga002 wage_amount
replace wage_amount = .d if wage==0 | wage>=.
replace wage_amount = .  if wage==1 & wage_amount>=.

forvalues i = 1/9{
	replace ga004_1_`i'_ = .d if ga003s`i'>=.
	replace ga004_1_`i'_ = .  if (ga003s`i'<.) & (ga004_1_`i'_>=.)
	
	replace ga004_2_`i'_ = .d if ga003s`i'>=.
	replace ga004_2_`i'_ = .  if (ga003s`i'<.) & (ga004_1_`i'_>=.)
	
	replace ga004_1_`i'_ = ga004_2_`i'_ * 12 if (ga004_1_`i'_>=.) & (ga004_2_`i'_<.)
}
drop ga004_1_11_
egen missing1 = rowmiss(ga003s1 - ga003s9)
egen missing2 = rowmiss(ga004_1_*)
order missing1, after(ga003s10)
order missing2, after(ga004_1_10_)

egen  program_amount = rowtotal(ga004_1_*)
order program_amount, after(missing2)
replace program_amount = .d if missing1==9 | (ga003s10==10)
replace program_amount = .  if missing1<9 & missing2==10
replace program_amount = (ga004_a_1_ + ga004_b_1_) / 2 if ///
	(program_amount>=.) & (ga004_a_1_<.) & (ga004_b_1_<.)
replace program_amount = ga004_a_1_ if ///
	(program_amount>=.) & (ga004_a_1_<.) & (ga004_b_1_>=.)
replace program_amount = ga004_b_1_ if ///
	(program_amount>=.) & (ga004_b_1_<.) & (ga004_a_1_>=.)
	
generate year = 2011
label variable year "Survey year"

replace  hhid = hhid + "0"
generate temp = substr(id, 10, 2), after(id)
replace  id   = hhid + temp
drop temp

keep  year hhid id wage wage_amount program_amount
order year hhid id wage wage_amount program_amount

label variable wage "=1, if the ind received wage income last year"
label variable wage_amount "The amount of wage income received last year"
label variable program_amount "The amount of social security program income received last year"

save "$workingdata\individual income_2011.dta", replace

**# 2013
***********************************************************************
** 2013 CHARLS: dependent variables (ind income)                         
***********************************************************************
use "$rawdatapath\2013\Individual_Income.dta", clear
keep ID householdID ga001 ga002 ga002_1 ga002_2 ga002_bracket_max ga002_bracket_min ga003s1 - ga004_bracket_min
order householdID ID
rename (householdID ID) (hhid id)

gen wage = (ga001==1) if ga001<., after(ga001)
rename ga002 temp
rename ga002_1 ga002
replace ga002 = ga002_2 * 12            if (ga002>=.) & (ga002_2<.) & temp==2
replace ga002 = (ga002_bracket_max + ga002_bracket_min) / 2 if (ga002>=.) & (ga002_bracket_max<.) & (ga002_bracket_min<.)
replace ga002 = ga002_bracket_max  if (ga002>=.) & (ga002_bracket_max<.) & (ga002_bracket_min>=.)
replace ga002 = ga002_bracket_min  if (ga002>=.) & (ga002_bracket_min<.) & (ga002_bracket_max>=.)
rename ga002 wage_amount
replace wage_amount = .d if wage==0 | wage>=.
replace wage_amount = .  if wage==1 & wage_amount>=.

forvalues i = 1/9{
	replace ga004_1_`i'_ = .d if ga003s`i'>=.
	replace ga004_1_`i'_ = .  if (ga003s`i'<.) & (ga004_1_`i'_>=.)
	
	replace ga004_2_`i'_ = .d if ga003s`i'>=.
	replace ga004_2_`i'_ = .  if (ga003s`i'<.) & (ga004_1_`i'_>=.)
	
	replace ga004_1_`i'_ = ga004_2_`i'_ * 12 if (ga004_1_`i'_>=.) & (ga004_2_`i'_<.)
}

egen missing1 = rowmiss(ga003s1 - ga003s9)
egen missing2 = rowmiss(ga004_1_*)

egen  program_amount = rowtotal(ga004_1_*)
replace program_amount = .d if missing1==9 | (ga003s10==10)
replace program_amount = .  if missing1<9 & missing2==10

replace program_amount = (ga004_bracket_max + ga004_bracket_min) / 2 if ///
	(program_amount>=.) & (ga004_bracket_max<.) & (ga004_bracket_min<.)
replace program_amount = ga004_bracket_max if ///
	(program_amount>=.) & (ga004_bracket_max<.) & (ga004_bracket_min>=.)
replace program_amount = ga004_bracket_min if ///
	(program_amount>=.) & (ga004_bracket_min<.) & (ga004_bracket_max>=.)
	
generate year = 2013
label variable year "Survey year"

keep  year hhid id wage wage_amount program_amount
order year hhid id wage wage_amount program_amount

label variable wage "=1, if the ind received wage income last year"
label variable wage_amount "The amount of wage income received last year"
label variable program_amount "The amount of social security program income received last year"

save "$workingdata\individual income_2013.dta", replace

**# 2015
***********************************************************************
** 2015 CHARLS: dependent variables (ind income)                         
***********************************************************************
use "$rawdatapath\2015\Individual_Income.dta", clear
keep ID householdID ga001 ga002 ga002_bracket_max ga002_bracket_min ga003s1- ga003s10  ga004_1_- ga004_9_
order householdID ID
rename (householdID ID) (hhid id)

gen wage = (ga001==1) if ga001<., after(ga001)
rename ga002 wage_amount
replace wage_amount = .d if wage==0 | wage>=.
replace wage_amount = .  if wage==1 & wage_amount>=.


egen missing1 = rowmiss(ga003s1 - ga003s9)
egen missing2 = rowmiss(ga004_*)

egen  program_amount = rowtotal(ga004_*)
replace program_amount = .d if missing1==9 | (ga003s10==10)
replace program_amount = .  if missing1<9 & missing2==9

generate year = 2015
label variable year "Survey year"

keep  year hhid id wage wage_amount program_amount
order year hhid id wage wage_amount program_amount

label variable wage "=1, if the ind received wage income last year"
label variable wage_amount "The amount of wage income received last year"
label variable program_amount "The amount of social security program income received last year"

save "$workingdata\individual income_2015.dta", replace

**# 2018
***********************************************************************
** 2018 CHARLS: dependent variables (ind income)                         
***********************************************************************
use "$rawdatapath\2018\Individual_Income.dta", clear
keep ID householdID ga001 ga002 ga002_max ga002_min ga003_w4_s1- ga003_w4_9
order householdID ID
rename (householdID ID) (hhid id)

gen wage = (ga001==1) if ga001<., after(ga001)
replace ga002 = (ga002_max + ga002_min) / 2 if (ga002>=.) & (ga002_max<.) & (ga002_min<.)
replace ga002 = ga002_max                   if (ga002>=.) & (ga002_max<.) & (ga002_min>=.)
replace ga002 = ga002_min                   if (ga002>=.) & (ga002_min<.) & (ga002_max>=.)
rename ga002 wage_amount


replace wage_amount = .d if wage==0 | wage>=.
replace wage_amount = .  if wage==1 & wage_amount>=.

forvalues i = 1/10{
	replace ga003_w4_s`i' = . if ga003_w4_s`i'==0
}
egen missing1 = rowmiss(ga003_w4_s1 - ga003_w4_s9)
egen missing2 = rowmiss(ga003_w4_1 - ga003_w4_9)

egen  program_amount = rowtotal(ga003_w4_1 - ga003_w4_9)
replace program_amount = .d if missing1==9 | (ga003_w4_s10==10)
replace program_amount = .  if missing1<9 & missing2==9

generate year = 2018
label variable year "Survey year"

keep  year hhid id wage wage_amount program_amount
order year hhid id wage wage_amount program_amount

label variable wage "=1, if the ind received wage income last year"
label variable wage_amount "The amount of wage income received last year"
label variable program_amount "The amount of social security program income received last year"

save "$workingdata\individual income_2018.dta", replace

**# Append
***********************************************************************
** Append the four waves and impute the missing values                          
***********************************************************************
use          "$workingdata\individual income_2011.dta", clear
append using "$workingdata\individual income_2013.dta"
append using "$workingdata\individual income_2015.dta"
append using "$workingdata\individual income_2018.dta"
sort id year

egen ind_inc = rowtotal(wage_amount program_amount) if wage_amount!=. & program_amount!=.
label variable ind_inc "Total amount of individual income (wage + program), 0 is included"

save "$workingdata\_individual income.dta", replace