
set more off
use "C:\Users\3043340\Box\Cost Variation Final\Test 11-13-19\final.dta", clear
drop if fips_state_cd =="72"
rename Distinct_Beneficiaries__non_LUPA num_bene

sort fips

by fips: egen totalbeneficiaries = sum(num_bene)
gen hccweight = (Average_HCC_Score*num_bene)/totalbeneficiaries
label var hccweight "Weighted HCC score"

by fips: egen weightedhcc = sum(hccweight)
label var weightedhcc "Weighted HCC Score by fips" 

sum tenure
gen tenuremean = r(mean)
gen tenure_agency = tenure>tenuremean
by fips: egen total_agencies = sum(count)
by fips: egen total_tenure = sum(tenure_agency)
by fips: gen per_tenure = total_tenure/total_agencies


gen ageweight = (Average_Age*num_bene)/totalbeneficiaries
label var ageweight "Weighted age"

by fips: egen weightedage = sum(ageweight)
label var weightedage "Weighted age by fips"

 

rename Percent_of_Beneficiaries_with_Al alzheimers
rename Percent_of_Beneficiaries_with_At atrial_fib
rename Percent_of_Beneficiaries_with_Hy hypertension


rename Percent_of_Beneficiaries_with_RA arthritis
replace arthritis = 0 if arthritis == .
rename Percent_of_Beneficiaries_with_As Asthma

rename Percent_of_Beneficiaries_with_Ca Cancer

rename Percent_of_Beneficiaries_with_CH CHF

rename Percent_of_Beneficiaries_with_C1 kidney

rename Percent_of_Beneficiaries_with_CO COPD

rename Percent_of_Beneficiaries_with_De Depression

rename Percent_of_Beneficiaries_with_Di Diabetes

rename Percent_of_Beneficiaries_with_IH IHD

rename Percent_of_Beneficiaries_with_Os Osteo

rename Percent_of_Beneficiaries_with_Sc Schizophrenia

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

gen pat_spend = Total_HHA_Medicare_Standard_Paym/num_bene

sort fips

by fips: egen total_fp = total(fp) 
by fips: egen total_gov = total(gov)
by fips: egen total_agen = total(count)

gen percent_gov = total_gov/total_agen
gen percent_fp = total_fp/total_agen






by fips: egen total_pat = total(num_bene)

gen hhi_portion = ((num_bene/total_pat)*100)^2

by fips: egen hhi = total(hhi_portion)

gen hhi2= hhi<7160.34

gen medianincome2 = median_income/1000

egen hhi_quartiles = xtile(hhi), n(4)

encode(State), gen(state_code)


local  weight  per_tenure weightedage weightedDiabetes  weightedIHD weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers

collapse `weight' hhi_quartiles  urban urban2 percap_pcp totalbeneficiaries percent_non_white medianincome2  percent_dual percent_female weightedhcc percent_gov percent_fp hhi hhi2 pat_spend num_bene per_cap_nursin per_cap_hosp  median_income   state_code, by(fips)

local weight  per_tenure weightedage weightedDiabetes   weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers



reg pat_spend percent_gov percent_fp weightedhcc urban hhi2 percent_dual percent_female percent_non_white per_cap_nursin percap_pcp per_cap_hosp  medianincome2 `weight' [w=totalbeneficiaries], cluster(state_code) 

gen log_spend = log(pat_spend)
kdensity log_spend
 gen agesquare = weightedage*weightedage
local weight  per_tenure weightedage agesquare weightedDiabetes   weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers

reg log_spend percent_gov   percent_fp weightedhcc i.hhi_quartiles urban percent_dual percent_female percent_non_white per_cap_nursin percap_pcp per_cap_hosp  medianincome2 `weight' i.state_code,  cluster(fips)
/* Fixed effects  and cluster at the county level*/

/* non linear age*/


sum urban pat_spend percent_gov percent_fp weightedhcc hhi2 num_bene percent_dual percent_female percent_non_white per_cap_nursin percap_pcp per_cap_hosp  median_income `weight'

/* Make my Quintiles of Spending per pat, Total Spending, and Number of pats*/



egen spending_quintiles= xtile(pat_spend), nq(5)


sort spending_quintiles

by spending_quintiles: sum pat_spend, detail

sum pat_spend, detail




/* make my graphics */

graph box pat_spend, over(spending_quintiles) title("Medicare Expenditure per Beneficiary by Quintile") note("2015 Data") ytitle("Per Patient Expenditure") 

graph box totalbeneficiaries, over(patient_quintiles) title("Quintiles of Home Health Beneficiaries by County") note("2015 Data") ytitle("Number of Patients") nooutsides 

graph box Total_HHA_Medicare_Standard_Paym, over(totalcharge_quintiles) title("Quintiles of Total Home Health Expenditure by County") note("2015 Data") ytitle("Total Home Health Expenditure") nooutsides 



/*local weight  per_tenure weightedage weightedDiabetes   weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers
glm pat_spend percent_gov percent_fp weightedhcc hhi2 percent_dual percent_female percent_non_white per_cap_nursin per_cap_hosp  medianincome2 `weight' ,family(gamma) link(log) cluster(state_code) 
*/
local weight  per_tenure weightedage weightedDiabetes   weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers


kdensity totalbeneficiaries
glm totalbeneficiaries percent_gov percent_fp weightedhcc hhi2 percent_dual percent_female percent_non_white per_cap_nursin per_cap_hosp  medianincome2 `weight' ,family(gamma) link(log) cluster(state_code) 

local weight  per_tenure weightedage weightedDiabetes   weightedSchizophrenia weightedCOPD weightedOsteo  weightedCHF weightedCancer weightedAsthma   weightedatrial_fib weightedalzheimers

kdensity pat_spend
glm pat_spend percent_gov percent_fp weightedhcc hhi2 percent_dual percent_female percent_non_white per_cap_nursin per_cap_hosp  medianincome2 `weight' ,family(gamma) link(log) cluster(state_code) 
