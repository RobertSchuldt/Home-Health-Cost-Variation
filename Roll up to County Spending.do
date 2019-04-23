cd  "E:\Cost HHA Paper\Redux Cost Paper 2019\
set more off
clear

use "E:\Cost HHA Paper\Redux Cost Paper 2019\cost_analysis.dta", clear

rename percent_of_beneficiaries_with_ra arthritis
rename percent_of_beneficiaries_with_as bene_as
rename percent_of_beneficiaries_with_ca bene_ca
rename percent_of_beneficiaries_with_ch bene_ch
rename percent_of_beneficiaries_with_c1 bene_c1
rename percent_of_beneficiaries_with_co bene_co
rename percent_of_beneficiaries_with_de bene_de
rename percent_of_beneficiaries_with_di bene_di
rename percent_of_beneficiaries_with_ih bene_ih
rename percent_of_beneficiaries_with_os bene_os
rename percent_of_beneficiaries_with_sc bene_sc
rename distinct_beneficiaries__non_lupa num_bene

local conditions bene_as bene_ca /*
*/bene_ch bene_c1 bene_co /*
*/ bene_de bene_di /*
*/ bene_ih bene_os /*
*/arthritis bene_sc 

foreach var of local conditions {
replace `var' = `var'*num_bene
}

gen pat_spend = total_hha_medicare_standard_paym/num_bene

sort fips

by fips: egen total_fp = total(fp) 
by fips: egen total_gov = total(gov)
by fips: egen total_agen = total(count)

gen percent_gov = total_gov/total_agen
gen percent_fp = total_fp/total_agen




by fips: egen total_pat = total(num_bene)

gen hhi_portion = ((num_bene/total_pat)*100)^2

by fips: egen hhi = total(hhi_portion)

by fips: gen hhi2 = hhi^2

encode(state), gen(state_code)

collapse `conditions' percent_gov percent_fp hhi hhi2 pat_spend num_bene per_cap_nursin per_cap_hosp  median_income  state_code, by(fips)



reg pat_spend percent_gov percent_fp hhi num_bene per_cap_nursin per_cap_hosp  median_income bene_as bene_ca /*
*/bene_ch bene_c1 bene_co /*
*/ bene_de bene_di /*
*/ bene_ih bene_os /*
*/arthritis bene_sc, cluster(state_code)

reg pat_spend percent_gov percent_fp hhi  per_cap_nursin per_cap_hosp  median_income bene_as bene_ca /*
*/bene_ch bene_c1 bene_co /*
*/ bene_de bene_di /*
*/ bene_ih bene_os /*
*/arthritis bene_sc [w=num_bene], cluster(state_code)
