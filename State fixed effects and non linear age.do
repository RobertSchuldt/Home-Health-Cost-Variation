cd "C:\Users\3043340\Box\Cost Variation Final\Tables"


reg log_spend weightedage  weightedhcc i.state_code
outreg2 using model_missing.doc, replace

reg log_spend weightedage  weightedhcc percent_fp percent_go per_tenure i.state_code
outreg2 using model_missing.doc, append

reg log_spend weightedage weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median_income ib4.hhi_quartiles   i.state_code
outreg2 using model_missing.doc, append

reg log_spend weightedage percent_dual percent_non_white percent_female weightedhcc i.state_code
outreg2 using models.doc, replace

reg log_spend weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure i.state_code
outreg2 using models.doc, append

reg log_spend weightedage percent_dual percent_non_white percent_female weightedhcc percent_fp percent_go per_tenure per_cap_hosp percap_pcp per_cap_nursin median_income ib4.hhi_quartiles   i.state_code
outreg2 using models.doc, append
