global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

***********************************************************************
** Harmonized CHARLS: Get information on individual and hh income                          
***********************************************************************

#delimit ;
use "$rawdatapath\H_CHARLS_D_Data.dta", clear;
keep ID r1itearn r2itearn r3itearn r4itearn s1itearn s2itearn s3itearn s4itearn 
	 hh1itsemp hh2itsemp hh3itsemp hh4itsemp 
	 hh1irent hh2irent hh3irent hh4irent hh1icap hh2icap hh3icap hh4icap 
	 r1ipena r2ipena r3ipena r4ipena s1ipena s2ipena s3ipena s4ipena 
	 r1ipubpen r2ipubpen r3ipubpen r4ipubpen s1ipubpen s2ipubpen s3ipubpen s4ipubpen 
	 r1ipen r2ipen r3ipen r4ipen s1ipen s2ipen s3ipen s4ipen 
	 r1igxfr r2igxfr r3igxfr r4igxfr s1igxfr s2igxfr s3igxfr s4igxfr 
	 hh1igxfri hh2igxfri hh3igxfri hh4igxfri hh1igxfr hh2igxfr hh3igxfr hh4igxfr 
	 r1iothr r2iothr r3iothr r4iothr s1iothr s2iothr s3iothr s4iothr 
	 hh1itot hh2itot hh3itot hh4itot hh1cfood hh2cfood hh3cfood hh4cfood 
	 hh1cnf1m hh2cnf1m hh3cnf1m hh4cnf1m hh1cnf1y hh2cnf1y hh3cnf1y hh4cnf1y 
	 hh1ctot hh2ctot hh3ctot hh4ctot hh1cperc hh2cperc hh3cperc hh4cperc;
	 
reshape long r@itearn s@itearn hh@itsemp hh@irent hh@icap r@ipena s@ipena r@ipubpen s@ipubpen 
		r@ipen s@ipen r@igxfr s@igxfr hh@igxfri hh@igxfr r@iothr s@iothr 
		hh@itot hh@cfood hh@cnf1m hh@cnf1y hh@ctot hh@cperc, i(ID) j(year);
				
replace year = 2011 if year==1;
replace year = 2013 if year==2;
replace year = 2015 if year==3;
replace year = 2018 if year==4;
sort ID year;
label values year .;
label define wave 2011 "2011.w1" 2013 "2013.w2" 2015 "2015.w3" 2018 "2018.w4";
label values year wave;
label variable year "Survey Year";

rename ID id;
rename (ritearn sitearn hhitsemp hhirent hhicap ripena sipena ripubpen sipubpen)
	   (earnings earnings_s hhsemp hhrent hhcapital pension_pri pension_pri_s pension_pub pension_pub_s);
rename (ripen sipen rigxfr sigxfr hhigxfri hhigxfr riothr siothr) 
	   (pension pension_s trans_gov trans_gov_s hhtrans_gov hhtrans_pub inc_other inc_other_s);
rename (hhitot hhcfood hhcnf1m hhcnf1y hhctot hhcperc) 
	   (hhinc hhfood hhnonfood_month hhnonfood_tol_year hhconsumption hhpcconsumption);
	   
label variable earnings 			"Earnings after Tax";
label variable earnings_s			"(Spousal) Earnings after Tax";
label variable hhsemp 				"Household Self-Employed Income after Tax";
label variable hhrent 				"Household Rental Income before Tax";
label variable hhcapital 			"Household Total Capital Income";
label variable pension_pri 			"Private Pension from Work Module before Bax";
label variable pension_pri_s 		"(Spousal) Private Pension from Work Module before Bax";
label variable pension_pub 			"Public Pension from Work Module";
label variable pension_pub_s 		"(Spousal) Public Pension from Work Module";
label variable pension 				"Total Pension Income";
label variable pension_s 			"(Spousal) Total Pension Income";
label variable trans_gov 			"Government Transfer";
label variable trans_gov_s			"(Spousal) Government Transfer";
label variable hhtrans_gov 			"Household Government Transfer Income";
label variable hhtrans_pub 			"Household Government/Public Transfer Income";
label variable inc_other 			"Other Income";
label variable inc_other_s 			"(Spousal) Other Income";
label variable hhinc 				"Household Total Household Income";
label variable hhfood 				"Household Food Consumption, Past 7 Days";
label variable hhnonfood_month		"Household Non-Food Consumption, Last Month";
label variable hhnonfood_tol_year 	"Household Other Non-Food Consumption, Past Year";
label variable hhconsumption 	    "Total Household Consumption";
label variable hhpcconsumption 		"Total Household per Capita Consumption";

egen inc = rowtotal(earnings pension trans_gov inc_other);
egen temp = rowmiss(earnings pension trans_gov inc_other);
replace inc = . if temp == 4;
egen inc_s = rowtotal(earnings_s pension_s trans_gov_s inc_other_s);
egen temp_s = rowmiss(earnings_s pension_s trans_gov_s inc_other_s);
replace inc_s = . if temp_s == 4;
label variable inc   "Individual Total Income";
label variable inc_s "(Spousal) Individual Total Income";
drop temp*;

order year id inc earnings pension trans_gov inc_other pension_pri pension_pub 
	  hhinc hhsemp hhrent hhcapital hhtrans_gov hhtrans_pub 
	  hhfood hhnonfood_month hhnonfood_tol_year hhconsumption hhpcconsumption 
	  inc_s earnings_s pension_s trans_gov_s inc_other_s pension_pri_s pension_pub_s;

save "$workingdata\_income and consumption_long.dta", replace;


