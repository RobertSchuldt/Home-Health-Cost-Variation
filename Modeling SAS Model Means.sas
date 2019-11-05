/* Running my regressions in SAS to calculate model means for my reference groups so I can create the graphics
that I want to add into my article on variation. 

Robert Schuldt
rfschuldt@uams.edu

****************************************************************************************************************/

proc import datafile = "****************************riation.dta"
dbms = dta out = models replace;
run;
/*Modeling */
proc mixed data = models;
	/*Define categorical*/
	class spend_quintiles(ref = "1") ;
	/* modeling the data */
	model pat_spend = spend_quintiles  / solution cl; /*Model the initial model unadjusted*/
	lsmeans spend_quintiles / pdiff cl;
	output = model; 
	run;
/*Patient factors adjusted */
proc mixed data = models;
	/*Define categorical*/
	class spend_quintiles(ref = "1") ;
	/* modeling the data */
	model pat_spend = spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc
	/ solution cl; 
	lsmeans spend_quintiles / pdiff cl;
	run;
/*MOdel with Patient Factors and agency factors*/
proc mixed data = models;
	/*Define categorical*/
	class spend_quintiles(ref = "1") ;
	/* modeling the data */
	model pat_spend = spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc
	percent_fp percent_gov per_tenure  / solution cl; 
	lsmeans spend_quintiles / pdiff cl;
	run;
/* With Community factors, patient, and agency factors */
proc mixed data = models;
	/*Define categorical*/
	class spend_quintiles(ref = "1") ;
	/* modeling the data */
	model pat_spend = spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc
	percent_fp percent_gov per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 hhi_quartiles  / solution cl; 
	lsmeans spend_quintiles / pdiff cl;
	run;
