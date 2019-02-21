/*Revised home health project to improve analysis and expand to the County level unit of analysis
We recently found documentation that supports the use of COUNTIES to define the geographic treatment
area of home health agencies. This is much easier for us to study and get better demographic data. 

@author: Robert Schuldt
@email:  rschuldt@uams.edu

************************************************************************************************/
option symbolgen;

libname cost 'E:\Cost HHA Paper\Redux Cost Paper 2019';
libname ahrf 'X:\Data\AHRF\2017-2018';


/*Import macro for the various files I'm going to need to be using*/
%macro import(file, type, name);

proc import datafile = "&file"
dbms = &type out= &name replace;
run;

%mend import;

%import(E:\puffiles\HH PUF - Provider 2016, xlsx, puf)

data puf1;
	set puf (rename = ( Provider_ID =CMS_Certification_Number__CCN_ ));
	count = 1;
	rename zip_code = zip;
run;


/*Bringing in my sorting macro*/

%include 'E:\SAS Macros\infile macros\sort.sas';

%import(E:\Cost HHA Paper\Redux Cost Paper 2019\ZIP_COUNTY, xlsx, crosswalk)

/*Now I merge the PUF with the crosswalk for zip code to county*/

%sort(puf1, zip)
%sort(crosswalk, zip)

data puf_zip;
	merge puf1 (in = a) crosswalk (in = b);
	by zip;
	if a;
	if b;
run;

/*Now bring int he HHC progarm*/
%import(E:\Cost HHA Paper\Redux Cost Paper 2019\homehealthcompare , xlsx, hhc)
%sort(hhc, CMS_Certification_Number__CCN_)
%sort(puf_zip, CMS_Certification_Number__CCN_)


data hhc_puf;
	merge hhc (in = a)  puf_zip (in = b);
	by CMS_Certification_Number__CCN_;
		if a;
		if b;
run;

proc sort data = hhc_puf nodupkey;
by CMS_Certification_Number__CCN_;
run;
/* All the agencies that didn't match had missing responses to all the questions in the
home health compare as well. It seems they were not measured? Must all below a limit or be missing
a particular component*/

title1'Type of Agencies';
proc freq;
table type_of_ownership;
run;


data cost_analysis;
	set hhc_puf;
		drop RES_RATIO BUS_RATIO OTH_RATIO TOT_RATIO;

		rename COUNTY = fips;

	if Male_Beneficiaries =. and Female_Beneficiaries = . then delete;
		%let t = type_of_ownership;
	if &t = "Proprietary" then for_profit = 1;
					else for_profit = 0;
	if &t = "Government - Combination Government & Voluntary" 
	or &t = "Government - Local"
	or &t = "Government - State/ County" 
			then government = 1;
					else not_for_profit = 0;
	if &t = "Non - Profit Private"  or 
  		&t = "Non - Profit Religious" 
			then not_for_profit = 1;
					else not_for_profit = 0;
	/*creating our other variables of interset within the puf*/
		percent_female = ((Distinct_Beneficiaries__non_LUPA - Male_Beneficiaries)/Distinct_Beneficiaries__non_LUPA)*100;
		percent_dual = (Dual_Beneficiaries/Distinct_Beneficiaries__non_LUPA)*100;
		percent_non_white = ( ( Distinct_Beneficiaries__non_LUPA - White_Beneficiaries)/Distinct_Beneficiaries__non_LUPA)*100;
		episodes_per_bene =  Distinct_Beneficiaries__non_LUPA/VAR7;


	/*Our per beneficiary standardized expenditure*/
	ex_pb = Total_HHA_Medicare_Standard_Paym/Distinct_Beneficiaries__non_LUPA;

	run;
title 'Check missing on set';
proc means;
var percent_female percent_dual episodes_per_bene percent_non_white;
run;


data ahrf;
	set ahrf.ahrf_2017_2018;

	keep f00002 f1404916 f0892416 f1322616 f1198416 median_income fips per_cap_hosp per_cap_nursin;


		fips = f00002;
		median_income = f1322616;
	per_cap_hosp = (f0892416/f1198416)*1000;
	per_cap_nursin = (f1404916/f1198416)*1000;

	run;

%sort(ahrf, fips)
%sort(cost_analysis, fips)

data ahrf_puf;
	merge cost_analysis (in = a) ahrf (in = b);
	by fips;
	if a;
	if b;
	run;




