/*Revised home health project to improve analysis and expand to the HSA level unit of analysis

@author: Robert Schuldt
@email:  rschuldt@uams.edu

************************************************************************************************/

libname cost 'E:\Cost HHA Paper\Redux Cost Paper 2019';

%macro import(file, type, name);

proc import datafile = "&file"
dbms = &type out= &name replace;
run;

%mend import;

%import(E:\puffiles\HH PUF - Provider 2016, xlsx, puf)
%import(E:\Cost HHA Paper\Redux Cost Paper 2019, xls, crosswalk)


proc import datafile = 'E:\puffiles\HH PUF - Provider 2016'
dbms = xlsx out= puf replace;
run;

proc import datafile = 'E:\Cost HHA Paper\Redux Cost Paper 2019'
dbms = xls out = crosswalk replace;

