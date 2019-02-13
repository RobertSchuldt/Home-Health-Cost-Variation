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

/*Need to add leading zeros to crosswalk*/
data zeros;
	set crosswalk;
	drop zipcode16;
		
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


