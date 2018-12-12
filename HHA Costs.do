**** Redo of the Home Health Project****
*Focused only on Health Care Costs No Quality*
*Extract Average HCC score weighted by patients*
set more off
clear

import excel "E:\Final Chen Project\HH_PUF_Provider_Final_2014\HH_PUF_Provider_2014.xlsx", sheet("Provider") firstrow case(lower)
** Keeping only Non LUPA patients*

keep providerid state distinctbeneficiariesnonlupa averagehccscore totalhhamedicarepaymentamoun

sort state

by state: egen totalbeneficiaries = sum(distinctbeneficiariesnonlupa)
by state: egen totalrealpayments = sum(totalhhamedicarepaymentamoun) 
by state: replace totalrealpayments = totalrealpayments/totalbeneficiaries
label variable totalbeneficiaries "total distinct beneficiaries by state"
label variable totalrealpayments "Real expenditures per beneficiary"
*weighting the HCC score*

gen hccweight = (averagehccscore*distinctbeneficiariesnonlupa)/totalbeneficiaries

label var hccweight "Weighted HCC score"

**adding the weights**

by state: egen weightedhcc = sum(hccweight)
label var weightedhcc "Weighted HCC Score by State" 

save weighted, replace 

clear
**bring in Home Health Compare data on ownership and date certified**
import delimited "E:\Final Chen Project\homehealthcompare.csv", varnames(1)

gen cert = date(datecertified, "MDYhm")

rename typeofownership ownershiptype

gen gov = 0
replace gov = 1 if ownershiptype == "State/County"
replace gov = 1 if ownershiptype == "Combination GOVT & Voluntary"
replace gov = 1 if ownershiptype == "Local"

gen nfp = 0
replace nfp = 1 if ownershiptype == "Private"
replace nfp = 1 if ownershiptype == "Religious Affiliations"
replace nfp = 1 if ownershiptype == "Other"

gen fp = 0
replace fp = 1 if ownershiptype == "Proprietary"

label var gov "Government Home Health Agency"
label var nfp "Not for Profit Home Health Agency"
label var fp "For Profit Home Health Agency"
label var cert "Date Certified "

sort state

by state: egen public = sum(nfp+gov)

by state: gen total = sum(nfp+fp+gov)
by state: replace total = total[_N]

by state:gen percentfp = sum(fp)
by state:replace percentfp = percentfp[_N]
by state: replace percentfp = percentfp/total

by state:gen percentnfp = sum(nfp)
by state:replace percentnfp = percentnfp[_N]
by state:replace percentnfp = percentnfp/total

by state:gen percentgov = sum(gov)
by state:replace percentgov = percentgov[_N]
by state:replace percentgov = percentgov/total
**extracting the year which agency was certified**
gen year = year(cert)

**choosing median years as the tenure 
gen tenure = 1 if cert < 16371
replace tenure = 0 if tenure == .

**Gen based on implementation of PPS**
gen tenure2 = 1 if year <2002
replace tenure2 = 0 if tenure2 == .

*Calcualte the percent of tenured agencies**
by state: egen tenuredtotal = sum(tenure)
by state: egen tenuredtotal2 = sum(tenure2)

by state: gen percenttenured = tenuredtotal/total
by state: gen percenttenured2 = tenuredtotal2/total

save homehealthcomparedata, replace

clear

**Pull in the Dartmouth Data**

clear

import excel "E:\Cost HHA Paper\DartmouthEOL.xls", sheet("2014") firstrow case(lower)

label var  homehealthsector "2 Year EOL Spending Home Health"
label var totalmedicarespending "2 Year EOL Spending Overall"

save dartmouth, replace

** Get the AHRF data** 
** Pulling in same file from old paper topic** 
**Refer to Project.do file for steps**
** Located in Final Chen HHA Folder**

use ahrf
keep state f1321314 f0892413 f1467514 pop_2014

gen physicians1000 = (f1467514/pop_2014)*1000
gen nursingbeds1000	= (f1321314/pop_2014)*1000
gen ltbeds131000 = (f0892413/pop_2014)*1000

save costsahrf, replace

clear

*start merge of data **

use weighted
**Collapsing down to state level**
collapse distinctbeneficiariesnonlupa averagehccscore totalbeneficiaries totalrealpayments weightedhcc, by(state)

save collapsedweight, replace
clear

use homehealthcomparedata

collapse gov nfp fp public total percentfp percentnfp percentgov tenuredtotal tenuredtotal2 percenttenured percenttenured2, by(state)

merge 1:1 state using collapsedweight

keep if _merge == 3
drop _merge 

merge 1:1 state using dartmouth 

keep if _merge == 3
drop _merge

merge 1:1 state using costsahrf 

keep if _merge == 3
drop _merge 

save mergedcomplete, replace

merge 1:1 state using totalpop
keep if _merge == 3
drop _merge

gen per_cap_agency = (total/total_pop_14)*1000
gen per_cap_fp = (fp/total_pop_14)*1000

save mergedcomplete, replace

**Generate % of Medicare Beneficiaries receiving Home Health**
gen percentbeneficiaries = totalbeneficiaries / medicareenrolles2014
*overall COV costs*

egen costssd = sd(homehealthsector)
egen costsmean = mean( homehealthsector)
gen covcosts = costssd/costsmean

sum covcosts

*create cost quintile**

egen costquin = xtile(homehealthsector), nq(5)


*Interquintile COV*
sort costquin

by costquin: egen sdquin = sd(homehealthsector)
by costquin: egen meanquin = mean(homehealthsector)

by costquin: gen cov = sdquin/meanquin

by costquin: sum cov
**Cost ratio  is 3.13 1st to 5th 
gen costration = 5529.39/1763.40

**Cost ratio2 is 2nd to 5th : 1.942 so almost twice as much**
gen costratio2 = 5529.39/2846.76


gen logeol = log(homehealthsector)

save mergedcomplete, replace

*** let's add in the Median household income 

clear

import delimited "E:\Cost HHA Paper\Median Income.csv", clear 

**How to destring in a WAY more efficient way

destring median, generate(median_income) ignore(",")
destring priceagesexrace, generate(price_agesexrace) ignore(",")
rename percentuner10l percent_earning_lt10k

drop median
drop priceagesexrace

merge 1:1 state using mergedcomplete 

save merged_withincome, replace


reg logeol weightedhcc percentbeneficiaries 
outreg2 using table4.doc, replace

reg logeol weightedhcc percentbeneficiaries percentfp percentgov percenttenured
outreg2 using table4.doc, append
reg logeol weightedhcc percentbeneficiaries percentfp percentgov percenttenured nursingbeds1000 ltbeds131000  con_hh 
outreg2 using table4.doc, append


