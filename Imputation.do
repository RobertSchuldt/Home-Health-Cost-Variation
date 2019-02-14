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

sort hsanum

by hsanum: egen total_diff = sum(difference_costs)

xtile deciles = total_diff, nq(10)

graph box total_diff, over(deciles)
