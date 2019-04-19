/***************************************************************************************************************************************************************************************************************************************

 PLEASE CITE THIS ARTICLE AS:
 
 Werner RM, Coe NB, Qi M, Konetzka RT. Patient Outcomes After Hospital Discharge to Home With Home Health Care vs to a Skilled Nursing Facility. JAMA Intern Med. Published online March 11, 2019. doi:10.1001/jamainternmed.2018.7998

***************************************************************************************************************************************************************************************************************************************/

********************************************************************************
*** Stata do file for defining study cohort, conducting statistical analyses ***
*** and creating tables and figures that showed in paper and appendix.       ***
********************************************************************************

*****************************************
*** Table 1, 2 and Supplementary 4, 6 ***
*****************************************
use [PATH]/pac_all_analytical_1016.dta, clear
keep if snf==1 | hha==1

global pt_covar1 age_adm i.race_num i.sex_num hxinfection otherinfectious metacancer severecancer othercancer diabetes malnutrition liverdisease hematological alcohol psychological motordisfunction seizure chf cadcvd arrhythmias copd lungdisorder ondialysis ulcers septicemia metabolicdisorder irondeficiency cardiorespiratory renalfailure pancreaticdisease arthritis respiratordependence transplants coagulopathy hipfracture
	drop if nh_stay_prior30==1
	drop if hosp_days<3
	drop if ma_enrollment_elig==0 & ffs_enrollment_elig==0
	
	*Create numeric id variable based on hospital provider number 
	egen hosp_prvdrnum_n = group(hosp_prvdrnum)
	
	*Create count of number of days observed (1-30)
	gen ndays=death_dt-dschrgdt if deadin30days==1
	replace ndays=30 if deadin30days==0
	
	*Creating near HHA variable
	gen dist_nearhha_hrr=dd_hhasnf_hrr<0 if dd_hhasnf_hrr~=.
	
	*Check the number of patients received hospice care at SNF
	replace snf_hospice="0" if snf==1 & snf_hospice!="1"
	tab snf_hospice deadin30days if snf==1, row col 
	
	*Check the number of patients received hospice care at SNF
	replace life_prgns_6month="0" if snf==1 & life_prgns_6month!="1"
	tab life_prgns_6month deadin30days if snf==1, row col 
	
	*Drop records of patients that received hospice care at SNF or life prognosis less than 6 months
	drop if snf_hospice=="1" | life_prgns_6month=="1"
	
	*Generate sample
	count
	quietly xtreg hha dist_nearhha_hrr radm30 $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe 
	keep if e(sample)
	count
	
	*Generate DRG samples
	gen drg_joint=1 if inlist(drg_cd,469,470)
	gen drg_sepsis=1 if inlist(drg_cd,870,871,872)
	gen drg_chf=1 if inlist(drg_cd,291,292,293)
	gen drg_pne=1 if inlist(drg_cd,193,194,195)
	gen drg_uti=1 if inlist(drg_cd,689,690)

*****Table 1 & 2. Summary of patient characteristics and outcomes by discharge destination 
    *To SNF
	sum $pt_covar1 dual_stus ma_enrollment_elig soi if snf==1
	sum drg_joint drg_sepsis drg_chf drg_pne drg_uti if snf==1
	sum radm30 non_dsct_hosp dsct_hosp_v1 deadin30days adl_total_improved if snf==1
	sum pmt_amt_pseudo pac_pmt_amt_pseudo total_pmt_60 if snf==1 & ffs_enrollment_elig==1
	
	foreach var of varlist sex_num race_num dual_stus ma_enrollment_elig {
		tab `var' if snf==1
	}

	*To HHA
	sum $pt_covar1 dual_stus ma_enrollment_elig soi if hha==1
	sum drg_joint drg_sepsis drg_chf drg_pne drg_uti if hha==1
	sum radm30 non_dsct_hosp dsct_hosp_v1 deadin30days adl_total_improved if hha==1
	sum pmt_amt_pseudo pac_pmt_amt_pseudo total_pmt_60 if hha==1 & ffs_enrollment_elig==1
	
	foreach var of varlist sex_num race_num dual_stus ma_enrollment_elig {
		tab `var' if hha==1
	}

*****Supplementary Table 4. Summary of patient characteristics and outcomes by discharge destination by near-far
	*Near HHA
	sum hha snf if dist_nearhha_hrr==1 
	sum $pt_covar1 dual_stus ma_enrollment_elig soi if dist_nearhha_hrr==1 
	sum drg_joint drg_sepsis drg_chf drg_pne drg_uti if dist_nearhha_hrr==1
	sum radm30 non_dsct_hosp dsct_hosp_v1 deadin30days adl_total_improved if dist_nearhha_hrr==1
	sum pmt_amt_pseudo pac_pmt_amt_pseudo total_pmt_60 if dist_nearhha_hrr==1

	foreach var of varlist sex_num race_num {
		tab `var' if dist_nearhha_hrr==1 
	}
	
    *Far from HHA
	sum hha snf if dist_nearhha_hrr==0
	sum $pt_covar1 dual_stus ma_enrollment_elig soi if dist_nearhha_hrr==0
	sum drg_joint drg_sepsis drg_chf drg_pne drg_uti if dist_nearhha_hrr==0
	sum radm30 non_dsct_hosp dsct_hosp_v1 deadin30days adl_total_improved if dist_nearhha_hrr==0
	sum pmt_amt_pseudo pac_pmt_amt_pseudo total_pmt_60 if dist_nearhha_hrr==0

	foreach var of varlist sex_num race_num {
		tab `var' if dist_nearhha_hrr==0 
	}
	
	*Summary of any Medicare spending in the prior year 
	gen any_pmt_prior=1 if prior_pmt_amt_sum>0
	replace any_pmt_prior=0 if prior_pmt_amt_sum<=0 | prior_pmt_amt_sum==.
	label variable any_pmt_prior "Any Medicare Payment in the Prior Year"
	label variable dist_nearhha_hrr "Near HHA"
	label define ysn 1 "Yes" 0 "No"
	label values dist_nearhha_hrr ysn
	label values any_pmt_prior ysn
	tab any_pmt_prior dist_nearhha_hrr, col

	*Summary of total Medicare spending amount in the prior year 
	table dist_nearhha_hrr, c(n prior_pmt_amt_sum mean prior_pmt_amt_sum median prior_pmt_amt_sum sd prior_pmt_amt_sum) 
	
	*Summary of ADL scores at admission 
	foreach var of varlist adl_bath_1-adl_total_1 {
	table dist_nearhha_hrr, c(n `var' mean `var' median `var' sd `var') 
	}




********************************
***** Table 3 Main results *****
********************************

*****All discharges (Fee-for-Service and Medicare Advantage)
    *OLS
	quietly xtreg radm30 hha ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm30
	quietly xtreg deadin30days hha $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store dead30
	quietly xtreg adl_total_improved hha adl_total_1 pac_days_all $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store adl_improved_wcontrol
	est table radm30 dead30 adl_improved_wcontrol, keep(hha) b se t p stats(N) title("OLS")
	eststo clear
	
    *Near-far Distance 2SLS
    preserve
	*First stage
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear

	*Second stage
	quietly xtreg radm30 pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm30
	quietly xtreg deadin30days pr_nearhha_hrr $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store dead30
	quietly xtreg adl_total_improved pr_nearhha_hrr adl_total_1 pac_days_all $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store adl_improved_wcontrol
	est table radm30 dead30 adl_improved_wcontrol, keep(pr_nearhha_hrr) b se t p stats(N) title("2nd stage")
		eststo clear

     restore	

*****Fee-for-Service Only
     preserve
     keep if ffs_enrollment_elig==1

    *OLS			
    quietly xtreg pmt_amt_pseudo hha ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store hosppayment
	quietly xtreg pac_pmt_amt_pseudo hha ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store pacpayment
	quietly xtreg total_pmt_60 hha ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store totalpayment60
	est table hosppayment pacpayment totalpayment60, keep(hha) b se t p stats(N) title("OLS")
	eststo clear

    *Near-far Distance 2SLS
	*First stage
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear

	*Second stage
	quietly xtreg pmt_amt_pseudo pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store hosppayment
	quietly xtreg pac_pmt_amt_pseudo pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store pacpayment
	quietly xtreg total_pmt_60 pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store totalpayment60
	est table hosppayment pacpayment totalpayment60, keep(pr_nearhha_hrr) b se t p stats(N) title("2nd stage")
		eststo clear



		
************************************
** Figure 1 and Supplemental 7, 8 **
************************************
*****Figure 1 (Discretionary and Non-discretionary Readmission)
    *OLS
	quietly xtreg non_dsct_hosp hha ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store non_dsct_hosp
	quietly xtreg dsct_hosp_v1 hha ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store dsct_hosp_v1
	est table non_dsct_hosp dsct_hosp_v1, keep(hha) b se t p stats(N) title("OLS")
	eststo clear
	
    *Near-far Distance 2SLS
	*First stage
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear

	*Second stage
	quietly xtreg non_dsct_hosp pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store non_dsct_hosp
	quietly xtreg dsct_hosp_v1 pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store dsct_hosp_v1
	est table non_dsct_hosp dsct_hosp_v1, keep(pr_nearhha_hrr) b se t p stats(N) title("2SLS")
		eststo clear

*****Figure 1 and Supplementary Table 7 & 8 (Medical and Surgical DRGs)
    *Create a indicator for DRGs
	gen drg_med=1 if inlist(drg_cd,871,690,291,292,194,683,193,641,872,190,603,312,689,682,392,191)
	gen drg_rehab=1 if inlist(drg_cd,470,481,65,552)

    *All
    preserve 
    *First Stages
	capture program drop firststage
	program define firststage
		quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
			estimates store `1'
			predict pr_nearhha_`1' if e(sample)
	end
	firststage drg_med
	firststage drg_rehab
	
	est table drg_med drg_rehab, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage" `1')
	eststo clear

    *Second Stages 
	capture program drop secondstage
	program define secondstage
		quietly xtreg radm30 pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
			estimates store radm30
		quietly xtreg deadin30days pr_nearhha_`1' $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
			estimates store dead30
		quietly xtreg adl_total_improved pr_nearhha_`1' adl_total_1 pac_days_all $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
			estimates store adl_improved_wcontrol
		est table radm30 dead30 adl_improved_wcontrol, keep(pr_nearhha_`1') b se t p stats(N) title("Second stage" `1')
		eststo clear

	end
	secondstage drg_med
	secondstage drg_rehab

    restore

	*FFS Only
	preserve
	keep if ffs_enrollment_elig==1
	*First Stages
		capture program drop firststage
		program define firststage
			quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store `1'
				predict pr_nearhha_`1' if e(sample)
		end
		firststage drg_med
		firststage drg_rehab
		
		est table drg_med drg_rehab, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage" `1')
		eststo clear
	
	*Second Stages
		capture program drop secondstage
		program define secondstage
			quietly xtreg pmt_amt_pseudo pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store hosppayment
			quietly xtreg pac_pmt_amt_pseudo pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store pacpayment
			quietly xtreg total_pmt_60 pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store totalpayment60
			est table hosppayment pacpayment totalpayment60, keep(pr_nearhha_`1') b se t p stats(N) title("Second stage" `1')
			eststo clear
	
		end
		secondstage drg_med
		secondstage drg_rehab
	
	restore


*****Figure 1 and Supplementary Table 7 & 8 (Urban and Hospitals without Vertically Integrated PAC)
	gen fullsample=1
	gen white=race_num==1
	gen black=race_num==2
	gen nondual=dual_stus==0
	gen nonintegrated=(hosp_snf==0 & hosp_hha==0)
	gen urban_ffs=(urban==1 & ffs_enrollment_elig==1)
	gen ma_enrollee=ma_enrollment_elig==1
	gen ffs_enrollee=ffs_enrollment_elig==1

	*All Discharges
	preserve 
	*First Stages 
		capture program drop firststage
		program define firststage
			quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store `1'
				predict pr_nearhha_`1' if e(sample)
		end
		firststage fullsample
		firststage white
		firststage black
		firststage dual_stus
		firststage nondual
		firststage urban
		firststage ma_enrollee
		firststage ffs_enrollee
		firststage nonintegrated
		
		est table fullsample white black dual_stus nondual urban ma_enrollee ffs_enrollee nonintegrated, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage" `1')
		eststo clear
	
		
	*Second Stages 
		capture program drop secondstage
		program define secondstage
			quietly xtreg radm30 pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store radm30
			quietly xtreg deadin30days pr_nearhha_`1' $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store dead30
			quietly xtreg adl_total_improved pr_nearhha_`1' adl_total_1 pac_days_all $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store adl_improved_wcontrol
		
			est table radm30 dead30 adl_improved_wcontrol, keep(pr_nearhha_`1') b se t p stats(N) title("Second stage" `1')
			eststo clear
	
		end
		secondstage fullsample
		secondstage white
		secondstage black
		secondstage dual_stus
		secondstage nondual
		secondstage urban
		secondstage ma_enrollee
		secondstage ffs_enrollee
		secondstage nonintegrated
	
	restore 
	
	
	*FFS Discharges only
	preserve 
	keep if ffs_enrollment_elig==1
	*First Stages 
		capture program drop firststage
		program define firststage
			quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store `1'
				predict pr_nearhha_`1' if e(sample)
		end
		firststage fullsample
		firststage white
		firststage black
		firststage dual_stus
		firststage nondual
		firststage urban
		firststage nonintegrated
		
		est table fullsample white black dual_stus nondual urban nonintegrated, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage" `1')
		eststo clear
	
		
	*Second Stages 
		capture program drop secondstage
		program define secondstage
			quietly xtreg pmt_amt_pseudo pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store hosppayment
			quietly xtreg pac_pmt_amt_pseudo pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store pacpayment
			quietly xtreg total_pmt_60 pr_nearhha_`1' ndays $pt_covar1 i.drg_cd i.dschrg_year if `1'==1, i(hosp_prvdrnum_n)fe vce(robust)
				estimates store totalpayment60
		
			est table hosppayment pacpayment totalpayment60, keep(pr_nearhha_`1') b se t p stats(N) title("Second stage" `1')
			eststo clear
	
		end
		secondstage fullsample
		secondstage white
		secondstage black
		secondstage dual_stus
		secondstage nondual
		secondstage urban
		secondstage nonintegrated
	
	restore 
	
	
	
	
************************************
*** Table 4 Summary of Compliers ***
************************************
*****Table 4 Summary of patient characteristics among marginal patients 
    *Generate dummy variable for each patient characteristic 	
	gen age_80=1 if age_adm>=80
	replace age_80=0 if age_adm<80
	
	gen female=1 if sex_num==2
	replace female=0 if sex_num!=2
	
	gen white=1 if race_num==1 
	replace white=0 if race_num!=1 
	
	gen black=1 if race_num==2 
	replace black=0 if race_num!=2 
	
	gen hispanic=1 if race_num==5
	replace hispanic=0 if race_num!=5 
	
	gen asian=1 if race_num==4
	replace asian=0 if race_num!=4
	
	gen other=1 if inlist(race_num, 3,6,0)
	replace other=0 if other==.
	
	gen high_risk=1 if risk=="High"
	replace high_risk=0 if risk=="Low"
	
	foreach x in 65 190 191 193 194 291 292 312 470 481 392 552 603 641 682 683 689 690 871 872 {
		gen drg_`x'=1 if drg_cd==`x'
		replace drg_`x'=0 if drg_cd!=`x'
		sum drg_`x'
	}
	
	gen drg_joint=1 if inlist(drg_cd,469,470)
	replace drg_joint=0 if drg_joint==.
	
	gen drg_sepsis=1 if inlist(drg_cd,870,871,872)
	replace drg_sepsis=0 if drg_sepsis==.
	
	gen drg_chf=1 if inlist(drg_cd,291,292,293)
	replace drg_chf=0 if drg_chf==.
	
	gen drg_pne=1 if inlist(drg_cd,193,194,195)
	replace drg_pne=0 if drg_pne==.
	
	gen drg_uti=1 if inlist(drg_cd,689,690)
	replace drg_uti=0 if drg_uti==.

	*Predict treatment
	quiet xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n) fe vce(robust)
	predict pr_hha
	
	*Generate % go to HHA among those near HHA or far away from HHA
	egen near_hha=mean(pr_hha) if dist_nearhha_hrr==1
	egen far_hha=mean(pr_hha) if dist_nearhha_hrr==0
	
	rename ma_enrollment_elig ma_enroll
	
	preserve 
	foreach var of varlist age_80-drg_uti dual_stus ma_enroll {
	*Generate % go to HHA among those near HHA by patient characteristic 
	egen `var'_near_hha=mean(pr_hha) if dist_nearhha_hrr==1 & `var'==1
	egen `var'_far_hha=mean(pr_hha) if dist_nearhha_hrr==0 & `var'==1
	
	*Generate mean value across data 
	collapse (mean)`var' (mean)`var'_near_hha (mean)`var'_far_hha (mean)near_hha (mean)far_hha
	
	*Calculate compliers proportion and ratio of compliers to full population 
	gen `var'_prop_complier=`var'*((`var'_near_hha-`var'_far_hha)/(near_hha-far_hha))
	gen `var'_complier_ratio=`var'_prop_complier/`var'
	
	*Summarize results
	sum `var'_prop_complier `var' `var'_complier_ratio
	
	restore 
	preserve
	}

	
	
	
***********************************
*** Supplementary Table 1 and 2 ***
***********************************
*****Summarize instrument
	*Supplementary Table 1. Summary of differential Distance 
	sum snf_dist_hrr hha_dist_hrr dd_hhasnf_hrr, det

	*Supplementary Table 2. Summary of Near-HHA Variables
	tab dist_nearhha_hrr
	table dist_nearhha_hrr, c(min dd_hhasnf_hrr p25 dd_hhasnf_hrr p50 dd_hhasnf_hrr p75 dd_hhasnf_hrr max dd_hhasnf_hrr)
	
	


******************************************************
*** Supplementary Table 3 and Line 189-191 in Text ***
******************************************************
*****QUARTILES OF DISTANCE
	*Creating quartiles
	_pctile dd_hhasnf_hrr, p(10, 50, 90)
	return list
	gen dist4=1 if dd_hhasnf_hrr<=r(r1)
	replace dist4=2 if dist4==. & dd_hhasnf_hrr<=r(r2)
	replace dist4=3 if dist4==. & dd_hhasnf_hrr<=r(r3)
	replace dist4=4 if dist4==. & (dd_hhasnf_hrr>r(r3) & dd_hhasnf_hrr~=.)
	table dist4, c(min dd_hhasnf_hrr p50 dd_hhasnf_hrr max dd_hhasnf_hrr n dd_hhasnf_hrr)

	*First stage continuous
	quietly xtreg hha dd_hhasnf_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_hha if e(sample)
	est table first_stage, keep(dd_hhasnf_hrr) b t p stats(N) title("1st stage w dd")
	eststo clear
	
	*First stage near-far
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear
	
	*First stage quartiles
	quietly xtreg hha i.dist4 $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		testparm i(2/4).dist4
		estimates store first_stage
		predict pr_nearhha4 if e(sample)
	est table first_stage, keep(i.dist4) b t p stats(N) title("1st stage w near HHA quartiles")
	eststo clear

*****Vacationers Subsample
	count if hosp_dist>75
	count if hosp_dist>150
	count if hosp_dist>250

	*First stage binary
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if hosp_dist>75, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage75
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if hosp_dist>150, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage150
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year if hosp_dist>250, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage250
	est table first_stage75 first_stage150 first_stage250, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator among vacationers")
	eststo clear


*****Summary of Effect of Distance on Choice of HHA (Line 189-191 in Text)
	sum hha if dist_nearhha_hrr==1
	sum hha if dist_nearhha_hrr==0

	
	
	
*******************************************
*** Supplementary Table 5 - Top 20 DRGs ***
*******************************************
*****Check the top 20 DRGs in the study cohort
	tab drg_cd, sort

	
	
	
	
*****************************
*** Supplementary Table 9 ***
*****************************

*****Near-far Distance 2SLS (All)
    preserve
	*First stage
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear

	*Second stage
	quietly xtreg radm_or_dd30 pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm_or_dd30
	est table radm_or_dd30, keep(pr_nearhha_hrr) b se t p stats(N) title("2nd stage")
		eststo clear
    restore
 
*****Near-far Distance 2SLS (FFS)
	keep if ffs_enrollment_elig==1
    preserve
	*First stage
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear

	*Second stage
	quietly xtreg radm_or_dd30 pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm_or_dd30_1
	quietly xtreg radm_or_dd30 pr_nearhha_hrr $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm_or_dd30_2
	est table radm_or_dd30_1 radm_or_dd30_2, keep(pr_nearhha_hrr) b se t p stats(N) title("2nd stage")
		eststo clear
    restore 

*****Near-far Distance 2SLS (MA)
	preserve 
	keep if ma_enrollment_elig==1
	*First stage
	quietly xtreg hha dist_nearhha_hrr $pt_covar1 i.drg_cd  i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store first_stage
		predict pr_nearhha_hrr if e(sample)
	est table first_stage, keep(dist_nearhha_hrr) b t p stats(N) title("1st stage w near HHA indicator")
	eststo clear

	*Second stage
	quietly xtreg radm_or_dd30 pr_nearhha_hrr ndays $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm_or_dd30_1
	quietly xtreg radm_or_dd30 pr_nearhha_hrr $pt_covar1 i.drg_cd i.dschrg_year, i(hosp_prvdrnum_n)fe vce(robust)
		estimates store radm_or_dd30_2
	est table radm_or_dd30_1 radm_or_dd30_2, keep(pr_nearhha_hrr) b se t p stats(N) title("2nd stage")
		eststo clear
    restore 






