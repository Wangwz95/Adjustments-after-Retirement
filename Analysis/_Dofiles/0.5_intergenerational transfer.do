global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# 2011
***********************************************************************
** 2011 CHARLS: dependent variables (intergenerational transfer)                         
***********************************************************************
use "$rawdatapath\2011\family_transfer.dta", clear
keep householdID ID communityID ce007 ce009_1_1 - ce009_10_4_b ce027 ce029_1_1 - ce029_10_4_b cf001 cf003_1_1_- cf003_28_s2 cg001_1_- cg002_3_

order communityID householdID ID
rename (householdID ID) (hhid id)

generate transfer_r = (ce007==1) if inrange(ce007, 1, 2), after(ce007)
label variable transfer_r "=1, if the hh received transfers from their children last year"

forvalues i = 1/10{
    forvalues j =1/4{
	    replace ce009_`i'_`j'   = . if ce009_`i'_`j'   < 0 
		replace ce009_`i'_`j'_a = . if ce009_`i'_`j'_a < 0
		replace ce009_`i'_`j'_b = . if ce009_`i'_`j'_a < 0
		if `j'==1/2{
		    replace ce009_`i'_`j'_every = . if ce009_`i'_`j'_every < 0
		}
	}
}

forvalues i = 1/10{
    generate cash_reg_`i' = ce009_`i'_1                         if ce009_`i'_1<.
	replace  cash_reg_`i' = ce009_`i'_1_a                       if (ce009_`i'_1_a<.) & (ce009_`i'_1_b>=.)
	replace  cash_reg_`i' = ce009_`i'_1_b                       if (ce009_`i'_1_b<.) & (ce009_`i'_1_a>=.)
	replace  cash_reg_`i' = (ce009_`i'_1_a + ce009_`i'_1_b) / 2 if (ce009_`i'_1_a<.) & (ce009_`i'_1_b< .)
	
	generate supp_reg_`i' = ce009_`i'_2                         if ce009_`i'_2<.
	replace  supp_reg_`i' = ce009_`i'_2_a                       if (ce009_`i'_2_a<.) & (ce009_`i'_2_b>=.)
	replace  supp_reg_`i' = ce009_`i'_2_b                       if (ce009_`i'_2_b<.) & (ce009_`i'_2_a>=.)
	replace  supp_reg_`i' = (ce009_`i'_2_a + ce009_`i'_2_b) / 2 if (ce009_`i'_2_a<.) & (ce009_`i'_2_b< .)
	
	generate cash_nreg_`i' = ce009_`i'_3                         if ce009_`i'_3<. 
	replace  cash_nreg_`i' = ce009_`i'_3_a                       if (ce009_`i'_3_a<.) & (ce009_`i'_3_b>=.)
	replace  cash_nreg_`i' = ce009_`i'_3_b                       if (ce009_`i'_3_b<.) & (ce009_`i'_3_a>=.)
	replace  cash_nreg_`i' = (ce009_`i'_3_a + ce009_`i'_3_b) / 2 if (ce009_`i'_3_a<.) & (ce009_`i'_3_b< .)
	
	generate supp_nreg_`i' = ce009_`i'_4                         if ce009_`i'_4<.     
	replace  supp_nreg_`i' = ce009_`i'_4_a                       if (ce009_`i'_4_a<.) & (ce009_`i'_4_b>=.)
	replace  supp_nreg_`i' = ce009_`i'_4_b                       if (ce009_`i'_4_b<.) & (ce009_`i'_4_a>=.)
	replace  supp_nreg_`i' = (ce009_`i'_4_a + ce009_`i'_4_b) / 2 if (ce009_`i'_4_a<.) & (ce009_`i'_4_b< .)
	
	replace  cash_reg_`i' = cash_reg_`i' * 12 if ce009_`i'_1_every == 1
	replace  cash_reg_`i' = cash_reg_`i' * 4  if ce009_`i'_1_every == 2
	replace  cash_reg_`i' = cash_reg_`i' * 2  if ce009_`i'_1_every == 3

	replace  supp_reg_`i' = supp_reg_`i' * 12 if ce009_`i'_2_every == 1
	replace  supp_reg_`i' = supp_reg_`i' * 4  if ce009_`i'_2_every == 2
	replace  supp_reg_`i' = supp_reg_`i' * 2  if ce009_`i'_2_every == 3
}
egen no_missing1  = rowmiss(cash_reg_*   supp_reg_*)
egen no_missing2  = rowmiss(cash_nreg_*  supp_nreg_*)
egen trans_r_reg  = rowtotal(cash_reg_*  supp_reg_*)
egen trans_r_nreg = rowtotal(cash_nreg_* supp_nreg_*)
egen trans_r      = rowtotal(trans_r_reg trans_r_nreg)
replace trans_r_reg  = .  if no_missing1 == 20
replace trans_r_nreg = .  if no_missing2 == 20
replace trans_r      = .  if trans_r_nreg==. & trans_r_reg==.
replace transfer_r   = 1  if trans_r_nreg!=. | trans_r_reg!=.
replace trans_r_reg  = .d if transfer_r==0
replace trans_r_nreg = .d if transfer_r==0
replace trans_r      = .d if transfer_r==0

drop ce007 ce009_1_1 - ce009_10_4_b cash_reg_1 - no_missing2
order trans_r trans_r_reg trans_r_nreg, after(transfer_r)
label variable trans_r      "Total amount of intergenerational transfer from children last year"
label variable trans_r_reg  "Total amount of regular intergenerational transfer from children last year"
label variable trans_r_nreg "Total amount of nonregular intergenerational transfer from children last year"

generate transfer_g = (ce027==1) if inrange(ce027, 1, 2), after(ce027)
label variable transfer_g "=1, if the hh provided economic support to their children last year"

forvalues i = 1/10{
    forvalues j =1/4{
	    replace ce029_`i'_`j'   = . if ce029_`i'_`j'   < 0 
		replace ce029_`i'_`j'_a = . if ce029_`i'_`j'_a < 0
		replace ce029_`i'_`j'_b = . if ce029_`i'_`j'_a < 0
		if `j'==1/2{
		    replace ce029_`i'_`j'_every = . if ce029_`i'_`j'_every < 0
		}
	}
}
forvalues i = 1/10{
    generate cash_reg_`i' = ce029_`i'_1                         if ce029_`i'_1<.
	replace  cash_reg_`i' = ce029_`i'_1_a                       if (ce029_`i'_1_a<.) & (ce029_`i'_1_b>=.)
	replace  cash_reg_`i' = ce029_`i'_1_b                       if (ce029_`i'_1_b<.) & (ce029_`i'_1_a>=.)
	replace  cash_reg_`i' = (ce029_`i'_1_a + ce029_`i'_1_b) / 2 if (ce029_`i'_1_a<.) & (ce029_`i'_1_b< .)
	
	generate supp_reg_`i' = ce029_`i'_2                         if ce029_`i'_2<.
	replace  supp_reg_`i' = ce029_`i'_2_a                       if (ce029_`i'_2_a<.) & (ce029_`i'_2_b>=.)
	replace  supp_reg_`i' = ce029_`i'_2_b                       if (ce029_`i'_2_b<.) & (ce029_`i'_2_a>=.)
	replace  supp_reg_`i' = (ce029_`i'_2_a + ce029_`i'_2_b) / 2 if (ce029_`i'_2_a<.) & (ce029_`i'_2_b< .)
	
	generate cash_nreg_`i' = ce029_`i'_3                         if ce029_`i'_3<. 
	replace  cash_nreg_`i' = ce029_`i'_3_a                       if (ce029_`i'_3_a<.) & (ce029_`i'_3_b>=.)
	replace  cash_nreg_`i' = ce029_`i'_3_b                       if (ce029_`i'_3_b<.) & (ce029_`i'_3_a>=.)
	replace  cash_nreg_`i' = (ce029_`i'_3_a + ce029_`i'_3_b) / 2 if (ce029_`i'_3_a<.) & (ce029_`i'_3_b< .)
	
	generate supp_nreg_`i' = ce029_`i'_4                         if ce029_`i'_4<.     
	replace  supp_nreg_`i' = ce029_`i'_4_a                       if (ce029_`i'_4_a<.) & (ce029_`i'_4_b>=.)
	replace  supp_nreg_`i' = ce029_`i'_4_b                       if (ce029_`i'_4_b<.) & (ce029_`i'_4_a>=.)
	replace  supp_nreg_`i' = (ce029_`i'_4_a + ce029_`i'_4_b) / 2 if (ce029_`i'_4_a<.) & (ce029_`i'_4_b< .)
	
	replace  cash_reg_`i' = cash_reg_`i' * 12 if ce029_`i'_1_every == 1
	replace  cash_reg_`i' = cash_reg_`i' * 4  if ce029_`i'_1_every == 2
	replace  cash_reg_`i' = cash_reg_`i' * 2  if ce029_`i'_1_every == 3

	replace  supp_reg_`i' = supp_reg_`i' * 12 if ce029_`i'_2_every == 1
	replace  supp_reg_`i' = supp_reg_`i' * 4  if ce029_`i'_2_every == 2
	replace  supp_reg_`i' = supp_reg_`i' * 2  if ce029_`i'_2_every == 3
}

egen no_missing1  = rowmiss(cash_reg_*   supp_reg_*)
egen no_missing2  = rowmiss(cash_nreg_*  supp_nreg_*)
egen trans_g_reg  = rowtotal(cash_reg_*  supp_reg_*)
egen trans_g_nreg = rowtotal(cash_nreg_* supp_nreg_*)
egen trans_g      = rowtotal(trans_g_reg trans_g_nreg)
replace trans_g_reg  = .  if no_missing1 == 20
replace trans_g_nreg = .  if no_missing2 == 20
replace trans_g      = .  if trans_g_nreg==. & trans_g_reg==.
replace transfer_g   = 1  if trans_g_nreg!=. | trans_g_reg!=.
replace trans_g_reg  = .d if transfer_g==0
replace trans_g_nreg = .d if transfer_g==0
replace trans_g      = .d if transfer_g==0

drop ce027 ce029_1_1 - ce029_10_4_b cash_reg_1 - no_missing2
order trans_g trans_g_reg trans_g_nreg, after(transfer_g)
label variable trans_g      "Total amount of intergenerational transfer to children last year"
label variable trans_g_reg  "Total amount of regular intergenerational transfer to children last year"
label variable trans_g_nreg "Total amount of nonregular intergenerational transfer to children last year"

generate trans_n = trans_r - trans_g if trans_r<. & trans_g<.,  after(trans_g_nreg)
replace  trans_n = trans_r           if trans_r<. & trans_g==.d
replace  trans_n = -1 * trans_g      if trans_g<. & trans_r==.d
label variable trans_n "= trans_r - trans_g "
order transfer_r transfer_g trans_r trans_g trans_n trans_r_reg trans_r_nreg trans_g_reg trans_g_nreg, after(id)

generate care_grandchild = (cf001==1) if inrange(cf001, 1, 2), after(cf001)
label variable care_grandchild "=1, if the hh spent time taking care of grandchildren last year"

forvalues i = 1/8{
    generate carehour_me_`i' = cf003_1_`i'_ * cf003_2_`i'_
	generate carehour_sp_`i' = cf003_3_`i'_ * cf003_4_`i'_
}
forvalues i = 26/28{
    generate carehour_me_`i' = cf003_1_`i'_ * cf003_2_`i'_
	generate carehour_sp_`i' = cf003_3_`i'_ * cf003_4_`i'_
}
egen carehour    = rowmax(carehour_*)
egen carehour_me = rowmax(carehour_me_*)
egen carehour_sp = rowmax(carehour_sp_*)
label variable carehour    "Total hours (household) spending on taking care of children last year"
label variable carehour_me "Total hours (the ind) spending on taking care of children last year"
label variable carehour_sp "Total hours (the ind's spouse) spending on taking care of children last year"
order carehour*, after(care_grandchild)
drop carehour_me_* carehour_sp_* cf*

generate year = 2011, before(communityID)
label variable year "Survey year"

replace  hhid = hhid + "0"
generate temp = substr(id, 10, 2), after(id)
replace  id   = hhid + temp
drop temp

save "$workingdata\intergeneration transfer_2011.dta", replace

**# 2013
***********************************************************************
** 2013 CHARLS: dependent variables (intergenerational transfer)                         
***********************************************************************
use "$rawdatapath\2013\Family_Transfer.dta", clear
keep ID householdID communityID ce009_1_1_- ce010_4_7_bracket_min ce029_1_1_ - ce030_4_6_bracket_min cf001 cf003_1_1_ - cf003_4_11_
order communityID householdID ID
rename (householdID ID) (hhid id)

forvalues j = 1/7{
    forvalues i =1/4{
	    replace ce009_`i'_`j'_  		  = . if ce009_`i'_`j'_            < 0 
		replace ce010_`i'_`j'_bracket_max = . if ce010_`i'_`j'_bracket_max < 0
		replace ce010_`i'_`j'_bracket_min = . if ce010_`i'_`j'_bracket_min < 0
		
		replace ce009_`i'_`j'_ = (ce010_`i'_`j'_bracket_max + ce010_`i'_`j'_bracket_min) / 2 ///
			if ce010_`i'_`j'_bracket_max<. & ce010_`i'_`j'_bracket_min<.
		replace ce009_`i'_`j'_ = ce010_`i'_`j'_bracket_max ///
			if ce010_`i'_`j'_bracket_max<. & ce010_`i'_`j'_bracket_min>=.
		replace ce009_`i'_`j'_ = ce010_`i'_`j'_bracket_min ///
			if ce010_`i'_`j'_bracket_min<. & ce010_`i'_`j'_bracket_max>=.
	}
}

egen no_missing1    = rowmiss(ce009_1_* ce009_3_*)
egen no_missing2    = rowmiss(ce009_2_* ce009_4_*)

egen     trans_r        = rowtotal(ce009_1_* ce009_3_*)
egen     trans_r_reg    = rowtotal(ce009_2_* ce009_4_*)
replace  trans_r        = .d  if no_missing1 == 24
replace  trans_r_reg    = .d  if no_missing2 == 24
replace  trans_r        = .d  if trans_r     == 0
replace  trans_r_reg    = .d  if trans_r_reg == 0
replace  trans_r        = trans_r_reg if trans_r==.d & trans_r_reg!=.d
generate trans_r_nreg   = trans_r - trans_r_reg
replace  trans_r_nreg   = .d  if trans_r_nreg==.
generate transfer_r     = (trans_r!=.d)
label variable transfer_r   "=1, if the hh received transfers from their children last year"
label variable trans_r      "Total amount of intergenerational transfer from children last year"
label variable trans_r_reg  "Total amount of regular intergenerational transfer from children last year"
label variable trans_r_nreg "Total amount of nonregular intergenerational transfer from children last year"
order transfer_r trans_r trans_r_reg trans_r_nreg, after(id)

drop ce009* ce010* no_missing*


forvalues j = 1/6{
    forvalues i =1/4{
	    replace ce029_`i'_`j'_   		  = . if ce029_`i'_`j'_            < 0 
		replace ce030_`i'_`j'_bracket_max = . if ce030_`i'_`j'_bracket_max < 0
		replace ce030_`i'_`j'_bracket_min = . if ce030_`i'_`j'_bracket_min < 0
		
		replace ce029_`i'_`j'_ = (ce030_`i'_`j'_bracket_max + ce030_`i'_`j'_bracket_min) / 2 ///
			if ce030_`i'_`j'_bracket_max<. & ce030_`i'_`j'_bracket_min<.
		replace ce029_`i'_`j'_ = ce030_`i'_`j'_bracket_max ///
			if ce030_`i'_`j'_bracket_max<. & ce030_`i'_`j'_bracket_min>=.
		replace ce029_`i'_`j'_ = ce030_`i'_`j'_bracket_min ///
			if ce030_`i'_`j'_bracket_min<. & ce030_`i'_`j'_bracket_max>=.
	}
}

egen no_missing1    = rowmiss(ce029_1_* ce029_3_*)
egen no_missing2    = rowmiss(ce029_2_* ce029_4_*)

egen     trans_g        = rowtotal(ce029_1_* ce029_3_*)
egen     trans_g_reg    = rowtotal(ce029_2_* ce029_4_*)
replace  trans_g        = .d  if no_missing1 == 24
replace  trans_g_reg    = .d  if no_missing2 == 24
replace  trans_g        = .d  if trans_g     == 0
replace  trans_g_reg    = .d  if trans_g_reg == 0
replace  trans_g        = trans_g_reg if trans_g==.d & trans_g_reg!=.d
generate trans_g_nreg   = trans_g - trans_g_reg
replace  trans_g_nreg   = .d  if trans_g_nreg==.
generate transfer_g     = (trans_g!=.d)

label variable transfer_g   "=1, if the hh provided economic support to their children last year"
label variable trans_g      "Total amount of intergenerational transfer to children last year"
label variable trans_g_reg  "Total amount of regular intergenerational transfer to children last year"
label variable trans_g_nreg "Total amount of nonregular intergenerational transfer to children last year"

drop ce029* ce030* no_missing*

generate trans_n = trans_r - trans_g if trans_r<. & trans_g<.,  after(trans_g_nreg)
replace  trans_n = trans_r           if trans_r<. & trans_g==.d
replace  trans_n = -1 * trans_g      if trans_g<. & trans_r==.d
replace  trans_n = .d                if trans_n==.
label variable trans_n "= trans_r - trans_g "
order transfer_r transfer_g trans_r trans_g trans_n trans_r_reg trans_r_nreg trans_g_reg trans_g_nreg, after(id)


generate care_grandchild = (cf001==1) if inrange(cf001, 1, 2), after(cf001)
label variable care_grandchild "=1, if the hh spent time taking care of grandchildren last year"

forvalues i = 1/9{
    generate carehour_me_`i' = cf003_1_`i'_ * cf003_2_`i'_
	generate carehour_sp_`i' = cf003_3_`i'_ * cf003_4_`i'_
}
    generate carehour_me_11 = cf003_1_11_ * cf003_2_11_
	generate carehour_sp_11 = cf003_3_11_ * cf003_4_11_


egen carehour    = rowmax(carehour_*)
egen carehour_me = rowmax(carehour_me_*)
egen carehour_sp = rowmax(carehour_sp_*)
label variable carehour    "Total hours (household) spending on taking care of children last year"
label variable carehour_me "Total hours (the ind) spending on taking care of children last year"
label variable carehour_sp "Total hours (the ind's spouse) spending on taking care of children last year"
order carehour*, after(care_grandchild)
drop carehour_me_* carehour_sp_* cf*

generate year = 2013, before(communityID)
label variable year "Survey year"

save "$workingdata\intergeneration transfer_2013.dta", replace

**# 2015
***********************************************************************
** 2015 CHARLS: dependent variables (intergenerational transfer)                         
***********************************************************************
use "$rawdatapath\2015\Family_Transfer.dta", clear
keep ID householdID communityID ce009_1_1_ - ce010_4_11_bracket_min ce029_1_1_ - ce030_4_6_bracket_min cf001 cf003_1_1_ - cf003_4_13_
order communityID householdID ID
rename (householdID ID) (hhid id)

gen ce010_1_6_bracket_min = .
forvalues j = 1/7{
    forvalues i =1/4{
	    replace ce009_`i'_`j'_  		  = . if ce009_`i'_`j'_            < 0 
		replace ce010_`i'_`j'_bracket_max = . if ce010_`i'_`j'_bracket_max < 0
		replace ce010_`i'_`j'_bracket_min = . if ce010_`i'_`j'_bracket_min < 0
		
		replace ce009_`i'_`j'_ = (ce010_`i'_`j'_bracket_max + ce010_`i'_`j'_bracket_min) / 2 ///
			if ce010_`i'_`j'_bracket_max<. & ce010_`i'_`j'_bracket_min<.
		replace ce009_`i'_`j'_ = ce010_`i'_`j'_bracket_max ///
			if ce010_`i'_`j'_bracket_max<. & ce010_`i'_`j'_bracket_min>=.
		replace ce009_`i'_`j'_ = ce010_`i'_`j'_bracket_min ///
			if ce010_`i'_`j'_bracket_min<. & ce010_`i'_`j'_bracket_max>=.
	}
}

egen no_missing1    = rowmiss(ce009_1_* ce009_3_*)
egen no_missing2    = rowmiss(ce009_2_* ce009_4_*)

egen     trans_r        = rowtotal(ce009_1_* ce009_3_*)
egen     trans_r_reg    = rowtotal(ce009_2_* ce009_4_*)
replace  trans_r        = .d  if no_missing1 == 32
replace  trans_r_reg    = .d  if no_missing2 == 32
replace  trans_r        = .d  if trans_r     == 0
replace  trans_r_reg    = .d  if trans_r_reg == 0
replace  trans_r        = trans_r_reg if trans_r==.d & trans_r_reg!=.d
generate trans_r_nreg   = trans_r - trans_r_reg
replace  trans_r_nreg   = .d  if trans_r_nreg==.
generate transfer_r     = (trans_r!=.d)

label variable transfer_r   "=1, if the hh received transfers from their children last year"
label variable trans_r      "Total amount of intergenerational transfer from children last year"
label variable trans_r_reg  "Total amount of regular intergenerational transfer from children last year"
label variable trans_r_nreg "Total amount of nonregular intergenerational transfer from children last year"
order transfer_r trans_r trans_r_reg trans_r_nreg, after(id)

drop ce009* ce010* no_missing*

gen ce030_2_5_bracket_min=.
gen ce030_1_6_bracket_max=.
gen ce030_1_6_bracket_min=.
gen ce030_2_6_bracket_max=.
gen ce030_2_6_bracket_min=.
forvalues j = 1/6{
    forvalues i =1/4{
	    replace ce029_`i'_`j'_   		  = . if ce029_`i'_`j'_            < 0 
		replace ce030_`i'_`j'_bracket_max = . if ce030_`i'_`j'_bracket_max < 0
		replace ce030_`i'_`j'_bracket_min = . if ce030_`i'_`j'_bracket_min < 0
		
		replace ce029_`i'_`j'_ = (ce030_`i'_`j'_bracket_max + ce030_`i'_`j'_bracket_min) / 2 ///
			if ce030_`i'_`j'_bracket_max<. & ce030_`i'_`j'_bracket_min<.
		replace ce029_`i'_`j'_ = ce030_`i'_`j'_bracket_max ///
			if ce030_`i'_`j'_bracket_max<. & ce030_`i'_`j'_bracket_min>=.
		replace ce029_`i'_`j'_ = ce030_`i'_`j'_bracket_min ///
			if ce030_`i'_`j'_bracket_min<. & ce030_`i'_`j'_bracket_max>=.
	}
}

egen no_missing1    = rowmiss(ce029_1_* ce029_3_*)
egen no_missing2    = rowmiss(ce029_2_* ce029_4_*)

egen     trans_g        = rowtotal(ce029_1_* ce029_3_*)
egen     trans_g_reg    = rowtotal(ce029_2_* ce029_4_*)
replace  trans_g        = .d  if no_missing1 == 32
replace  trans_g_reg    = .d  if no_missing2 == 32
replace  trans_g        = .d  if trans_g     == 0
replace  trans_g_reg    = .d  if trans_g_reg == 0
replace  trans_g        = trans_g_reg if trans_g==.d & trans_g_reg!=.d
generate trans_g_nreg   = trans_g - trans_g_reg
replace  trans_g_nreg   = .d  if trans_g_nreg==.
generate transfer_g     = (trans_g!=.d)

label variable transfer_g   "=1, if the hh provided economic support to their children last year"
label variable trans_g      "Total amount of intergenerational transfer to children last year"
label variable trans_g_reg  "Total amount of regular intergenerational transfer to children last year"
label variable trans_g_nreg "Total amount of nonregular intergenerational transfer to children last year"

drop ce029* ce030* no_missing*

generate trans_n = trans_r - trans_g if trans_r<. & trans_g<.,  after(trans_g_nreg)
replace  trans_n = trans_r           if trans_r<. & trans_g==.d
replace  trans_n = -1 * trans_g      if trans_g<. & trans_r==.d
replace  trans_n = .d                if trans_n==.
label variable trans_n "= trans_r - trans_g "
order transfer_r transfer_g trans_r trans_g trans_n trans_r_reg trans_r_nreg trans_g_reg trans_g_nreg, after(id)


generate care_grandchild = (cf001==1) if inrange(cf001, 1, 2), after(cf001)
label variable care_grandchild "=1, if the hh spent time taking care of grandchildren last year"

forvalues i = 1/11{
    generate carehour_me_`i' = cf003_1_`i'_ * cf003_2_`i'_
	generate carehour_sp_`i' = cf003_3_`i'_ * cf003_4_`i'_
}
    generate carehour_me_13 = cf003_1_13_ * cf003_2_13_
	generate carehour_sp_13 = cf003_3_13_ * cf003_4_13_


egen carehour    = rowmax(carehour_*)
egen carehour_me = rowmax(carehour_me_*)
egen carehour_sp = rowmax(carehour_sp_*)
label variable carehour    "Total hours (household) spending on taking care of children last year"
label variable carehour_me "Total hours (the ind) spending on taking care of children last year"
label variable carehour_sp "Total hours (the ind's spouse) spending on taking care of children last year"
order carehour*, after(care_grandchild)
drop carehour_me_* carehour_sp_* cf*

generate year = 2015, before(communityID)
label variable year "Survey year"

save "$workingdata\intergeneration transfer_2015.dta", replace

**# 2018
***********************************************************************
** 2018 CHARLS: dependent variables (intergenerational transfer)                         
***********************************************************************
use "$rawdatapath\2018\Family_Transfer.dta", clear
keep ID householdID communityID ce009_1_1_ - ce009_4_11__max ce029_1_1_ - ce029_4_8__max cf001 cf003_1_1_ - cf003_4_11_
order communityID householdID ID
rename (householdID ID) (hhid id)

forvalues i = 1/4{
    gen ce009_`i'_9__max=.
	gen ce009_`i'_9__min=.
}

forvalues j = 1/11{
    forvalues i =1/4{
	    replace ce009_`i'_`j'_  		  = . if ce009_`i'_`j'_     < 0 
		replace ce009_`i'_`j'__max        = . if ce009_`i'_`j'__max < 0
		replace ce009_`i'_`j'__min        = . if ce009_`i'_`j'__min < 0
		
		replace ce009_`i'_`j'_ = (ce009_`i'_`j'__max + ce009_`i'_`j'__min) / 2 ///
			if ce009_`i'_`j'__max<. & ce009_`i'_`j'__min<.
		replace ce009_`i'_`j'_ = ce009_`i'_`j'__max ///
			if ce009_`i'_`j'__max<. & ce009_`i'_`j'__min>=.
		replace ce009_`i'_`j'_ = ce009_`i'_`j'__min ///
			if ce009_`i'_`j'__min<. & ce009_`i'_`j'__max>=.
	}
}
drop ce009_1_1__min - ce009_4_11__max

egen no_missing1    = rowmiss(ce009_1_* ce009_3_*)
egen no_missing2    = rowmiss(ce009_2_* ce009_4_*)

egen     trans_r        = rowtotal(ce009_1_* ce009_3_*)
egen     trans_r_reg    = rowtotal(ce009_2_* ce009_4_*)
replace  trans_r        = .d  if no_missing1 == 34
replace  trans_r_reg    = .d  if no_missing2 == 34
replace  trans_r        = .d  if trans_r     == 0
replace  trans_r_reg    = .d  if trans_r_reg == 0
replace  trans_r        = trans_r_reg if trans_r==.d & trans_r_reg!=.d
generate trans_r_nreg   = trans_r - trans_r_reg
replace  trans_r_nreg   = .d  if trans_r_nreg==.
generate transfer_r     = (trans_r!=.d)

label variable transfer_r   "=1, if the hh received transfers from their children last year"
label variable trans_r      "Total amount of intergenerational transfer from children last year"
label variable trans_r_reg  "Total amount of regular intergenerational transfer from children last year"
label variable trans_r_nreg "Total amount of nonregular intergenerational transfer from children last year"
order transfer_r trans_r trans_r_reg trans_r_nreg, after(id)

drop ce009* no_missing*


forvalues j = 1/6{
    forvalues i =1/4{
	    replace ce029_`i'_`j'_     = . if ce029_`i'_`j'_     < 0 
		replace ce029_`i'_`j'__max = . if ce029_`i'_`j'__max < 0
		replace ce029_`i'_`j'__min = . if ce029_`i'_`j'__min < 0
		
		replace ce029_`i'_`j'_ = (ce029_`i'_`j'__max + ce029_`i'_`j'__min) / 2 ///
			if ce029_`i'_`j'__max<. & ce029_`i'_`j'__min<.
		replace ce029_`i'_`j'_ = ce029_`i'_`j'__max ///
			if ce029_`i'_`j'__max<. & ce029_`i'_`j'__min>=.
		replace ce029_`i'_`j'_ = ce029_`i'_`j'__min ///
			if ce029_`i'_`j'__min<. & ce029_`i'_`j'__max>=.
	}
}

drop ce029_1_1__min - ce029_4_8__max

egen no_missing1    = rowmiss(ce029_1_* ce029_3_*)
egen no_missing2    = rowmiss(ce029_2_* ce029_4_*)

egen     trans_g        = rowtotal(ce029_1_* ce029_3_*)
egen     trans_g_reg    = rowtotal(ce029_2_* ce029_4_*)
replace  trans_g        = .d  if no_missing1 == 32
replace  trans_g_reg    = .d  if no_missing2 == 32
replace  trans_g        = .d  if trans_g     == 0
replace  trans_g_reg    = .d  if trans_g_reg == 0
replace  trans_g        = trans_g_reg if trans_g==.d & trans_g_reg!=.d
generate trans_g_nreg   = trans_g - trans_g_reg
replace  trans_g_nreg   = .d  if trans_g_nreg==.
generate transfer_g     = (trans_g!=.d)

label variable transfer_g   "=1, if the hh provided economic support to their children last year"
label variable trans_g      "Total amount of intergenerational transfer to children last year"
label variable trans_g_reg  "Total amount of regular intergenerational transfer to children last year"
label variable trans_g_nreg "Total amount of nonregular intergenerational transfer to children last year"

drop ce029* no_missing*

generate trans_n = trans_r - trans_g if trans_r<. & trans_g<.,  after(trans_g_nreg)
replace  trans_n = trans_r           if trans_r<. & trans_g==.d
replace  trans_n = -1 * trans_g      if trans_g<. & trans_r==.d
replace  trans_n = .d                if trans_n==.
label variable trans_n "= trans_r - trans_g "
order transfer_r transfer_g trans_r trans_g trans_n trans_r_reg trans_r_nreg trans_g_reg trans_g_nreg, after(id)


generate care_grandchild = (cf001==1) if inrange(cf001, 1, 2), after(cf001)
label variable care_grandchild "=1, if the hh spent time taking care of grandchildren last year"

forvalues i = 1/11{
    generate carehour_me_`i' = cf003_1_`i'_ * cf003_2_`i'_
	generate carehour_sp_`i' = cf003_3_`i'_ * cf003_4_`i'_
}

egen carehour    = rowmax(carehour_*)
egen carehour_me = rowmax(carehour_me_*)
egen carehour_sp = rowmax(carehour_sp_*)
label variable carehour    "Total hours (household) spending on taking care of children last year"
label variable carehour_me "Total hours (the ind) spending on taking care of children last year"
label variable carehour_sp "Total hours (the ind's spouse) spending on taking care of children last year"
order carehour*, after(care_grandchild)
drop carehour_me_* carehour_sp_* cf*

generate year = 2018, before(communityID)
label variable year "Survey year"

save "$workingdata\intergeneration transfer_2018.dta", replace

**# Append
***********************************************************************
** Append the four waves and impute the missing values                          
***********************************************************************
use          "$workingdata\intergeneration transfer_2011.dta", clear
append using "$workingdata\intergeneration transfer_2013.dta"
append using "$workingdata\intergeneration transfer_2015.dta"
append using "$workingdata\intergeneration transfer_2018.dta"
sort id year

save "$workingdata\_intergeneration transfer.dta", replace
