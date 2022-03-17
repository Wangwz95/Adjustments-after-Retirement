global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# 2011
***********************************************************************
** 2011 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2011\work_retirement_and_pension.dta", clear
keep ID householdID communityID fa001 fa002 fa007 fa008 fc004 fc005 fc006 fc007 fc009 fc010 fc011 fe001 fe002 fe003 ff002 ff003_a ff003_b ff012 ff013_a ff013_b fh001 fh002 fh003 fh020 fm003 fb011 fb012

order communityID householdID ID
rename (householdID ID) (hhid id)

gen work_ag = (fa001==1) if inrange(fa001, 1, 2), after(fa001)
gen work_wg = (fa002==1) if inrange(fa002, 1, 2), after(fa002)
gen work    = ((work_ag==1) | (work_wg==1)),      after(work_wg)
label variable work_ag "=1, if the ind engaged in agricultural work for more than 10 days last year"
label variable work_wg "=1, if the ind worked for at least 1h last week"
label variable work    "=1, if (work_ag==1) | (work_wg==1)"
drop fa001 fa002

gen neverwork = (fa007==2 & fa008==1) if fa007!=., after(fa007)
label variable neverwork "=1, if the ind never worked for at least three months"
drop fa007 fa008

foreach var in fc011 fc006 fe003 fh003{
    replace `var' = 16 if `var' >= 16 & `var' !=.
}


gen workhour_agother = fc004 * fc005 * fc006 * 4, after(fc006)
label variable workhour_agother "Hours working for other farmers last year"

gen workhour_agown = fc009 * fc010 * fc011 * 4, after(fc011)
label variable workhour_agown "Hours doing agricultural work for one's own household last year"


gen workhour_wg = fe001 * fe002 * fe003 * 4, after(fe003)
label variable workhour_wg "Hours doing wage work last year"

replace fh002 = 7 if fh002 > 7
gen workhour_own = fh001 * fh002 * fh003 * 4, after(fh003)
label variable workhour_own "Hours doing self-employeed business last year"


gen inc_agother_year = fc004 * fc007
label variable inc_agother_year "Income from working for other farmers"
rename fc007 inc_agother_month 
label variable inc_agother_month "Average monthly wage for other farmers"
drop fc004 fc005 fc006

replace ff002 = (ff003_a + ff003_b)/2 if ff002==. & ff003_a!=. & ff003_b!=.
rename ff002 inc_wg_year
drop ff003_a ff003_b

replace ff012 = (ff013_a + ff013_b)/2 if ff012==. & ff013_a!=. & ff013_b!=.
rename ff012 inc_wg_month
drop ff013_a ff013_b

rename fh020 inc_own_year

order communityID hhid id work work_ag work_wg neverwork workhour_agother workhour_agown workhour_wg workhour_own inc_agother_year inc_wg_year inc_own_year inc_wg_month inc_agother_month

egen  workhour = rowtotal(workhour_agother workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agother)
replace work     =  1 if workhour > 0
replace workhour = .  if work==1 & workhour<=12
replace workhour = .d if work==0
egen temp = rowmax(workhour_agother workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
drop temp fc009 - fh003
label variable workhour "Total working hours last year"

generate retire = (fb011==1 | fb012==1) if inrange(fb011, 1, 2), after(fb012)
replace  retire = 0 if work==1
label variable retire "=1, if the ind has retired and did not work last year/week"
drop fb011 fb012

rename fm003 worktype

generate year = 2011, before(communityID)
label variable year "Survey year"

replace  hhid = hhid + "0"
generate temp = substr(id, 10, 2), after(id)
replace  id   = hhid + temp
drop temp

keep year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own 
save "$workingdata\labor supply_2011.dta", replace

**# 2013
***********************************************************************
** 2013 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2013\Work_Retirement_and_Pension.dta", clear

keep ID householdID communityID fa001 fa002 fa007 fa008 fc004 fc005 fc006 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003 fm003 fb011 fb012 zf15 zf16

order communityID householdID ID
rename (householdID ID) (hhid id)

gen work_ag = (fa001==1) if inrange(fa001, 1, 2), after(fa001)
gen work_wg = (fa002==1) if inrange(fa002, 1, 2), after(fa002)
gen work    = ((work_ag==1) | (work_wg==1)),      after(work_wg)
label variable work_ag "=1, if the ind engaged in agricultural work for more than 10 days last year"
label variable work_wg "=1, if the ind worked for at least 1h last week"
label variable work    "=1, if (work_ag==1) | (work_wg==1)"
drop fa001 fa002

gen neverwork = (fa007==2 & fa008==1) if fa007!=., after(fa007)
label variable neverwork "=1, if the ind never worked for at least three months"
drop fa007 fa008

foreach var in fc011 fc006 fe003 fh003{
    replace `var' = 16 if `var' >= 16 & `var' !=.
}
foreach var in fc005 fc010 fe002 fh002{
    replace `var' = 7 if `var' >7 & `var' !=.
}


gen workhour_agother = fc004 * fc005 * fc006 * 4, after(fc006)
label variable workhour_agother "Hours working for other farmers last year"

gen workhour_agown = fc009 * fc010 * fc011 * 4, after(fc011)
label variable workhour_agown "Hours doing agricultural work for one's own household last year"


gen workhour_wg = fe001 * fe002 * fe003 * 4, after(fe003)
label variable workhour_wg "Hours doing wage work last year"

gen workhour_own = fh001 * fh002 * fh003 * 4, after(fh003)
label variable workhour_own "Hours doing self-employeed business last year"

order communityID hhid id work work_ag work_wg neverwork workhour_agother workhour_agown workhour_wg workhour_own

egen  workhour = rowtotal(workhour_agother workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agother)
replace work     =  1 if workhour > 0
replace workhour = .  if work==1 & workhour<=12
replace workhour = .d if work==0
egen temp = rowmax(workhour_agother workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
drop temp fc009 - fh003
label variable workhour "Total working hours last year"

generate retire = .
replace  retire = 1 if fb011==1 | fb012==1 | zf15==1 | zf16==1
replace  retire = 0 if (fb011!=. | fb012!=.) & retire!=1
replace  retire = 0 if work==1
label variable retire "=1, if the ind has retired and did not work last year/week"
drop fb011 fb012 zf15 zf16

rename fm003 worktype

generate year = 2013, before(communityID)
label variable year "Survey year"
keep year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own 
save "$workingdata\labor supply_2013.dta", replace

**# 2015
***********************************************************************
** 2015 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2015\Work_Retirement_and_Pension.dta", clear

keep ID householdID communityID fa001 fa002 fa007 fa008 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003 fm003 fb011 fb012 zf15 zf16

order communityID householdID ID
rename (householdID ID) (hhid id)

gen work_ag = (fa001==1) if inrange(fa001, 1, 2), after(fa001)
gen work_wg = (fa002==1) if inrange(fa002, 1, 2), after(fa002)
gen work    = ((work_ag==1) | (work_wg==1)),      after(work_wg)
label variable work_ag "=1, if the ind engaged in agricultural work for more than 10 days last year"
label variable work_wg "=1, if the ind worked for at least 1h last week"
label variable work    "=1, if (work_ag==1) | (work_wg==1)"
drop fa001 fa002

gen neverwork = (fa007==2 & fa008==1) if fa007!=., after(fa007)
label variable neverwork "=1, if the ind never worked for at least three months"
drop fa007 fa008

foreach var in fc011 fe003 fh003{
    replace `var' = 16 if `var' >= 16 & `var' !=.
}
foreach var in fc010 fe002 fh002{
    replace `var' = 7 if `var' >7 & `var' !=.
}


gen workhour_agown = fc009 * fc010 * fc011 * 4, after(fc011)
label variable workhour_agown "Hours doing agricultural work for one's own household last year"

gen workhour_wg = fe001 * fe002 * fe003 * 4, after(fe003)
label variable workhour_wg "Hours doing wage work last year"

gen workhour_own = fh001 * fh002 * fh003 * 4, after(fh003)
label variable workhour_own "Hours doing self-employeed business last year"

order communityID hhid id work work_ag work_wg neverwork workhour_agown workhour_wg workhour_own

egen  workhour = rowtotal(workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agown)
replace work     =  1 if workhour > 0
replace workhour = .  if work==1 & workhour<=12
replace workhour = .d if work==0
egen temp = rowmax(workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
drop temp fc009 - fh003
label variable workhour "Total working hours last year"

generate retire = .
replace  retire = 1 if fb011==1 | fb012==1 | zf15==1 | zf16==1
replace  retire = 0 if (fb011!=. | fb012!=.) & retire!=1
replace  retire = 0 if work==1
label variable retire "=1, if the ind has retired and did not work last year/week"
drop fb011 fb012 zf15 zf16

rename fm003 worktype

generate year = 2015, before(communityID)
label variable year "Survey year"

keep year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agown workhour_wg workhour_own 

save "$workingdata\labor supply_2015.dta", replace


**# 2018
***********************************************************************
** 2018 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2018\Work_Retirement.dta", clear

keep ID householdID communityID fa002_w4 fc008 fc001 fa007 fa008 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003 fm003 fb011_w4 fb012 xzf21 xzf18 xzf19 fm000_w4

order communityID householdID ID
rename (householdID ID) (hhid id)

gen work_ag = (fc001==1 | fc008==1) if (fc001!=. | fc008!=.)
gen work_wg = (fa002_w4==1) if inrange(fa002_w4, 1, 2), after(fa002)
gen work    = ((work_ag==1) | (work_wg==1)),      after(work_wg)
label variable work_ag "=1, if the ind engaged in agricultural work for more than 10 days last year"
label variable work_wg "=1, if the ind worked for at least 1h last week"
label variable work    "=1, if (work_ag==1) | (work_wg==1)"
drop fa002_w4 fc008 fc001

gen neverwork = (fa007==2 & fa008==1) if fa007!=., after(fa007)
label variable neverwork "=1, if the ind never worked for at least three months"
drop fa007 fa008

foreach var in fc011 fe003 fh003{
    replace `var' = 16 if `var' >= 16 & `var' !=.
}
foreach var in fc010 fe002 fh002{
    replace `var' = 7 if `var' >7 & `var' !=.
}


gen workhour_agown = fc009 * fc010 * fc011 * 4, after(fc011)
label variable workhour_agown "Hours doing agricultural work for one's own household last year"

gen workhour_wg = fe001 * fe002 * fe003 * 4, after(fe003)
label variable workhour_wg "Hours doing wage work last year"

gen workhour_own = fh001 * fh002 * fh003 * 4, after(fh003)
label variable workhour_own "Hours doing self-employeed business last year"

order communityID hhid id work work_ag work_wg neverwork workhour_agown workhour_wg workhour_own

egen  workhour = rowtotal(workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agown)
replace work     =  1 if workhour > 0
replace workhour = .  if work==1 & workhour<=12
replace workhour = .d if work==0
egen temp = rowmax(workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
drop temp fc009 - fh003
label variable workhour "Total working hours last year"

generate retire = .
replace  retire = 1 if fb011==1 | fb012==1 | xzf18==1 | xzf19==1 | fm000_w4==1
replace  retire = 0 if (fb011!=. | fb012!=. | xzf19==1) & retire!=1
replace  retire = 0 if work==1
label variable retire "=1, if the ind has retired and did not work last year/week"
drop fb011 fb012 xzf21 xzf18 xzf19 fm000_w4

rename fm003 worktype

generate year = 2018, before(communityID)
label variable year "Survey year"

keep year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire worktype work work_ag work_wg neverwork workhour workhour_agown workhour_wg workhour_own 

save "$workingdata\labor supply_2018.dta", replace

**# Append
***********************************************************************
** Append the four waves and impute the missing values                          
***********************************************************************
use          "$workingdata\labor supply_2011.dta", clear
append using "$workingdata\labor supply_2013.dta"
append using "$workingdata\labor supply_2015.dta"
append using "$workingdata\labor supply_2018.dta"
sort id year


bysort id: gen temp = retire[_N]
order temp, after(retire)
replace retire = temp if (retire==.) & (temp==0) // 最后一期也未退休的人之前一定也没有退休
drop temp

bysort id: gen tempvar = ((retire==1 & retire[_n-1]==0) | (retire[1]==1)) 
order tempvar, after(retire)
gen tempyear = year if tempvar==1, after(tempvar)
sort id tempyear
bysort id: replace tempyear = tempyear[1]
sort id year
replace retire = 1 if year>=tempyear // 在出现retire之后的年份一定也是retire
drop temp*

bysort id: egen temp = min(retire)
order temp, after(retire)

gen tempyear = year if temp==retire, after(temp)
bysort id: egen tempyear1 = min(tempyear)
order tempyear1, after(tempyear)
replace retire = 0 if temp==0 & year<tempyear1 & retire==. // retire=0之前的年份也一定为0
drop temp*

save "$workingdata\_labor supply.dta", replace
