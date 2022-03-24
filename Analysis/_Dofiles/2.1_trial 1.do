global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

**# Merge the datasets
***********************************************************************
** Merge all the datasets                         
***********************************************************************
use "$workingdata\_demo.dta", clear
merge 1:1 id year using "$workingdata\_labor supply.dta", keep(match) nogenerate
merge m:1 hhid year using "$workingdata\_intergeneration transfer.dta", keep(1 3) nogenerate
keep if inrange(hukou, 2, 3)
keep if inrange(age, 40, 75)

global male_con   "if male==1 & inrange(age, 45, 75)"
global female_con "if male==0 & inrange(age, 40, 75)"

generate age_normal = age - 60 $male_con
replace  age_normal = age - 50 $female_con
generate R = (age_normal>=0)
generate age2 = age ^ 2
generate age3 = age ^ 3

forvalues i = 2/9{
	gen educ_`i' = (educ==`i')
}
forvalues i = 2/7{
	gen marriage_`i' = (marriage==`i')
}
forvalues i = 1/2{
	gen minority_`i'  = (minority ==`i')
	gen communist_`i' = (communist==`i')
}

global cov age2 age3 educ_* marriage_* minority_* communist_*

save "$workingdata\temp_3-23.dta", replace





***********************************************************************
** Effect of age on retirement                        
***********************************************************************
global graphregion  "graphregion(fcolor(gs16) lcolor(gs16)) plotregion(lcolor(gs16) margin(zero))"

* Step 1-1: Retirement Rate by Age
#delimit ;
preserve;
collapse (mean) retire, by(age male) ;
graph twoway (connected retire age $male_con , msymbol(o))  
	(connected retire age $female_con , msymbol(o)) , 
	$graphregion 
	xline(60) xlabel(45(5)75) xline(50)
	title(Average Retirement Rate by Age)
	xtitle(Age) ytitle(Average Retirement Rate);
graph export "$resultspath\Average Retirement Rate by Age.png", as(png) replace;
restore;

* Step 1-2: RD Plot
#delimit ;
rdplot retire age_normal, ci(95)  $male_con
	graph_options($graphregion title("RD Plot of Retirement Rate by Normalized Age"));
graph export "$resultspath\RD Plot of Retirement Rate_male.png", as(png) replace;

#delimit ;
rdplot retire age_normal, ci(95)  $female_con
	graph_options($graphregion title("RD Plot of Retirement Rate by Normalized Age"));
graph export "$resultspath\RD Plot of Retirement Rate_female.png", as(png) replace;

#delimit ;
rdplot retire age_normal, ci(95) 
	graph_options($graphregion title("RD Plot of Retirement Rate by Normalized Age"));
graph export "$resultspath\RD Plot of Retirement Rate_all.png", as(png) replace;

#delimit cr

***********************************************************************
** Effect of retirement on Intergenerational Transfer                       
***********************************************************************
rdrobust transfer_r age_normal, fuzzy(retire) covs($cov)

replace trans_r = 0 if trans_r == .d
rdrobust trans_r age_normal, fuzzy(retire) covs($cov)


