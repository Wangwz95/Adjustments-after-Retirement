global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# 2011
***********************************************************************
** 2011 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2011\work_retirement_and_pension.dta", clear
#delimit ;
keep ID householdID communityID 
fa001 fa002 fa007 fa008 fc004 fc005 fc006 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003
fb011 fb012 fd002 fd006 fd007 fd008 fd009 fd010 fd011_1 fd011_2 fd012_gb fd012_isco 
fl001 fl002_1 fl002_2 fl003_1 fl003_2 fl014 fl015 fl016 fl017_gb fl017_isco fl018 
fm001 fm003 fm005_1 fm005_2 fm014_1 fm014_2 fm018_1 fm018_2 fm024 fm025_1 fm025_2 fm030_1 fm030_2 fm036 fm037_1 fm037_2 fm040 fm052 fm053 fn080;
#delimit cr

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

foreach var in fc005 fc010 fe002 fh002{
	replace `var' = 7 if `var'>7 & `var'<.
}
foreach var in fc006 fc011 fe003 fh003{
    replace `var' = 16 if `var'>16 & `var'<. // Set the maximum working hours per day as 16 hours
}


gen workhour_agother = fc004 * fc005 * fc006 * 4, after(fc006)
label variable workhour_agother "Hours working for other farmers last year"
gen workhour_agown = fc009 * fc010 * fc011 * 4, after(fc011)
label variable workhour_agown "Hours doing agricultural work for one's own household last year"
gen workhour_wg = fe001 * fe002 * fe003 * 4, after(fe003)
label variable workhour_wg "Hours doing wage work last year"
gen workhour_own = fh001 * fh002 * fh003 * 4, after(fh003)
label variable workhour_own "Hours doing self-employeed business last year"

/*
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
*/

order work work_ag work_wg never workhour_agother workhour_agown workhour_wg workhour_own, after(id)

egen  workhour = rowtotal(workhour_agother workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agother)
label variable workhour "Total working hours last year"

replace work     =  1 if workhour > 0
replace workhour = .  if work==1 & workhour==0
replace workhour = .d if work==0

egen temp = rowmax(workhour_agother workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour<.)
drop temp fc004 fc005 fc006 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003

generate workhour0 = workhour, after(workhour)
replace  workhour0 = 0 if workhour0 == .d
label variable workhour0 "Total working hours last year; 0 is included for non-workers"

generate retire = (fb011==1 | fb012==1) if inrange(fb011, 1, 2), after(fb012)
codebook retire
codebook retire
label variable retire "=1, if the ind has processes retired or receded the position"
drop fb011 fb012

generate worktype = ., after(retire)
replace  worktype = fd002 if worktype==. & fd002<.
replace  worktype = fl014 if worktype==. & fl014<.
replace  worktype = fm003 if worktype==. & fm003<. & fm001==2

#delimit ;
label define worktype 
           1 "Government"
           2 "Institutions"
           3 "NGO"
           4 "Firm"
           5 "Individual firm"
           6 "Individual farmer"
           7 "Individual household"
           8 "Other";
#delimit cr
label values worktype worktype
label variable worktype "The type of the ind's latest work (retirement or not)"
drop fd002 fl014 fm003

generate yor = .
replace  yor = fm005_1 if yor==. & fm005_1<.
replace  yor = fm014_1 if yor==. & fm014_1<.
replace  yor = fm025_1 if yor==. & fm025_1<.
replace  yor = fm030_1 if yor==. & fm030_1<.
label variable yor "Year of retirement"
drop fm005_1 fm014_1 fm025_1 fm030_1

generate year = 2011, before(communityID)
label variable year "Survey year"

replace  hhid = hhid + "0"
generate temp = substr(id, 10, 2), after(id)
replace  id   = hhid + temp
drop temp

generate workafterR = (fm052==1) if inrange(fm052, 1, 2)
label variable workafterR "=1, if the ind work after his/her retirement"
drop fm052

#delimit ;
keep  year communityID hhid id retire worktype yor workafterR fn080
	work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own; 
order year communityID hhid id retire worktype yor workafterR fn080
	work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own;
#delimit cr

save "$workingdata\labor supply_2011.dta", replace

**# 2013
***********************************************************************
** 2013 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2013\Work_Retirement_and_Pension.dta", clear

keep ID householdID communityID fa001 fa002 fa007 fa008 fc004 fc005 fc006 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003 fm003 fb011 fb012 zf15 zf16 zf23

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
replace workhour = .  if work==1
replace workhour = .d if work==0
egen temp = rowmax(workhour_agother workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
label variable workhour "Total working hours last year"

generate workhour0 = workhour, after(workhour)
replace  workhour0 = 0 if workhour0 == .d
label variable workhour0 "Total working hours last year; 0 is included for non-workers"

generate retire = .
replace  retire = 1 if fb011==1 | fb012==1 | zf15==1 | zf16==1 | zf23==1
replace  retire = 0 if (fb011!=. | fb012!=.) & retire!=1
 // replace  retire = 0 if work==1
label variable retire "=1, if the ind has processes retired or receded the position"
drop fb011 fb012 zf15 zf16 zf23

generate year = 2013, before(communityID)
label variable year "Survey year"

keep  year communityID hhid id retire work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire work work_ag work_wg neverwork workhour workhour_agother workhour_agown workhour_wg workhour_own 
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

egen  workhour = rowtotal(workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agown)
replace work     =  1 if workhour > 0
replace workhour = .  if work==1
replace workhour = .d if work==0
egen temp = rowmax(workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
label variable workhour "Total working hours last year"

generate workhour0 = workhour, after(workhour)
replace  workhour0 = 0 if workhour0 == .d
label variable workhour0 "Total working hours last year; 0 is included for non-workers"

generate retire = .
replace  retire = 1 if fb011==1 | fb012==1 | zf15==1 | zf16==1
replace  retire = 0 if (fb011!=. | fb012!=.) & retire!=1
replace  retire = 0 if work==1
label variable retire "=1, if the ind has retired and did not work last year/week"
drop fb011 fb012 zf15 zf16

generate year = 2015, before(communityID)
label variable year "Survey year"

keep  year communityID hhid id retire work work_ag work_wg neverwork workhour workhour0 workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire work work_ag work_wg neverwork workhour workhour0 workhour_agown workhour_wg workhour_own 

save "$workingdata\labor supply_2015.dta", replace


**# 2018
***********************************************************************
** 2018 CHARLS: independent variables                          
***********************************************************************
use "$rawdatapath\2018\Work_Retirement.dta", clear

keep ID householdID communityID fa002_w4 fc008 fc001 fa007 fa008 fc009 fc010 fc011 fe001 fe002 fe003 fh001 fh002 fh003 fm003 fb011_w4 fb012 xzf17 xzf18 xzf19 fm000_w4 zf25_4

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

egen  workhour = rowtotal(workhour_agown workhour_wg workhour_own)
order workhour, before(workhour_agown)
replace work     =  1 if workhour > 0
replace workhour = .  if work==1
replace workhour = .d if work==0
egen temp = rowmax(workhour_agown workhour_wg workhour_own)
order temp, after(workhour)
replace workhour = temp if workhour>5840 & (workhour!=. & workhour!=.d)
label variable workhour "Total working hours last year"

generate workhour0 = workhour, after(workhour)
replace  workhour0 = 0 if workhour0 == .d
label variable workhour0 "Total working hours last year; 0 is included for non-workers"

generate retire = .
replace  retire = 1 if fb011==1 | fb012==1 | xzf18==1 | xzf19==1 | xzf17==1 |zf25_4==1
replace  retire = 0 if (fb011!=. | fb012!=. | xzf19==1) & retire!=1
replace  retire = 0 if work==1
label variable retire "=1, if the ind has retired and did not work last year/week"


generate year = 2018, before(communityID)
label variable year "Survey year"

keep  year communityID hhid id retire work work_ag work_wg neverwork workhour workhour0 workhour_agown workhour_wg workhour_own 
order year communityID hhid id retire work work_ag work_wg neverwork workhour workhour0 workhour_agown workhour_wg workhour_own 

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

sort id year
generate temp = 1
bysort id: egen no_wave = total(temp)
drop temp
label variable no_wave "Number of waves the ind shown in the dataset"

bysort id: generate temp1 = retire[1]
bysort id: generate temp2 = retire[2] if no_wave>=2
bysort id: generate temp3 = retire[3] if no_wave>=3
bysort id: generate temp4 = retire[4] if no_wave>=4
order temp*, after(retire)

bysort id: gen wave = _n
order wave, after(retire)

forvalues i = 1/3{
	if `i'==1{
		replace retire = temp2 if wave==`i' & temp2==0 & retire==.
		replace retire = temp3 if wave==`i' & temp3==0 & retire==.
		replace retire = temp4 if wave==`i' & temp4==0 & retire==.
	}
	if `i'==2{
		replace retire = temp3 if wave==`i' & temp3==0 & retire==.
		replace retire = temp4 if wave==`i' & temp4==0 & retire==.
	}
	if `i'==3{
		replace retire = temp4 if wave==`i' & temp4==0 & retire==.
	}
} // 在retire=0之前的年份retire也一定为0

forvalues i = 1/3{
	if `i'==1{
		replace retire = 1 if wave==2 & temp`i'==1 & retire==.
		replace retire = 1 if wave==3 & temp`i'==1 & retire==.
		replace retire = 1 if wave==4 & temp`i'==1 & retire==.
	}
	if `i'==2{
		replace retire = 1 if wave==3 & temp`i'==1 & retire==.
		replace retire = 1 if wave==4 & temp`i'==1 & retire==.
	}
	if `i'==3{
		replace retire = 1 if wave==4 & temp`i'==1 & retire==.
	}
} // 在出现retire之后的年份一定也是retire，仅修改了缺失值
drop temp*

replace retire = 0 if work!=. & retire==.

save "$workingdata\_labor supply.dta", replace
