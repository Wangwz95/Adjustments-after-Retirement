global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

***********************************************************************
** Harmonized CHARLS: Get the basic demographic variables                            
***********************************************************************

#delimit ;
use "$rawdatapath\H_CHARLS_D_Data.dta", clear;

keep householdID community ID s1id s2id s3id s4id rabyear s1byear s2byear s3byear s4byear 
ragender raeduc_c s1educ_c s2educ_c s3educ_c s4educ_c raeducl s1educl s2educl s3educl s4educl 
r1mstat r2mstat r3mstat r4mstat s1mstat s2mstat s3mstat s4mstat rabplace_c 
s1bplace_c s2bplace_c s3bplace_c s4bplace_c r1hukou r2hukou r3hukou r4hukou 
s1hukou s2hukou s3hukou s4hukou h1rural h2rural h3rural h4rural;

reshape long s@id s@byear s@educ_c s@educl r@mstat s@mstat s@bplace_c r@hukou s@hukou h@rural, i(ID) j(year);
replace year = 2011 if year==1;
replace year = 2013 if year==2;
replace year = 2015 if year==3;
replace year = 2018 if year==4;
sort ID year;
label values year .;
label define wave 2011 "2011.w1" 2013 "2013.w2" 2015 "2015.w3" 2018 "2018.w4";
label values year wave;

rename household hhid;
rename (rabyear ragender raeducl raeduc_c rabplace_c rmstat rhukou hrural)
	   (yob gender educ4 educ pob marriage hukou rural);
rename (ID sid sbyear seduc_c seducl smstat sbplace_c shukou) 
	   (id id_s yob_s educ_s educ4_s marriage_s pob_s hukou_s);
order communityID hhid year id gender yob educ educ4 hukou marriage rural pob 
	  id_s yob_s educ_s educ4_s hukou_s marriage_s pob_s;

label variable year          "Survey Year";
label variable communityID   "Community ID: 7-char";
label variable hhid          "Household ID: 10-char";
label variable id		     "Person Identifier: 12-char";
label variable gender        "Gender";
label variable yob           "Year of Birth";
label variable educ          "Education: 10 Levels";
label variable educ4 	     "Education: 4 Levels";
label variable hukou 	     "Hukou Status";
label variable marriage      "Marriage Status";
label variable rural 	     "=1, if the Household Lives in the rural region";
label variable pob           "Place of Birth";
label variable id_s		     "(Spousal) Person Identifier: 12-char";
label variable yob_s         "(Spousal) Year of Birth";
label variable educ_s        "(Spousal) Education: 10 Levels";
label variable educ4_s 	     "(Spousal) Education: 4 Levels";
label variable hukou_s 	     "(Spousal) Hukou Status";
label variable marriage_s    "(Spousal) Marriage Status";
label variable pob_s         "(Spousal) Place of Birth";

label list raeduc_c educl;
label define EducForRegression 
	1 "1.Illiterate" 2 "2.Did not finish primary school but capable of reading and/or writing" 
	3 "3.Home school" 4 "4.Elementary school" 5 "5.Middle school" 6 "6.High school" 
	7 "7.Vocational school" 8 "8.College and above" 9 "9.Missing";
	
label define EduclForRegression 
	0 "0.None" 1 "1.Less than lower secondary" 2 "2.Upper secondary & Vocational training"
	3 "3.Tertiary" 4 "4.Missing";	

generate reduc = educ, after(educ);
recode   reduc (9/10 = 8);
replace  reduc = 9 if educ>=.;
label values reduc EducForRegression;
label variable reduc "(Regression) Education: 8 Levels (missing values are coded as 9)";
generate reduc_s = educ_s, after(educ_s);
recode   reduc_s (9/10 = 8);
replace  reduc_s = 9 if educ_s>=.;
label values reduc_s EducForRegression;
label variable reduc_s "(Regression) (Spousal) Education: 8 Levels (missing values are coded as 9)";

generate reduc4 = educ4, after(educ4);
replace  reduc4 = 4 if educ>=.;
label values reduc4 EduclForRegression;
label variable reduc4 "(Regression) Education: 4 Levels (missing values are coded as 4)";
generate reduc4_s = educ4_s, after(educ4_s);
replace  reduc4_s = 4 if educ_s>=.;
label values reduc4_s EduclForRegression;
label variable reduc4_s "(Regression) (Spousal) Education: 4 Levels (missing values are coded as 4)";

label define HukouForRegression	
	1 "Agricultual" 2 "Non-Agricultural" 3 "Unified Residence"        
    4 "Do not have Hukou" 5 "Missing";
generate rhukou = hukou, after(hukou);
replace  rhukou = 5 if hukou>=.;
label values rhukou HukouForRegression;
generate rhukou_s = hukou_s, after(hukou_s);
replace  rhukou_s = 5 if hukou_s>=.;
label values rhukou_s HukouForRegression;
label variable rhukou   "(Regression) Hukou Status";
label variable rhukou_s "(Regression) (Spousal) Hukou Status";


label define MarriageForRegression
           1 "1.married"
           3 "3.partnered"
           4 "4.separated"
           5 "5.divorced"
           7 "7.widowed"
           8 "8.never married"
		   99 "Missing";
generate rmarriage = marriage, after(marriage);
replace  rmarriage = 99 if marriage >= .;
generate rmarriage_s = marriage_s, after(marriage_s);
replace  rmarriage_s = 99 if marriage_s >= .;
label values rmarriage MarriageForRegression;
label values rmarriage_s MarriageForRegression;
label variable rmarriage   "(Regression) Marriage Status";
label variable rmarriage_s "(Regression) (Spousal) Marriage Status";

order communityID hhid rural year id 
gender yob reduc reduc4 rhukou rmarriage pob 
id_s yob_s reduc_s reduc4_s rhukou_s rmarriage_s pob_s;

merge m:1 communityID using "E:\Data_CHARLS\2011\PSU.dta", keepusing(province city) nogenerate;
order province city, before(communityID);

save "$workingdata\_demo_long.dta", replace;
 


