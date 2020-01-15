cd "C:\Users\3043340\Box\Cost Variation Final\Tables"
use cost_variation, clear

/*Models  NO FE Non Log transformed */
reg pat_spend ib1.spend_quintiles
outreg2 using models.doc, replace alpha(0.001, 0.01, 0.05) dec(2)
reg pat_spend ib1.spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc  
outreg2 using models.doc, append alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  
outreg2 using models.doc, append alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  
outreg2 using models.doc, append alpha(0.001, 0.01, 0.05) dec(2)

/*Models  FE Non Log transformed */
reg pat_spend ib1.spend_quintiles i.state_code
outreg2 using femodels.doc, replace alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend ib1.spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc  i.state_code
outreg2 using femodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  i.state_code
outreg2 using femodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  i.state_code
outreg2 using femodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)
 
/*Models  NO FE Non Log transformed   NO QUINTILES*/


reg pat_spend   weightedage percent_dual percent_non_white percent_female weightedhcc  
outreg2 using nqmodels.doc, replace alpha(0.001, 0.01, 0.05) dec(2)
 
reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  
outreg2 using nqmodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  
outreg2 using nqmodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)

/*Models  FE Non Log transformed NO QUINTILES*/


reg pat_spend   weightedage percent_dual percent_non_white percent_female weightedhcc  i.state_code
outreg2 using nqfemodels.doc, replace alpha(0.001, 0.01, 0.05) dec(2)
reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  i.state_code
outreg2 using nqfemodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)

reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  i.state_code
outreg2 using nqfemodels.doc, append alpha(0.001, 0.01, 0.05) dec(2)




/*Models  NO FE  Log transformed */
reg ln_spend ib1.spend_quintiles
outreg2 using lnmodels.doc, replace
reg ln_spend ib1.spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc  
outreg2 using lnmodels.doc, append

reg ln_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  
outreg2 using lnmodels.doc, append

reg ln_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  
outreg2 using lnmodels.doc, append

/*Models  FE Non Log transformed */
reg ln_spend ib1.spend_quintiles i.state_code
outreg2 using lnfemodels.doc, replace

reg ln_spend ib1.spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc  i.state_code
outreg2 using lnfemodels.doc, append

reg ln_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  i.state_code
outreg2 using lnfemodels.doc, append

reg ln_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  i.state_code
outreg2 using lnfemodels.doc, append


bysort spend_quintiles: sum pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_gov per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 hhi


foreach var of varlist pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_gov per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 hhi {


gen `var'_1 = `var' if spend_quintiles == 1
gen `var'_2 = `var' if spend_quintiles == 2
gen `var'_3 = `var' if spend_quintiles == 3
gen `var'_4 = `var' if spend_quintiles == 4
gen `var'_5 = `var' if spend_quintiles == 5


}

foreach var of varlist pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_gov per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 hhi{

ttest `var'_2 == `var'_1, unpaired
ttest `var'_3 == `var'_1, unpaired
ttest `var'_4 == `var'_1, unpaired
ttest `var'_5 == `var'_1, unpaired


}


reg

