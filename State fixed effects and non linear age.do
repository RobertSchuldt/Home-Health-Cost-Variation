cd "C:\Users\3043340\Box\Cost Variation Final\Tables"
use cost_variation, clear

/*Models  NO FE Non Log transformed */
reg pat_spend ib1.spend_quintiles
outreg2 using models.doc, replace
reg pat_spend ib1.spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc  
outreg2 using models.doc, append

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  
outreg2 using models.doc, append

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  
outreg2 using models.doc, append

/*Models  FE Non Log transformed */
reg pat_spend ib1.spend_quintiles i.state_code
outreg2 using femodels.doc, replace

reg pat_spend ib1.spend_quintiles  weightedage percent_dual percent_non_white percent_female weightedhcc  i.state_code
outreg2 using femodels.doc, append

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  i.state_code
outreg2 using femodels.doc, append

reg pat_spend ib1.spend_quintiles weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  i.state_code
outreg2 using femodels.doc, append

/*Models  NO FE Non Log transformed   NO QUINTILES*/


reg pat_spend   weightedage percent_dual percent_non_white percent_female weightedhcc  
outreg2 using nqmodels.doc, replace

reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  
outreg2 using nqmodels.doc, append

reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  
outreg2 using nqmodels.doc, append

/*Models  FE Non Log transformed NO QUINTILES*/


reg pat_spend   weightedage percent_dual percent_non_white percent_female weightedhcc  i.state_code
outreg2 using nqfemodels.doc, replace
reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure  i.state_code
outreg2 using nqfemodels.doc, append

reg pat_spend  weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median2 ib4.hhi_quartiles  i.state_code
outreg2 using nqfemodels.doc, append




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
