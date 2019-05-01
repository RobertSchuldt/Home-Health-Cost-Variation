cd  "C:\Users\3043340\Desktop\Box Sync\Schuldt Research Work\Cost HHA Paper\Redux Cost Paper 2019"
set more off
clear

use  "E:\Cost HHA Paper\Redux Cost Paper 2019\cost_analysis2.dta", clear

rename distinct_beneficiaries__non_lupa num_bene

sort fips

by fips: egen totalbeneficiaries = sum(num_bene)
gen hccweight = (average_hcc_score*num_bene)/totalbeneficiaries
label var hccweight "Weighted HCC score"

by fips: egen weightedhcc = sum(hccweight)
label var weightedhcc "Weighted HCC Score by fips" 


gen ageweight = (average_age*num_bene)/totalbeneficiaries
label var ageweight "Weighted age"

by fips: egen weightedage = sum(ageweight)
label var weightedage "Weighted age by fips"

 

rename percent_of_beneficiaries_with_al alzheimers
rename percent_of_beneficiaries_with_at atrial_fib
rename percent_of_beneficiaries_with_hy hypertension


rename percent_of_beneficiaries_with_ra arthritis
replace arthritis = 0 if arthritis == .
rename percent_of_beneficiaries_with_as Asthma

rename percent_of_beneficiaries_with_ca Cancer

rename percent_of_beneficiaries_with_ch CHF

rename percent_of_beneficiaries_with_c1 kidney

rename percent_of_beneficiaries_with_co COPD

rename percent_of_beneficiaries_with_de Depression

rename percent_of_beneficiaries_with_di Diabetes

rename percent_of_beneficiaries_with_ih IHD

rename percent_of_beneficiaries_with_os Osteo

rename percent_of_beneficiaries_with_sc Schizophrenia

mdesc    weightedhcc  num_bene per_cap_nursin per_cap_hosp  median_income Diabetes IHD /*
*/Schizophrenia COPD Osteo /*
*/ kidney CHF /*
*/ Cancer Asthma /*
*/arthritis   atrial_fib alzheimers percent_dual percent_female


local conditions Diabetes IHD /*
*/Schizophrenia COPD Osteo /*
*/ kidney CHF /*
*/ Cancer Asthma  /*
*/arthritis  hypertension atrial_fib alzheimers



foreach var of local conditions {

replace `var' = (`var'*num_bene)/totalbeneficiaries

by fips: egen weighted`var' = sum(`var')
label var weighted`var' "Weighted `var' by fips" 
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

gen hhi2= hhi>7160.34

gen medianincome2 = median_income/1000



encode(state), gen(state_code)


local weight weightedage  weightedIHD weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers

collapse `weight'  medianincome2 percent_dual percent_female weightedhcc percent_gov percent_fp hhi hhi2 pat_spend num_bene per_cap_nursin per_cap_hosp  median_income   state_code, by(fips)




reg pat_spend percent_gov percent_fp weightedhcc hhi2 percent_dual percent_female per_cap_nursin per_cap_hosp  medianincome2 `weight', cluster(state_code)

gen log_spend = log(pat_spend)
kdensity log_spend
reg log_spend percent_gov percent_fp weightedhcc hhi2  percent_dual percent_female per_cap_nursin per_cap_hosp  medianincome2 `weight', cluster(state_code)



sum pat_spend percent_gov percent_fp weightedhcc hhi2 num_bene percent_dual percent_female per_cap_nursin per_cap_hosp  medianincome2 `weight'

