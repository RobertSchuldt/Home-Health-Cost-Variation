/*Revised home health project to improve analysis and expand to the HSA level unit of analysis

@author: Robert Schuldt
@email:  rschuldt@uams.edu

************************************************************************************************/
option symbolgen;

libname cost 'E:\Cost HHA Paper\Redux Cost Paper 2019';

/*Import macro for the various files I'm going to need to be using*/
%macro import(file, type, name);

proc import datafile = "&file"
dbms = &type out= &name replace;
run;

%mend import;

%import(E:\puffiles\HH PUF - Provider 2016, xlsx, puf)
%import(E:\Cost HHA Paper\Redux Cost Paper 2019\ZipHsaHrr16, xls, crosswalk)

data puf1;
	set puf (rename = ( Provider_ID =CMS_Certification_Number__CCN_ ));
	count = 1;
run;

/*Need to add leading zeros to crosswalk*/


data zeros;
	set crosswalk ;
	drop zipcode16 ;
	 
		zip_code = put(zipcode16, z5.);

	run;
/*Bringing in my sorting macro*/

%include 'E:\SAS Macros\infile macros\sort.sas';

/*Sorting to figure out which HSA's cross state lines*/
%sort(zeros, hsanum)

/*Now I need t create a count of states in hsa by hsanum*/

proc sql;
create table check_hsa as
select hsanum, hsastate, zip_code,
count(distinct hsastate) as state_check
from zeros
group by hsanum
;
quit;

title 'Check to see if HSA cross state lines';
proc freq;
table state_check;
run;

/*says that none do which has me a bit concerned, but we will see later*/

%sort(check_hsa, zip_code)
%sort(puf1, zip_code)

data hsa_puf;
	merge puf1 (in = a) check_hsa (in = b);
	by zip_code;
	if a;
	if b;
run;

%import(E:\Cost HHA Paper\Redux Cost Paper 2019\homehealthcompare , xlsx, hhc)
%sort(hhc, CMS_Certification_Number__CCN_)
%sort(hsa_puf, CMS_Certification_Number__CCN_)

data hhc_puf_hsa;
	merge hhc (in = a) hsa_puf (in = b);
	by CMS_Certification_Number__CCN_;
		if a;
		if b;
run;
/* All the agencies that didn't match had missing responses to all the questions in the
home health compare as well. It seems they were not measured? Must all below a limit or be missing
a particular component*/

title1'Type of Agencies';
proc freq;
table type_of_ownership;
run;


data cost_analysis;
	set hhc_puf_hsa;
	
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


