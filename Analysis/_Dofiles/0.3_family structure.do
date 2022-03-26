global rawdatapath "E:\__Post-Retirement Behavior\RawData"
global workingdata "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\workingdata"
global resultspath "E:\__Post-Retirement Behavior\Adjustments-after-Retirement\Analysis\_results"

***********************************************************************
** Harmonized CHARLS: Get information on household structure                           
***********************************************************************

#delimit ;
use "$rawdatapath\H_CHARLS_D_Data.dta", clear;
keep ID h1hhres h2hhres h3hhres h4hhres h1child h2child h3child h4child 
	 h1coresd h2coresd h3coresd h4coresd h1lvnear h2lvnear h3lvnear h4lvnear 
	 h1kcntf h2kcntf h3kcntf h4kcntf h1kcntpm h2kcntpm h3kcntpm h4kcntpm 
	 h1kcnt h2kcnt h3kcnt h4kcnt 
	 r1socwk r2socwk r3socwk r4socwk s1socwk s2socwk s3socwk s4socwk 
	 h1fcany h2fcany h3fcany h4fcany h1fcamt h2fcamt h3fcamt h4fcamt 
	 h1tcany h2tcany h3tcany h4tcany h1tcamt h2tcamt h3tcamt h4tcamt 
	 h1ftot h2ftot h3ftot h4ftot;

reshape long h@hhres h@child h@coresd h@lvnear h@kcntf h@kcntpm h@kcnt 
	    r@socwk s@socwk h@fcany h@fcamt h@tcany h@tcamt h@ftot, i(ID) j(year);
			
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
rename (hhhres hchild hcoresd hlvnear hkcntf hkcntpm hkcnt)
	   (size noc_alive coreside nearby contact_p contact_d contact);
rename (rsocwk ssocwk hfcany hfcamt htcany htcamt hftot) 
	   (social social_s transfer_r trans_r transfer_g trans_g trans_tol_n);
	   
label variable size         "Number of People Living in this Household";
label variable noc_alive    "Number of Living Children";
label variable coreside     "Any Child Co-Reside with R/S";
label variable nearby       "R/S Live Near Children (the Same City or County)";
label variable contact_p    "Any Weekly Contact with Children in Person";
label variable contact_d    "Any Weekly Contact with Children - Phone/Email";
label variable contact      "Any Weekly Contact with Children in Person/Phone/Email";
label variable social       "Participate in Social Activities";
label variable social_s     "(Spouse) Participate in Social Activities";
label variable transfer_r   "Any Transfer from Children/Grandchildren";
label variable trans_r      "Amount of Transfers from Children/Grandchildren";
label variable transfer_g   "Any Transfer to Children/Grandchildren";
label variable trans_g      "Amount of Transfers to Children/Grandchildren";
label variable trans_tol_n  "Net Value of Financial Transfers";

save "$workingdata\_family structure_long.dta", replace;
