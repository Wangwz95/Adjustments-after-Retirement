global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

***********************************************************************
** Harmonized CHARLS: Get information on labor supply and retirement                           
***********************************************************************

#delimit ;
use "$rawdatapath\H_CHARLS_D_Data.dta", clear;
keep ID r1work r2work r3work r4work s1work s2work s3work s4work 
	 r1lbrf_c r2lbrf_c r3lbrf_c r4lbrf_c s1lbrf_c s2lbrf_c s3lbrf_c s4lbrf_c 
	 r1slfemp r2slfemp r3slfemp r4slfemp s1slfemp s2slfemp s3slfemp s4slfemp 
	 r1jhourtot r2jhourtot r3jhourtot r4jhourtot s1jhourtot s2jhourtot s3jhourtot s4jhourtot 
	 r1jweeks_c r2jweeks_c r3jweeks_c r4jweeks_c s1jweeks_c s2jweeks_c s3jweeks_c s4jweeks_c 
	 r1retemp r2retemp r3retemp r4retemp s1retemp s2retemp s3retemp s4retemp 
	 r1fret_c r2fret_c r3fret_c r4fret_c s1fret_c s2fret_c s3fret_c s4fret_c 
	 r1retyr r2retyr r3retyr r4retyr s1retyr s2retyr s3retyr s4retyr 
	 r1wkaftret r2wkaftret r3wkaftret r4wkaftret s1wkaftret s2wkaftret s3wkaftret s4wkaftret;
	 
reshape long r@work s@work r@lbrf_c s@lbrf_c r@slfemp s@slfemp 
		r@jhourtot s@jhourtot r@jweeks_c s@jweeks_c r@retemp s@retemp 
		r@fret_c s@fret_c r@retyr s@retyr r@wkaftret s@wkaftret, i(ID) j(year);
		
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
rename (rwork swork rlbrf_c slbrf_c rslfemp sslfemp rjhourtot sjhourtot rjweeks_c sjweeks_c)
	   (work work_s jobstatus jobstatus_s selfemp selfemp_s workhour workhour_s workweek workweek_s);
rename (rretemp rfret_c rretyr rwkaftret sretemp sfret_c sretyr swkaftret) 
	   (retire_jobstatus retire yor wkaftret retire_jobstatus_s retire_s yor_s wkaftret_s);
label variable id					"Person Identifier: 12-char";
label variable work         		"=1 if Currently Working";
label variable work_s       		"=1 if (Spouse) Currently Working";
label variable jobstatus    		"Labor Force Status";
label variable jobstatus_s 			"(Spousal) Labor Force Status";
label variable selfemp      		"=1, if Self-Employed (Non-Agricultural)";
label variable selfemp_s    		"=1, if (Spouse) Self-Employed (Non-Agricultural)";
label variable workhour     		"Total Hours Worked per Week";
label variable workhour_s       	"(Spouse) Total Hours Worked per Week";
label variable workweek     		"Weeks Worked per Year on Main Job";
label variable workweek_s       	"(Spouse) Weeks Worked per Year on Main Job";
label variable retire_jobstatus 	"Whether Retired (from Labor Force Status variable)";
label variable retire				"Whether Retired";
label variable yor					"Year of Retirement";
label variable wkaftret				"Worked after Processed Retirement";
label variable retire_jobstatus_s   "(Spouse) Whether Retired (from Labor Force Status variable)";
label variable retire_s				"(Spouse) Whether Retired";
label variable yor_s				"(Spouse) Year of Retirement";
label variable wkaftret_s			"(Spouse) Worked after Processed Retirement";

order id work jobstatus selfemp workhour workweek retire_jobstatus retire yor wkaftret
	  work_s jobstatus_s selfemp_s workhour_s workweek_s retire_jobstatus_s retire_s yor_s wkaftret_s;
order year, before(id);
sort id year;

save "$workingdata\_employment_long.dta", replace;