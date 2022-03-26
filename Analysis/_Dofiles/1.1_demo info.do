global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# 2011
***********************************************************************
** 2011 CHARLS: control variables                           
***********************************************************************
use "$rawdatapath\2011\demographic_background.dta", clear
keep  ID householdID communityID ba002_1 ba002_2 ba003 ba001 bb001 bc001 bc005 bd001 be001 rgender
order communityID ID householdID rgender ba002_1 ba002_2 ba003 ba001 bb001 bc001 bc005 bd001 be001

rename (ID householdID) (id hhid)
sort hhid id
generate temp = 1
bysort hhid: egen no_old = total(temp)
order no_old, after(hhid)
label variable no_old "Number of IWs in this hh"
drop temp

codebook rgender
generate male = (rgender==1) if (inrange(rgender,1,2)), after(rgender)
label variable male "=1, if the ind is a male"
drop rgender

rename (ba002_1 ba002_2) (yob mob)
generate age       = 2011 - yob,     after(mob)
generate age_month = age * 12 + mob, after(age)
label variable age "survey year - year of birth"
label variable age_month "Age * 12 + mob"
drop ba003 ba001

/*
generate notsamecity = (inrange(bb001, 3, 5)) if inrange(bb001, 1, 5)
label variable notsamecity "=1, if the ind's birthplace and residence are not in the same city"
drop bb001

generate notsamecity_hukou = .
replace  notsamecity_hukou = 1 if inrange(bc005, 4, 5)
replace  notsamecity_hukou = 1 if bc005==1 & notsamecity==1
replace  notsamecity_hukou = 0 if (inrange(bc005,1,5) | notsamecity!=.) & notsamecity_hukou!=1
label variable notsamecity_hukou "=1, if the ind's hukou place and residence are not in the same city"
drop bc005
*/

rename bc001 hukou
replace hukou = . if !inrange(hukou,1 , 4)
replace hukou = 5 if hukou==.
label define hukou ///
	1 "Agricultual" 2 "Non-Agricultural" 3 "Unified Residence" ///        
    4 "Do not have Hukou" 5 "Missing"
numlabel hukou, add
label values hukou hukou

rename (bd001 be001) (educ marriage)
recode educ (9/11 = 8)
replace educ = . if !inrange(educ, 1, 8)
replace educ = 9 if educ==.
label define educ ///
	1 "Illiterate" 2 "Did not finish primary school but capable of reading and/or writing" ///
	3 "Home school" 4 "Elementary school" 5 "Middle school" 6 "High school" ///
	7 "Vocational school" 8 "College and above" 9 "Missing"
numlabel educ, add
label values educ educ

replace marriage = 7 if !inrange(marriage, 1, 6)
label define marriage ///
	1 "Married with spouse present" 2 "Married but not living with spouse temporarily" ///
    3 "Separated" 4 "Divorced" 5 "Widowed" 6 "Never married" 7 "Missing"
numlabel marriage, add
label values marriage marriage

keep communityID hhid id no_old male yob mob age age_month hukou educ marriage
order communityID hhid id no_old male yob mob age age_month hukou educ marriage

generate year = 2011, before(communityID)
label variable year "Survey year"

replace  hhid = hhid + "0"
generate temp = substr(id, 10, 2), after(id)
replace  id   = hhid + temp
drop temp

save "$workingdata\demo_2011.dta", replace

**# 2013
***********************************************************************
** 2013 CHARLS: control variables                            
***********************************************************************
use "$rawdatapath\2013\Demographic_Background.dta", clear
keep ID householdID communityID zba002_1 zba002_2 zbc001 zbc005 zbd001 ba000_w2_3 ba007_w2_1 ba006_w2_1 bb001 bc001 bc005 bd001 be001 ba002_1 ba002_2
order communityID ID householdID

rename (ID householdID) (id hhid)
sort hhid id
generate temp = 1
bysort hhid: egen no_old = total(temp)
order no_old, after(hhid)
label variable no_old "Number of IWs in this hh"
drop temp

codebook ba000_w2_3
generate male = (ba000_w2_3 ==1) if (inrange(ba000_w2_3,1,2)), after(ba000_w2_3)
label variable male "=1, if the ind is a male"
drop ba000_w2_3

replace ba002_1 = zba002_1 if ba002_1==. & zba002_1!=.
replace ba002_2 = zba002_2 if ba002_2==. & zba002_2!=.
rename (ba002_1 ba002_2) (yob mob)
generate age       = 2013 - yob,   after(mob)
generate age_month = age * 12 + mob, after(age)
label variable age "survey year - year of birth"
label variable age_month "Age * 12 + mob"
drop zba002_1 zba002_2

replace bc001 = zbc001 if bc001==. & zbc001!=.
rename bc001 hukou
replace hukou = . if !inrange(hukou,1 , 4)
replace hukou = 5 if hukou==.
label define hukou ///
	1 "Agricultual" 2 "Non-Agricultural" 3 "Unified Residence" ///        
    4 "Do not have Hukou" 5 "Missing"
numlabel hukou, add
label values hukou hukou

replace bd001 = zbd001 if bd001==. & zbd001!=.
rename (bd001 be001) (educ marriage)
recode educ (9/11 = 8)
replace educ = . if !inrange(educ, 1, 8)
replace educ = 9 if educ==.
label define educ ///
	1 "Illiterate" 2 "Did not finish primary school but capable of reading and/or writing" ///
	3 "Home school" 4 "Elementary school" 5 "Middle school" 6 "High school" ///
	7 "Vocational school" 8 "College and above" 9 "Missing"
numlabel educ, add
label values educ educ

replace marriage = 7 if !inrange(marriage, 1, 6)
label define marriage ///
	1 "Married with spouse present" 2 "Married but not living with spouse temporarily" ///
    3 "Separated" 4 "Divorced" 5 "Widowed" 6 "Never married" 7 "Missing"
numlabel marriage, add
label values marriage marriage

generate minority = (ba007_w2_1!=1) if (ba007_w2_1!=.)
label variable minority "=1, if the ind is national minority"

generate communist = (ba006_w2_1==1) if (ba006_w2_1!=.)
label variable communist "=1, if the ind is a communist"


keep  communityID id hhid no_old male yob mob age age_month hukou educ marriage minority communist
order communityID hhid id no_old male yob mob age age_month hukou educ marriage minority communist

generate year = 2013, before(communityID)
label variable year "Survey year"

save "$workingdata\demo_2013.dta", replace

**# 2015
***********************************************************************
** 2015 CHARLS: control variables                            
***********************************************************************
use "$rawdatapath\2015\Demographic_Background.dta", clear
keep ID householdID communityID ba000_w2_3 ba004_w3_1 ba004_w3_2 ba004_w3_3 ba002_1 ba002_2 bc001_w3_2 bc002_w3_1 bd001_w2_4 be001 xrtype
order communityID ID householdID

rename (ID householdID) (id hhid)
sort hhid id
generate temp = 1
bysort hhid: egen no_old = total(temp)
order no_old, after(hhid)
label variable no_old "Number of IWs in this hh"
drop temp

codebook ba000_w2_3
generate male = (ba000_w2_3 ==1) if (inrange(ba000_w2_3,1,2)), after(ba000_w2_3)
label variable male "=1, if the ind is a male"
drop ba000_w2_3

replace ba004_w3_1 = ba002_1 if ba002_1!=. & ba004_w3_1==.
replace ba004_w3_2 = ba002_2 if ba002_2!=. & ba004_w3_2==.
rename (ba004_w3_1 ba004_w3_2) (yob mob)
generate age       = 2015 - yob,   after(mob)
generate age_month = age * 12 + mob, after(age)
label variable age "survey year - year of birth"
label variable age_month "Age * 12 + mob"
drop ba002_1 ba002_2 ba004_w3_3

replace bc002_w3_1 = bc001_w3_2 if bc002_w3_1==. & bc001_w3_2!=.
drop bc001_w3_2
merge 1:1 id using "$workingdata\demo_2013.dta", keepusing(hukou) keep(master match) nogenerate
replace bc002_w3_1 = hukou if bc002_w3_1==. & hukou!=.
drop hukou
merge 1:1 id using "$workingdata\demo_2011.dta", keepusing(hukou) keep(master match) nogenerate
replace bc002_w3_1 = hukou if bc002_w3_1==. & hukou!=.
drop hukou
rename bc002_w3_1 hukou
replace hukou = 5 if !inrange(hukou, 1, 4)
label values hukou hukou

recode bd001_w2_4 (9/11 = 8)
merge 1:1 id using "$workingdata\demo_2013.dta", keepusing(educ) keep(master match) nogenerate
replace bd001_w2_4 = educ if (bd001_w2_4==12 | bd001_w2_4==.) & inrange(educ, 1, 8)
drop educ
merge 1:1 id using "$workingdata\demo_2011.dta", keepusing(educ) keep(master match) nogenerate
replace bd001_w2_4 = educ if (bd001_w2_4==12 | bd001_w2_4==.) & inrange(educ, 1, 8)
drop educ
rename bd001_w2_4 educ
replace educ = 9 if !inrange(educ, 1, 8)
label values educ educ

rename be001 marriage
replace marriage = 7 if !inrange(marriage, 1, 6)
label values marriage marriage

keep communityID id hhid no_old male yob mob age age_month hukou educ marriage 
order communityID hhid id no_old male yob mob age age_month hukou educ marriage 

generate year = 2015, before(communityID)
label variable year "Survey year"

save "$workingdata\demo_2015.dta", replace

**# 2018
***********************************************************************
** 2018 CHARLS: control variables                            
********************************8***************************************
use "$rawdatapath\2018\Demographic_Background.dta", clear
keep ID householdID communityID ba000_w2_3 ba004_w3_1 ba004_w3_2 ba002_1 ba002_2 bc001_w3_2 bc002_w3_1 bd001_w2_4 be001 bg001_w4 bg004_w4 zbc004 zfredu zfrgender zfrbirth
order communityID ID householdID

rename (ID householdID) (id hhid)
sort hhid id
generate temp = 1
bysort hhid: egen no_old = total(temp)
order no_old, after(hhid)
label variable no_old "Number of IWs in this hh"
drop temp

codebook ba000_w2_3
generate male = (ba000_w2_3 ==1) if (inrange(ba000_w2_3,1,2)), after(ba000_w2_3)
label variable male "=1, if the ind is a male"
drop ba000_w2_3

replace ba004_w3_1 = ba002_1 if ba002_1!=. & ba004_w3_1==.
replace ba004_w3_2 = ba002_2 if ba002_2!=. & ba004_w3_2==.
rename (ba004_w3_1 ba004_w3_2) (yob mob)
generate age       = 2018 - yob,   after(mob)
generate age_month = age * 12 + mob, after(age)
label variable age "survey year - year of birth"
label variable age_month "Age * 12 + mob"

replace bc002_w3_1 = bc001_w3_2 if bc002_w3_1==. & bc001_w3_2!=.
replace bc002_w3_1 = zbc004 if bc002_w3_1==. & zbc004!=.
rename bc002_w3_1 hukou
replace hukou = . if !inrange(hukou,1 , 4)
replace hukou = 5 if hukou==.
label define hukou ///
	1 "Agricultual" 2 "Non-Agricultural" 3 "Unified Residence" ///        
    4 "Do not have Hukou" 5 "Missing"
numlabel hukou, add
label values hukou hukou

rename (bd001_w2_4 be001) (educ marriage)
recode educ (9/11 = 8)
replace educ = . if !inrange(educ, 1, 8)
replace educ = 9 if educ==.
label define educ ///
	1 "Illiterate" 2 "Did not finish primary school but capable of reading and/or writing" ///
	3 "Home school" 4 "Elementary school" 5 "Middle school" 6 "High school" ///
	7 "Vocational school" 8 "College and above" 9 "Missing"
numlabel educ, add
label values educ educ

replace marriage = 7 if !inrange(marriage, 1, 6)
label define marriage ///
	1 "Married with spouse present" 2 "Married but not living with spouse temporarily" ///
    3 "Separated" 4 "Divorced" 5 "Widowed" 6 "Never married" 7 "Missing"
numlabel marriage, add
label values marriage marriage

codebook bg001_w4
generate minority = (bg001_w4!=1) 
label variable minority "=1, if the ind is national minority"

generate communist = (bg004_w4==1)
label variable communist "=1, if the ind is a communist"

keep  communityID id hhid no_old male yob mob age age_month hukou educ marriage minority communist
order communityID hhid id no_old male yob mob age age_month hukou educ marriage minority communist

generate year = 2018, before(communityID)
label variable year "Survey year"

save "$workingdata\demo_2018.dta", replace

**# Append
***********************************************************************
** Append the four waves and impute the missing values                          
***********************************************************************
use          "$workingdata\demo_2011.dta", clear
append using "$workingdata\demo_2013.dta"
append using "$workingdata\demo_2015.dta"
append using "$workingdata\demo_2018.dta"

sort id year
generate temp = 1
bysort id: egen no_wave = total(temp)
drop temp
label variable no_wave "Number of waves the ind shown in the dataset"

* minority & communist
sort id minority
bysort id: generate temp = minority[1]
replace minority = temp if minority==. & temp!=.
sort id communist
bysort id: generate temp1 = communist[1]
replace communist = temp1 if communist==. & temp1!=.
drop temp*
replace minority  = 2 if minority  ==.
replace communist = 2 if communist ==.
label define missing 2 "Missing"
label values minority missing
label values communist missing

* male
sort id male
bysort id: generate temp = male[1]
replace male = temp if male==. & temp!=.
drop temp*

* educ
sort id year
bysort id: generate temp1 = educ[1]
bysort id: generate temp2 = educ[2] if no_wave>=2
bysort id: generate temp3 = educ[3] if no_wave>=3
bysort id: generate temp4 = educ[4] if no_wave>=4
order temp*, after(educ)
replace educ = temp1 if (educ==9) & (temp1!=9)
replace educ = temp2 if (educ==9) & (temp2!=9)
replace educ = temp3 if (educ==9) & (temp3!=9)
replace educ = temp3 if (educ==9) & (temp4!=9)
drop temp*
replace educ = 9 if !inrange(educ, 1, 8)

* hukou
sort id year
bysort id: generate temp1 = hukou[1]
bysort id: generate temp2 = hukou[2] if no_wave>=2
bysort id: generate temp3 = hukou[3] if no_wave>=3
bysort id: generate temp4 = hukou[4] if no_wave>=4
order temp*, after(hukou)
replace hukou = temp1 if (hukou==5) & (temp1!=5)
replace hukou = temp2 if (hukou==5) & (temp2!=5)
replace hukou = temp3 if (hukou==5) & (temp3!=5)
replace hukou = temp3 if (hukou==5) & (temp4!=5)
drop temp*
replace hukou = 5 if !inrange(hukou, 1, 4)

* yob
sort id year
bysort id: generate temp1 = yob[1]
bysort id: generate temp2 = yob[2] if no_wave>=2
bysort id: generate temp3 = yob[3] if no_wave>=3
bysort id: generate temp4 = yob[4] if no_wave>=4
order temp*, after(yob)

replace yob = temp1 if (yob>=.) & (temp1!=.)
replace yob = temp2 if (yob>=.) & (temp2!=.)
replace yob = temp3 if (yob>=.) & (temp3!=.)
replace yob = temp4 if (yob>=.) & (temp4!=.)

bysort id: egen temp =  mode(yob)
order temp, after(yob)
generate error = yob - temp, after(temp)
replace  yob = temp if !inrange(error, -5, 5) & temp<.
drop error

merge 1:1 id year using "$rawdatapath\H_CHARLS_demo_long.dta"

replace age = year - yob
replace age_month = age * 12 + mob
drop temp*

merge m:1 communityID using "$rawdatapath\2011\PSU.dta", ///
	keepusing(province city urban_nbs) nogenerate
order province city urban_nbs
sort id year
save "$workingdata\_demo.dta", replace