/*HHA Cost Analysis using MI and moving to the HSA level of 
analysis. Data management in SAS, calculations in STATA 14*/

cd  "E:\Cost HHA Paper\Redux Cost Paper 2019\
set more off
clear

use "E:\Cost HHA Paper\Redux Cost Paper 2019\cost_analysis.dta", clear


mi set mlong


rename percent_of_beneficiaries_with_ra arthritis

mi register imputed percent_non_white percent_dual percent_female arthritis

mi imput mvn percent_non_white percent_dual arthritis = percent_female, add(50) rseed(2130)

mi estimate, saving(miest, replace): reg ex_pb average_age percent_female percent_dual percent_non_white /*
*/ average_hcc_score percent_of_beneficiaries_with_at percent_of_beneficiaries_with_al /*
*/ percent_of_beneficiaries_with_as percent_of_beneficiaries_with_ca /*
*/percent_of_beneficiaries_with_ch percent_of_beneficiaries_with_c1 percent_of_beneficiaries_with_co /*
*/ percent_of_beneficiaries_with_de percent_of_beneficiaries_with_di /*
*/ percent_of_beneficiaries_with_ih percent_of_beneficiaries_with_os /*
*/arthritis percent_of_beneficiaries_with_sc 

mi estimate, vartable dftable



mi predict yhat using miest

gen difference_costs = ex_pb - yhat

keep if difference_costs != .

sum difference_costs

sort fips

by fips: egen total_diff = sum(difference_costs)

xtile deciles = total_diff, nq(10)

graph box total_diff, over(deciles)

by fips: egen total_pat = total(distinct_beneficiaries__non_lupa)

gen hhi_portion = ((distinct_beneficiaries__non_lupa/total_pat)*100)^2

by fips: egen hhi = total(hhi_portion)

by fips: gen hhi2 = hhi^2

sort deciles

by deciles: sum hhi



sort fips
by fips: egen total_agen = total(count)

by fips: egen total_fp = total(for_profit) 
by fips: egen total_gov = total(government)

gen percent_gov = total_gov/total_agen
gen percent_fp = total_fp/total_agen

gen tenured =date_certified>14072

by fips: egen total_tenure = total(tenured)
by fips: gen percent_tenure = total_tenure/total_agen

reg difference percent_fp percent_gov percent_tenure hhi per_cap_nursin per_cap_hosp /*
*/ median_income hhi2, cluster(state)

/*Dropping variables three standard deviations outside the mean*/

sum difference
drop if (difference-(r(mean))>(3*r(sd)))

reg difference percent_fp percent_gov percent_tenure hhi per_cap_nursin per_cap_hosp /*
*/ median_income, cluster(state)

