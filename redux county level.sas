/*Revised home health project to improve analysis and expand to the County level unit of analysis
We recently found documentation that supports the use of COUNTIES to define the geographic treatment
area of home health agencies. This is much easier for us to study and get better demographic data. 

@author: Robert Schuldt
@email:  rschuldt@uams.edu

************************************************************************************************/
option symbolgen;

libname cost 'E:\Cost HHA Paper\Redux Cost Paper 2019';
libname ahrf 'X:\Data\AHRF\2017-2018';
libname pos 'X:\Data\POS\2015\Data';

/*Import macro for the various files I'm going to need to be using*/
%macro import(file, type, name);

proc import datafile = "&file"
dbms = &type out= &name replace;
run;

%mend import;

%import(E:\puffiles\HH PUF - Provider 2016, xlsx, puf)

data pos;
	set pos.pos_2015;
	where PRVDR_CTGRY_CD = "05";
	keep PRVDR_NUM GNRL_CNTL_TYPE_CD FIPS_STATE_CD FIPS_CNTY_CD nfp fp gov other;
	rename prvdr_num = CMS_Certification_Number__CCN_;
	if GNRL_CNTL_TYPE_CD = '01' or GNRL_CNTL_TYPE_CD =  '02' or GNRL_CNTL_TYPE_CD =  '03' then nfp = 1;
		else nfp = 0;
	if GNRL_CNTL_TYPE_CD = '04' then fp = 1;
		else fp = 0;
	if GNRL_CNTL_TYPE_CD = '05' or GNRL_CNTL_TYPE_CD =  '06' or GNRL_CNTL_TYPE_CD =  '07' then gov = 1;
		else gov = 0;
run;

proc freq;
table GNRL_CNTL_TYPE_CD;
run;

data puf1;
	set puf;
	drop provider_id;
	    length CMS_Certification_Number__CCN_ $ 6;
		CMS_Certification_Number__CCN_ = Provider_ID;
		CMS_Certification_Number__CCN_ = put(input(CMS_Certification_Number__CCN_, 6.),z6.);
	count = 1;
run;


/*Bringing in my sorting macro*/

%include 'E:\SAS Macros\infile macros\sort.sas';

/*Now I merge the PUF with the crosswalk for zip code to county*/

%sort(puf1, CMS_Certification_Number__CCN_)
%sort(pos, CMS_Certification_Number__CCN_)

data puf_pos;
	merge puf1 (in = a) pos (in = b);
	by CMS_Certification_Number__CCN_;
	if a;
	if b;
run;
/* All the agencies that didn't match had missing responses to all the questions in the
home health compare as well. It seems they were not measured? Must all below a limit or be missing
a particular component*/

title1'Type of Agencies';
proc freq;
table nfp gov fp;
run;


data cost_analysis;
	set puf_pos;	
	
	if Male_Beneficiaries =. and Female_Beneficiaries = . then delete;
	
	length fips $ 7;
	fips = catt(FIPS_STATE_CD,FIPS_CNTY_CD);
	if fips = '12025' then fips = '12086';
	/*creating our other variables of interset within the puf*/
		percent_female = ((Distinct_Beneficiaries__non_LUPA - Male_Beneficiaries)/Distinct_Beneficiaries__non_LUPA)*100;
		percent_dual = (Dual_Beneficiaries/Distinct_Beneficiaries__non_LUPA)*100;
		percent_non_white = ( ( Distinct_Beneficiaries__non_LUPA - White_Beneficiaries)/Distinct_Beneficiaries__non_LUPA)*100;
		episodes_per_bene =  Distinct_Beneficiaries__non_LUPA/VAR7;
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




