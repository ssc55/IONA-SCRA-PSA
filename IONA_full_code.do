//Cleaning & preparation 

gen id = Accrualno
rename DetectDrug21 iona_no_dup//Duplicate of IONANo

drop DetectDrug20//No data in this variable
multencode DetectDrug1-DetectDrug19, gen(drugdetect1-drugdetect19)
multencode Reportedexposure1 reportedexposure2 reportedexposure3 reportedexposure4, gen(repexp1-repexp4)

//Encode datetime string as date variable
gen date=date(datetime,"MDY####")//month day year, ignoring time
format date %td
gen month = month(date)
gen quarter = quarter(date)
gen year = year(date)
gen ym = ym(year,month)

gen start = 665 //specify that the first month = July 2015
format start %tm
gen months = ym - start //continious variable counting number of months since July 2015

reshape long drugdetect repexp, i(id) j(number)

xtset id

destring Age, gen(age) force

encode SexMale1Female0, gen(gender)
recode gender 3=1 4=2 5=2
label define gender 1 "Female" 2 "Male"
label values gender gender

//Clean SCRA data & combine variations of the same compound 
recode drugdetect (3=.)//212-2 coded separtely to WIN55,212-2 
recode drugdetect (8=10) (11=10)//Combine different variations of 4F-MDMB-BINACA
recode drugdetect (12=22)//Combine different variations of 5F-MDMB-PICA
recode drugdetect (13=25)//Combine different variations of 5F-NPB-22
recode drugdetect (15=23) (24=23)//Combine different variations of 5F-MDMB-PINACA & 5F-ADB
recode drugdetect (26=27)//Combine different variations of 5F-PB-22
recode drugdetect (31=30) (32=30)//Combine different variations of AB-FUBINACA & AB-FUBINACA deamino carboxylic acid
recode drugdetect (41=40) (93=40)// Combine AMB-FUBINACA, AMB-FUBINACA-desmethyl & FUB-AMB
recode drugdetect (121/124=122)//Combine different variations of MDMB-4en-PINACA  & MDMB-4en-PINACA-desmethyl

//Generate SCRA list variable
gen scralist=drugdetect if inrange(drugdetect, 9, 40) | drugdetect==50| inrange(drugdetect,92, 95)|inrange(drugdetect,121, 127)| drugdetect==152| drugdetect==153| drugdetect==185| drugdetect==194
label copy DetectDrug1 scralabel
label values scralist scralabel 
label define scralabel 17 "5F-EMB-PINACA" 18 "5F-APINACA" 19 "5F-AMB-PINACA" 36 "4F-APINACA" 50 "QUCHIC" 185 "5F-APICA" 194 "WIN-55,212-2", modify


//Clean (nonSCRA) drug data & classify into drug classes
recode drugdetect (197=47) (198=49) (200=53) (204=62) (205=67) (206=71) (207=72) (208=74) (209=76) (210=77) (212=82) (213=83) (215=90) (217=96) (218=100) (219=101) (220=104) (222=106) (223=108) (224=131) (226=132) (228=133) (229=136) (230=140) (235=144) (237=154) (238=158) (239=164) (242=172) (243=172) (244=178) (245=181) (246=183) (248=188)//combine duplicate labels

gen drugshort =1 if inrange(drugdetect, 9, 40) | drugdetect==50| inrange(drugdetect,92, 95)|inrange(drugdetect,121, 127)| drugdetect==152| drugdetect==153| drugdetect==185| drugdetect==194//SCRAs

recode drugshort .=2 if drugdetect==47|drugdetect==61|drugdetect==62|drugdetect==63|inrange(drugdetect, 66, 69)|drugdetect==76|drugdetect==77|drugdetect==78|drugdetect==81|drugdetect==82|drugdetect==89|drugdetect==90|drugdetect==99|drugdetect==100|drugdetect==101|drugdetect==115|drugdetect==116|drugdetect==129|drugdetect==130|drugdetect==140|drugdetect==141|drugdetect==158|drugdetect==159|drugdetect==177|drugdetect==199|drugdetect==211|drugdetect==216|drugdetect==241//Benzos

recode drugshort .=3 if drugdetect==42|inrange(drugdetect, 144, 148)|drugdetect==196|inrange(drugdetect, 43, 45)|drugdetect==80|drugdetect==83|drugdetect==84|inrange(drugdetect, 96, 98)|drugdetect==102|drugdetect==105|drugdetect==106|drugdetect==107|drugdetect==164|drugdetect==167|drugdetect==168|inrange(drugdetect,182,184)|inrange(drugdetect,190,192)|drugdetect==74|drugdetect==53|drugdetect==88|drugdetect==132|drugdetect==156|drugdetect==170|drugdetect==171|drugdetect==174|drugdetect==191|drugdetect==225|drugdetect==227|drugdetect==247//Opioids

recode drugshort .=4 if drugdetect==51|drugdetect==71|drugdetect==72|drugdetect==73//Cocaine

recode drugshort .=5 if inrange(drugdetect, 55, 58)|drugdetect==189|drugdetect==202|drugdetect==203//THC

recode drugshort .=6 if drugdetect==133|drugdetect==136//Methamphetamine

recode drugshort .=7 if inrange(drugdetect,117, 120)//MDMA

recode drugshort .=8 if drugdetect==49//Amphetamine

recode drugshort .=9 if drugdetect==103|drugdetect==104|drugdetect==178//Gabpentinoids

recode drugshort .=10 if drugdetect==1|drugdetect==4|drugdetect==5|drugdetect==6|drugdetect==46|drugdetect==52|drugdetect==54|drugdetect==59|drugdetect==60|drugdetect==65|drugdetect==91|drugdetect==128|drugdetect==134|drugdetect==137|drugdetect==139|drugdetect==149|drugdetect==150|drugdetect==214|drugdetect==236|drugdetect==251|drugdetect==7|drugdetect==131//Cathinones/stimulants 

recode drugshort .=11 if drugdetect==48|drugdetect==64|drugdetect==70|drugdetect==79|inrange(drugdetect, 85, 87)|inrange(drugdetect,108,114)|drugdetect==135|drugdetect==138|drugdetect==142|drugdetect==143|drugdetect==151|drugdetect==154|drugdetect==155|drugdetect==162|drugdetect==163|drugdetect==164|drugdetect==165|drugdetect==169|inrange(drugdetect,172, 173)|inrange(drugdetect,175, 181)|drugdetect==186|drugdetect==187|drugdetect==188|drugdetect==193|drugdetect==195|drugdetect==201|drugdetect==221|inrange(drugdetect,231,234)|drugdetect==240|drugdetect==247|drugdetect==249|drugdetect==250//Other

label define drugshort 1 "SCRA" 2 "Benzos" 3 "Opioids" 4 "Cocaine" 5 "THC" 6 "Methamphetamine" 7 "MDMA" 8"Amphetamine" 9 "Gabpentinoids" 10 "Cathinones/stimulants" 11 "Other"

label values drugshort drugshort

//Generate SCRA grouping variable

egen nodrug_detected = max(drugshort), by(id)
recode nodrug_detected .=1 1/max=0
egen scragroup = max(scralist), by(id)
recode scragroup .=0 1/max=1 if nodrug_detected==0

//Generate number of SCRAs and non-SCRA drugs detected

egen num_scra_n =nvals(scralist), by(id)
egen num_scra = max(num_scra_n), by(id)

egen num_nonscra_n =count(drugshort) if drugshort > 1, by(id)
egen num_nonscra = max(num_nonscra_n), by(id)

drop num_scra_n num_nonscra_n

//Generate suspected NPS variable based on reported exposure 

label values repexp Reportedexposure1//Assign label to repexp if lost in reshape

gen nps_suspect =1 if inrange(repexp, 2, 12)|inrange(repexp, 15, 19)|inrange(repexp, 21, 26)|inrange(repexp, 28, 32)|inrange(repexp, 34, 76)|repexp==78|inrange(repexp, 82, 84)|repexp==87|repexp==89|repexp==92|inrange(repexp, 102, 120)|inrange(repexp, 122, 136)|inrange(repexp, 139, 141)|repexp==144|repexp==145|repexp==147|repexp==148|repexp==155|repexp==157|repexp==158|repexp==164|repexp==166|repexp==170|repexp==171|repexp==172|repexp==175|inrange(repexp, 177, 178)|repexp==181|repexp==182|repexp==185|repexp==186|repexp==187|repexp==191|repexp==193|repexp==194|repexp==196|repexp==204|repexp==206|repexp==208|repexp==210|inrange(repexp, 212, 226)|inrange(repexp,229,236)|inrange(repexp, 238, 240)|repexp==243|repexp==249|repexp==250|inrange(repexp, 252, 254)|repexp==256|inrange(repexp,258, 274)|inrange(repexp, 279, 290)|inrange(repexp, 292, 293)|inrange(repexp, 295, 300)|inrange(repexp, 302, 303)|inrange(repexp, 309, 313)|inrange(repexp, 315, 322)|inrange(repexp,325, 327)|inrange(repexp, 331, 332)|repexp==335|repexp==337|repexp==338|repexp==342|repexp==343|repexp==347|repexp==348|inrange(repexp, 350, 354)|inrange(repexp, 356, 358)|inrange(repexp, 361, 363)|inrange(repexp,365,369)|inrange(repexp, 372, 373)|repexp==375|inrange(repexp, 379, 385)|inrange(repexp, 387, 394)|inrange(repexp,397,406)|repexp==414|inrange(repexp, 418, 423)|inrange(repexp, 425, 427)|repexp==429|repexp==430|inrange(repexp, 433, 440)|repexp==442|inrange(repexp, 445, 464)|inrange(repexp, 466, 475)|inrange(repexp, 478, 479)|repexp==481|inrange(repexp,483,487)|repexp==488|repexp==490|repexp==491|repexp==493|inrange(repexp, 496, 498)|inrange(repexp, 502, 539)|repexp==541|repexp==544|repexp==546|inrange(repexp, 549, 576)|inrange(repexp, 579, 594)|repexp==598

recode repexp 600=. 237=. 

egen repexp_missing = max(repexp), by(id)

recode  repexp_missing .=1 2/max=0

egen nps_suspect_group = max(nps_suspect), by (id)
recode nps_suspect_group .=0 if repexp_missing==0

//Generate reported SCRA variable
gen rep_scra =1 if repexp==4|repexp==8|repexp==11|repexp==34|repexp==35|repexp==51|repexp==69|repexp==70|inrange(repexp,102,109)|repexp==124|repexp ==126|repexp==129|repexp==131|repexp==139|repexp==140|repexp==141|repexp==164|repexp==196|repexp==210|repexp==229|repexp==240|repexp==243|repexp==250|repexp==261|repexp==264|repexp==265|repexp==273|repexp==274|repexp==282|repexp==286|repexp==316|repexp==317|repexp==318|repexp==319|repexp==353|repexp==358|repexp==372|inrange(repexp,389, 393)|drugdetect==402|repexp==420|repexp==427|repexp==440|inrange(repexp, 445, 459)|repexp==464|repexp==483|repexp==484|repexp==490|repexp==508|repexp==509|repexp==539|repexp==544

egen rep_scra_group = max(rep_scra), by(id)
recode rep_scra_group .=0 

gen rep_scra_type = 4 if repexp == 4|repexp==8 |repexp ==34| repexp == 35 |repexp == 51 |repexp == 69|repexp ==70|repexp == 109|repexp ==124|repexp ==126|repexp ==129|repexp ==131|repexp ==140|repexp ==164|repexp ==196|repexp ==250|repexp ==240|repexp ==243|repexp ==250|repexp ==264|repexp ==265|repexp ==286|repexp ==282 |repexp ==286|repexp ==317|repexp ==319|repexp ==440|inrange(repexp,445, 459)|repexp ==464|repexp ==508|repexp ==509|repexp ==539

recode rep_scra_type . = 3 if inrange(repexp, 103, 108)| repexp==316|repexp==317

recode rep_scra_type . = 2 if inrange(repexp, 389, 393)

recode rep_scra_type . = 1 if rep_scra==1


label define rep_scra_type 4 "Spice/SCRA" 3 "Black Mamba" 2 "Pandora" 1 "Other named product"
label values rep_scra_type rep_scra_type

//Generate unconcontrolled NPS variable
gen uncontrolled_nps = drugdetect if drugdetect==1|inrange(drugdetect, 4, 6)|drugdetect==46|drugdetect==52|drugdetect==54|drugdetect==65|drugdetect==82|drugdetect==85|drugdetect==91|inrange(drugdetect, 99, 101)|drugdetect==128|drugdetect==129|drugdetect==135|drugdetect==139|inrange(drugdetect, 149,151)|drugdetect==159|drugdetect==167|drugdetect==168|drugdetect==190|drugdetect==214|drugdetect==216

recode uncontrolled_nps 1/max=1
recode uncontrolled_nps .=2 if !missing(drugshort)

egen nps_only_group = max(uncontrolled_nps), by(id)

//Generatre inclusion variable based on reported exposure, date of presentation and controlled drugs detected
gen include =1 if nps_suspect_group==1 | repexp_missing==1
recode include .=0
replace include =0 if ym < tm(2015m7) | ym > tm(2019m12)
replace include =0 if nps_only_group==1
replace include =0 if drugshort==.
egen includegroup = max(include), by(id)

//Generate isolated SCRA use variable 
egen iso_scra = nvals(drugshort) if scragroup==1, by(id)
recode iso_scra 2/max=0

//Clean site data
encode Siteno, gen(siteno)
gen site =1 if inrange(siteno, 1, 8)
recode site .=2 if inrange(siteno, 9, 165)
recode site .=3 if inrange(siteno, 166, 168)
recode site .=4 if inrange(siteno, 169, 212)
recode site .=5 if inrange(siteno, 213, 224)
recode site .=6 if siteno == 225
recode site .=7 if inrange(siteno, 226, 283)
recode site .=8 if inrange(siteno, 284, 290)
recode site .=9 if inrange(siteno, 291, 311)
recode site .=10 if siteno==312
recode site .=11 if inrange(siteno, 313, 463)
recode site .=12 if inrange(siteno, 464, 491)
recode site .=13 if siteno==492
recode site .=14 if inrange(siteno, 493, 574)
recode site .=15 if siteno ==575
recode site .=16 if inrange(siteno, 576, 591)
recode site .=17 if inrange(siteno, 592, 656)
recode site .=18 if inrange(siteno, 657, 661)
recode site .=19 if inrange(siteno, 662, 670)
recode site .=20 if inrange(siteno, 671, 672)
recode site .=21 if inrange(siteno, 673, 732)
recode site .=22 if inrange(siteno, 733, 776)

recode site .=23 if inrange(siteno, 777, 797)
recode site .=24 if inrange(siteno, 798, 853)
recode site .=25 if inrange(siteno, 854, 862)
recode site .=26 if inrange(siteno, 863, 950)
recode site .=27 if siteno == 951
recode site .=28 if inrange(siteno, 952, 962)
recode site .=29 if inrange(siteno, 963, 1057)
recode site .=30 if inrange(siteno, 1058, 1069)
recode site .=31 if inrange(siteno, 1070, 1076)
recode site .=32 if inrange(siteno, 1077, 1086)
recode site .=33 if inrange(siteno, 1087, 1091)
recode site .=34 if inrange(siteno, 1092, 1095)
recode site .=35 if inrange(siteno, 1096, 1102)
recode site .=36 if inrange(siteno, 1103, 1121)
recode site .=37 if siteno == 1122


 label define site 1 "BOLT" 2 "BTH" 3 "CAV" 4 "CMFT" 5 "DER" 6 "DMH" 7 "ESTH" 8 "FPH" 9 "KCH" 10 "LGI" 11 "LOTH" 12 "LRI" 13 "MTW" 14 "NHSG" 15 "NOR" 16 "NTHT" 17 "NUTH" 18 "PAT" 19 "PLY" 20 "QEW" 21 "RBH" 22 "RDE" 23 "RLBUHT" 24 "RLH" 25 "RUH" 26 "SGH" 27 "SJH" 28 "SMH" 29 "STH" 30 "STHK" 31 "TST" 32 "UCLH" 33 "UHB" 34 "WCH" 35 "WEX" 36 "WHH" 37 "WREX"

label values site site

encode Region, gen(region)
recode region 1=3 if site==5
recode region 5=4 if site==16



//Prepare data for time series analysis

drop nps_suspect uncontrolled_nps include rep_scra iso_scra//drop variables not constant within id (id-constant versions of these variables still retained)

reshape wide drugdetect repexp drugshort scralist rep_scra_type, i(id) j(number)

//Generate dummy variable indicating whether sites are active in each of the 54 months (based on first & last recruit)   

bys site: egen first_recruit = min(months)
bys site: egen last_recruit = max(months)
format first_recruit last_recruit %tm


replace last_recruit = 39 if site==1 //Change sites last recruitment to account for disruption if recruitment gap >=1 year
replace last_recruit = 48 if site==31
replace last_recruit = 51 if site==21

forvalues j = 1/54 { 

bys site: gen site_active_m`j'=0
replace site_active_m`j' =1 if first_recruit <= `j' & last_recruit >=`j'
  }


//Generate variable with the total count of active sites in each of the 54 months
forvalues j = 1/54 { 
egen count_active_sites_m`j'=nvals(site) if site_active_m`j'==1 & includegroup==1
  }

//Generate monthly counts for SCRA and non-SCRA cases  
bys months: egen scra_month = count(scragroup) if scragroup==1 & includegroup==1
bys months: egen nonscra_month = count(scragroup) if scragroup==0 & includegroup==1
bys months: egen total_month = count(scragroup) if includegroup==1


collapse (max) scra_month nonscra_month count_active_sites_m1-count_active_sites_m54 if includegroup==1, by (months)
recode scra_month nonscra_month (.=0)


gen no_sites = . 
forvalues j = 1/54 { 
replace no_sites = count_active_sites_m`j' if months==`j'
}

drop count_active_sites_m1-count_active_sites_m54


//Calculate average number of presentations per month & number of active months across individual sites - requires seperate dataset created from previous wide version
bys site: egen first_recruit = min(months)
bys site: egen last_recruit = max(months)


replace last_recruit = 39 if site==1 //Change sites last recruitment to account for disruption if recruitment gap >=1 year
replace last_recruit = 48 if site==31
replace last_recruit = 51 if site==21

gen site_first_active = first_recruit
gen site_inactive = last_recruit

replace site_first_active = 1 if site_first_active < 1
replace site_inactive = 54 if site_inactive > 54

bys site ym: egen site_scra_month = count(scragroup) if scragroup==1 & includegroup==1
bys site ym: egen site_nonscra_month = count(scragroup) if scragroup==0 & includegroup==1
bys site ym: egen site_total_month = count(scragroup) if !missing(scragroup) & includegroup==1
bys site ym: egen exclude_recruit = count(scragroup) if !missing(scragroup) & includegroup==0



forvalues j = 1/54 { 
bys site: gen site_active_m`j'=0
replace site_active_m`j' =1 if first_recruit <= `j' & last_recruit >=`j'
  }
forvalues j = 1/54 {
recode site_scra_month .=0 if site_active_m`j'==1
recode site_nonscra_month .=0 if site_active_m`j'==1
recode site_total_month .=0 if site_active_m`j'==1 
}

collapse (max) site_scra_month site_nonscra_month site_total_month exclude_recruit site_first_active site_inactive, by(site  months)

xtset site months
tsfill

sort months site

bys site: egen site_sum_scra = sum(site_scra_month)
bys site: egen site_sum_nonscra = sum(site_nonscra_month)
bys site: egen site_sum_total = sum(site_total_month)
drop if site_sum_total==0

bys months: egen no_sites = count(site)

gen include=1 if inrange(months, 1, 54)

recode site_scra_month site_nonscra_month site_total_month (.=0) if include==1

drop if include!=1

bys site: gen active_duration = (site_inactive - site_first_active ) + 1 

bys site: gen site__monthly_average = site_sum_total/active_duration

//Time series analysis - using aggregate level data prepared above

tsset months

gen degrees = (months/12)*360//time divided by the number of time points in a year multiply by  degrees in a circle
fourier degrees, n(1)//specifies the number of cos and sin pairs - fit number of pairs sequentially, final number informed by model fit 

//Generate variables representing trend/intercept for pre/post intervention period for PSA & MDA
gen psa_trend1 = months-12
replace  psa_trend1 = 0 if months >= 12
generate psa_trend2 = months - 12 
replace  psa_trend2 = 0 if months < 12
generate psa_int1 = 1
replace  psa_int1 = 0 if months >= 12
generate psa_int2 = 1
replace  psa_int2 = 0 if months < 12

gen mda_trend_jan1 = months-19
replace  mda_trend_jan1 = 0 if months >= 19
generate mda_trend_jan2 = months - 19 
replace  mda_trend_jan2 = 0 if months < 19
generate mda_int_jan1 = 1
replace  mda_int_jan1 = 0 if months >= 19
generate mda_int_jan2 = 1
replace  mda_int_jan2 = 0 if months < 19

//Model estimating trend and intercept in SCRA exposure cases before/after PSA 
glm scra_month psa_int1 psa_trend1 psa_int2 psa_trend2 no_sites cos* sin*, family (poisson) link(log) scale(x2) nocons eform 

//Generate model predicted values and thier 95% CI estimate
predictnl yhat_scra_psa = predict(), ci(lb1_scra_psa ub1_scra_psa) 

//Check residuals for autocorrelation
predict residuals_scra_psa, r
twoway (scatter residuals_scra_psa months), yline(0)
corrgram residuals_scra_psa


//Model estimating trend and intercept in SCRA exposure cases before/after MDA 
glm scra_month mda_int_jan1 mda_trend_jan1 mda_int_jan2 mda_trend_jan2 no_sites cos* sin*, family (poisson) link(log) scale(x2) nocons eform

//Generate model predicted values and their 95% CI estimate
predictnl yhat_scra_mda = predict(), ci(lb1_scra_mda ub1_scra_mda) 

//Check residuals for autocorrelation
predict residuals_scra_mda, r
twoway (scatter residuals_scra_mda months), yline(0)
corrgram residuals_scra_mda


//Model estimating trend and intercept in non-SCRA exposure cases before/after PSA 
glm nonscra_month psa_int1 psa_trend1 psa_int2 psa_trend2 no_sites cos* sin*, family (poisson) link(log) scale(x2) nocons eform 

//Generate model predicted values and their 95% CI estimate
predictnl yhat_nonscra_psa = predict(), ci(lb1_nonscra_psa ub1_nonscra_psa) 

//Check residuals for autocorrelation
predict residuals_nonscra_psa, r
twoway (scatter residuals_nonscra_psa months), yline(0)
corrgram residuals_nonscra_psa


//Model estimating trend and intercept in non-SCRA exposure cases before/after MDA 
glm nonscra_month mda_int_jan1 mda_trend_jan1 mda_int_jan2 mda_trend_jan2 no_sites cos* sin*, family (poisson) link(log) scale(x2) nocons eform

//Generate model predicted values and their 95% CI estimate
predictnl yhat_nonscra_mda = predict(), ci(lb1_nonscra_mda ub1_nonscra_mda) 

//Check residuals for autocorrelation
predict residuals_nonscra_mda, r
twoway (scatter residuals_nonscra_mda months), yline(0)
corrgram residuals_nonscra_mda


//Sensitivity analyses with total hospital presentations included as an offset variable
gen ln_totalcount = ln(scra_month + nonscra_month)

glm scra_month psa_int1 psa_trend1 psa_int2 psa_trend2 no_sites cos* sin*, family (poisson) link(log) nocons eform offset(ln_totalcount)

glm scra_month mda_int_jan1 mda_trend_jan1 mda_int_jan2 mda_trend_jan2 no_sites cos* sin*, family (poisson) link(log) nocons eform offset(ln_totalcount)

//Sensitivty analyses with the change point for the MDA amendment at December
gen mda_trend_dec1 = months-18
replace  mda_trend_dec1 = 0 if months >= 18
generate mda_trend_dec2 = months - 18 
replace  mda_trend_dec2 = 0 if months < 18
generate mda_int_dec1 = 1
replace  mda_int_dec1 = 0 if months >= 18
generate mda_int_dec2 = 1
replace  mda_int_dec2 = 0 if months < 18 

glm scra_month mda_int_dec1 mda_trend_dec1 mda_int_dec2 mda_trend_dec2 no_sites cos* sin*, family (poisson) link(log) scale(x2) nocons eform

glm nonscra_month mda_int_dec1 mda_trend_dec1 mda_int_dec2 mda_trend_dec2 no_sites cos* sin*, family (poisson) link(log) scale(x2) nocons eform