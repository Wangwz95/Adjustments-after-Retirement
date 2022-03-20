global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# 2011
***********************************************************************
** 2011 CHARLS: dependent variables (family size)                         
***********************************************************************
use "$rawdatapath\2011\hhmember.dta", clear
keep householdID a006 
rename householdID hhid
sort hhid

gen temp = 1
bysort hhid: egen no_hhmember = total(temp)
label variable no_hhmember "Number of household members other than the main IW and his/her spouse"

gen child   = (a006==7) if a006<.
gen nextgen = (inrange(a006, 7, 9)) if a006<.

bysort hhid: egen with_child   = max(child)
bysort hhid: egen with_nextgen = max(nextgen)

label variable with_child   "=1, if the IW lives with his/her child"
label variable with_nextgen "=1, if the IW lives with his/her child, spouse of child or grandchild"

generate year = 2011
label variable year "Survey year"

keep  year hhid no_hhmember with_child with_nextgen
order year hhid no_hhmember with_child with_nextgen


replace  hhid = hhid + "0"

duplicates drop
save "$workingdata\coresidence_2011.dta", replace

**# 2013
***********************************************************************
** 2013 CHARLS: dependent variables (family size)                         
***********************************************************************
use "$rawdatapath\2013\Other_HHmember.dta", clear
keep householdID a006 za006 
rename householdID hhid
sort hhid

gen temp = 1
bysort hhid: egen no_hhmember = total(temp)
label variable no_hhmember "Number of household members other than the main IW and his/her spouse"

replace a006 = za006 if a006==. & za006!=.

gen child   = (a006==7) if a006<.
gen nextgen = (inrange(a006, 7, 9)) if a006<.

bysort hhid: egen with_child   = max(child)
bysort hhid: egen with_nextgen = max(nextgen)

label variable with_child   "=1, if the IW lives with his/her child"
label variable with_nextgen "=1, if the IW lives with his/her child, spouse of child or grandchild"

generate year = 2013
label variable year "Survey year"

keep  year hhid no_hhmember with_child with_nextgen
order year hhid no_hhmember with_child with_nextgen

duplicates drop
save "$workingdata\coresidence_2013.dta", replace


**# 2015
***********************************************************************
** 2015 CHARLS: dependent variables (family size)                         
***********************************************************************
use "$rawdatapath\2015\Household_Member.dta", clear
keep householdID member_type a006
rename householdID hhid
sort hhid

gen temp = (!inrange(member_type, 1, 2))
bysort hhid: egen no_hhmember = total(temp)
label variable no_hhmember "Number of household members other than the main IW and his/her spouse"


gen child   = (member_type==4) 
gen nextgen = ((member_type==4) | (member_type==7 & inrange(a006, 7, 9)) )

bysort hhid: egen with_child   = max(child)
bysort hhid: egen with_nextgen = max(nextgen)

label variable with_child   "=1, if the IW lives with his/her child"
label variable with_nextgen "=1, if the IW lives with his/her child, spouse of child or grandchild"

generate year = 2015
label variable year "Survey year"

keep  year hhid no_hhmember with_child with_nextgen
order year hhid no_hhmember with_child with_nextgen

duplicates drop
save "$workingdata\coresidence_2015.dta", replace


**# 2018
***********************************************************************
** 2018 CHARLS: dependent variables (family size)                         
***********************************************************************
** It is difficult to clean variables related to coresidence behavior in the 2018 wave
** Hope that more detailed information will be provided by the CHARLS staff

**# Append
***********************************************************************
** Append the four waves and impute the missing values                          
***********************************************************************
use          "$workingdata\coresidence_2011.dta", clear
append using "$workingdata\coresidence_2013.dta"
append using "$workingdata\coresidence_2015.dta"

sort hhid year

save "$workingdata\_coresidence.dta", replace