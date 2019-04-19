/***************************************************************************************************************************************************************************************************************************************

 PLEASE CITE THIS ARTICLE AS:
 
 Werner RM, Coe NB, Qi M, Konetzka RT. Patient Outcomes After Hospital Discharge to Home With Home Health Care vs to a Skilled Nursing Facility. JAMA Intern Med. Published online March 11, 2019. doi:10.1001/jamainternmed.2018.7998

***************************************************************************************************************************************************************************************************************************************/

/**************************************************************************************************************************************************************************************
 *Goal: Create an analytical data set which includes records of eligible discharge from acute-care hospital, their post-discharge destination, patient outcomes, Medicare spending,
        patient and instituion characteristics and other information related

 *Time frame: Jan 1st 2010 - Nov 1st 2016
**************************************************************************************************************************************************************************************/

/*********************************************************************************
 Step 1: Define study cohort for 2010-2016, update new criteria for those died 
         within 60 days after discharge;
*********************************************************************************/
*Set up library references and format of variables;
filename initial "[PATH]/Initial.sas";
%include initial;
options linesize=75 nodate nonumber;

*Read data from MedPAR data 2010-2016;
*Change SSLSSNF eq "S" to substr(PRVDR_NUM,3,1) in ('0','M','R','S','T'), modified 20160621;
data temp.MedPAR2010_16;
set Medpar.Mp100mod_2010 Medpar.Mp100mod_2011 Medpar.Mp100mod_2012 Medpar.Mp100mod_2013 Medpar.Mp100mod_2014 Medpar.Mp100mod_2015 Medpar.Mp100mod_2016;
if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or substr(PRVDR_NUM,3,2)='13') & SPCLUNIT not in ('M','R','S','T') then output;
keep BENE_ID SSLSSNF DSCHRGDT SPCLUNIT ADMSNDT DSCHRGCD DSTNTNCD MEDPAR_ID DRG_CD PT_ID PMT_AMT PRVDR_NUM BENE_ZIP UTIL_DAY LOSCNT
     DGNS_CD01 DGNS_CD02 DGNS_CD03 DGNS_CD04 DGNS_CD05 DGNS_CD06 DGNS_CD07 DGNS_CD08 DGNS_CD09 DGNS_CD10 DGNS_CD11 DGNS_CD12 DGNS_CD13 DGNS_CD14 
     DGNS_CD15 DGNS_CD16 DGNS_CD17 DGNS_CD18 DGNS_CD19 DGNS_CD20 DGNS_CD21 DGNS_CD22 DGNS_CD23 DGNS_CD24 DGNS_CD25  
     PRCDR_CD1-PRCDR_CD25 SRC_ADMS TYPE_ADM 
     DGNS_E_1_CD DGNS_E_2_CD DGNS_E_3_CD DGNS_E_4_CD DGNS_E_5_CD DGNS_E_6_CD DGNS_E_7_CD DGNS_E_8_CD DGNS_E_9_CD DGNS_E_10_CD DGNS_E_11_CD DGNS_E_12_CD;
run; *total 96,091,346 records in MedPAR files;

proc sql;
create table mp.MedPAR2010_16 as
select * from temp.MedPAR2010_16
where DSCHRGCD eq 'A' & ADMSNDT ge 18263 & DSCHRGDT+60 le 20819;
quit; *90,522,984 records are admitted later than 01/01/2010 and discharged 60 days before 12/31/2016 (Updated);	


*Read data from Denominator data 2010-2016;
data Denominator2010_16_data;
set Denom.Dn100mod_2010 Denom.Dn100mod_2011 Denom.Dn100mod_2012 Denom.Dn100mod_2013 Denom.Dn100mod_2014 Denom.Dn100mod_2015 Denom.Dn100mod_2016;
rename  BUYIN01=BUYIN1 BUYIN02=BUYIN2 BUYIN03=BUYIN3 BUYIN04=BUYIN4 BUYIN05=BUYIN5 BUYIN06=BUYIN6 BUYIN07=BUYIN7 BUYIN08=BUYIN8 BUYIN09=BUYIN9
        HMOIND01=HMOIND1 HMOIND02=HMOIND2 HMOIND03=HMOIND3 HMOIND04=HMOIND4 HMOIND05=HMOIND5 HMOIND06=HMOIND6 HMOIND07=HMOIND7 HMOIND08=HMOIND8 HMOIND09=HMOIND9;	         
keep BENE_ID BENE_DOB DEATH_DT RFRNC_YR SEX RACE HMOIND: BUYIN: ;
run; *total 385,661,111 records (updated);

data Dn100mod_2010; set Denominator2010_16_data; where RFRNC_YR=2010; rename DEATH_DT=DEATH_DT_10; run;
data Dn100mod_2011; set Denominator2010_16_data; where RFRNC_YR=2011; rename BUYIN1-BUYIN12=BUYIN13-BUYIN24; rename HMOIND1-HMOIND12=HMOIND13-HMOIND24; rename DEATH_DT=DEATH_DT_11; run;
data Dn100mod_2012; set Denominator2010_16_data; where RFRNC_YR=2012; rename BUYIN1-BUYIN12=BUYIN25-BUYIN36; rename HMOIND1-HMOIND12=HMOIND25-HMOIND36; rename DEATH_DT=DEATH_DT_12; run;
data Dn100mod_2013; set Denominator2010_16_data; where RFRNC_YR=2013; rename BUYIN1-BUYIN12=BUYIN37-BUYIN48; rename HMOIND1-HMOIND12=HMOIND37-HMOIND48; rename DEATH_DT=DEATH_DT_13; run;
data Dn100mod_2014; set Denominator2010_16_data; where RFRNC_YR=2014; rename BUYIN1-BUYIN12=BUYIN49-BUYIN60; rename HMOIND1-HMOIND12=HMOIND49-HMOIND60; rename DEATH_DT=DEATH_DT_14; run;
data Dn100mod_2015; set Denominator2010_16_data; where RFRNC_YR=2015; rename BUYIN1-BUYIN12=BUYIN61-BUYIN72; rename HMOIND1-HMOIND12=HMOIND61-HMOIND72; rename DEATH_DT=DEATH_DT_15; run;
data Dn100mod_2016; set Denominator2010_16_data; where RFRNC_YR=2016; rename BUYIN1-BUYIN12=BUYIN73-BUYIN84; rename HMOIND1-HMOIND12=HMOIND73-HMOIND84; rename DEATH_DT=DEATH_DT_16; run;

proc sort data=Dn100mod_2010; by BENE_ID; run;
proc sort data=Dn100mod_2011; by BENE_ID; run;
proc sort data=Dn100mod_2012; by BENE_ID; run;
proc sort data=Dn100mod_2013; by BENE_ID; run;
proc sort data=Dn100mod_2014; by BENE_ID; run;
proc sort data=Dn100mod_2015; by BENE_ID; run;
proc sort data=Dn100mod_2016; by BENE_ID; run;

data mp.Denominator2010_16_data;
merge Dn100mod_2010 Dn100mod_2011 Dn100mod_2012 Dn100mod_2013 Dn100mod_2014 Dn100mod_2015 Dn100mod_2016;
by BENE_ID;
run; *total 72,872,500 records (updated) in denominator files;

*Test whether multiple death date exists;
data Ning_pac.Denominator2010_13_data;
set Ning_pac.Denominator2010_13_data;
if 4-nmiss(DEATH_DT_10,DEATH_DT_11,DEATH_DT_12,DEATH_DT_13) gt 1 then death_flag=1; else death_flag=0;
run;
proc freq data=Ning_pac.Denominator2010_13_data;
tables death_flag; 																																	
run;
proc print data=Ning_pac.Denominator2010_13_data;
where death_flag eq 1;
var BENE_ID DEATH_DT_10 DEATH_DT_11 DEATH_DT_12 DEATH_DT_13;
run;

*Generate death date variable by combining death date information from each dataset;
data mp.Denominator2010_16_data;
set mp.Denominator2010_16_data;
DEATH_DT=DEATH_DT_10;
if DEATH_DT_10 eq . & DEATH_DT_11 ne . then DEATH_DT=DEATH_DT_11;
else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 ne . then DEATH_DT=DEATH_DT_12;
else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 ne . then DEATH_DT=DEATH_DT_13;
else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 ne . then DEATH_DT=DEATH_DT_14;
else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 ne . then DEATH_DT=DEATH_DT_15;
else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 eq . & DEATH_DT_16 ne . then DEATH_DT=DEATH_DT_16;
run;

*Merge MedPAR and Denominator data together;
proc sql;
create table temp.Merged2010_16 as
select medpar.*,denom.* 
from mp.MedPAR2010_16 as medpar
left join mp.Denominator2010_16_data as denom
on medpar.BENE_ID=denom.BENE_ID;
quit; *total 90,522,984 records (updated) in combined dataset;

*Exclude those less than 65 years old at admission date;
data temp.Merged2010_16;
set temp.Merged2010_16;
age_adm=floor((intck('month',BENE_DOB,ADMSNDT)-(day(ADMSNDT)<day(BENE_DOB)))/12);
run;   *90,522,984;
data temp.Merged2010_16;
set temp.Merged2010_16;
where age_adm ge 66;
run; *include total 70,556,574 records (updated) for those who were at least 66 years when admitted;

*Only include those have part A and part B, not HMO from admission to post discharge;
data temp.Merged2010_16_1;
set temp.Merged2010_16;
array buyin{84} BUYIN1-BUYIN84;
array hmoin{84} HMOIND1-HMOIND84;
array enroll_indicator{84} enroll_1-enroll_84;
array elig_period{84} elig_period_1-elig_period_84;
array elig_indicator{84} elig_indicator_1-elig_indicator_84;
array MA_indicator(84) MA_indicator_1-MA_indicator_84;
array MA_elig_indicator(84) MA_elig_indicator_1-MA_elig_indicator_84;
array FFS_indicator(84) FFS_indicator_1-FFS_indicator_84;
array FFS_elig_indicator(84) FFS_elig_indicator_1-FFS_elig_indicator_84;
if DEATH_DT ne . & DEATH_DT ge DSCHRGDT then post_dischdt=min(DSCHRGDT+60,DEATH_DT); else post_dischdt=DSCHRGDT+60;
do i=1 to 84;
	*Eligible for Part A coverage;
	if buyin(i) in ('3','C') then enroll_indicator(i)=1; else enroll_indicator(i)=0;
	if (year(ADMSNDT)-2010)*12+month(ADMSNDT) le i le (year(post_dischdt)-2010)*12+month(post_dischdt) then elig_period(i)=1; 
    else elig_period(i)=0; 
    elig_indicator(i)=enroll_indicator(i)*elig_period(i);
	*Eligible for Part A - enrolled in MA;
	if buyin(i) in ('3','C') & hmoin(i) not in (' ','0','4') then MA_indicator(i)=1; else MA_indicator(i)=0;
	MA_elig_indicator(i)=MA_indicator(i)*elig_period(i);
	*Eligible for Part A - enrolled in FFS;
	if buyin(i) in ('3','C') & hmoin(i) in (' ','0','4') then FFS_indicator(i)=1; else FFS_indicator(i)=0;
	FFS_elig_indicator(i)=FFS_indicator(i)*elig_period(i);
end; 
drop i;
elig_sum=sum(of elig_indicator_1-elig_indicator_84);
MA_elig_sum=sum(of MA_elig_indicator_1-MA_elig_indicator_84);
FFS_elig_sum=sum(of FFS_elig_indicator_1-FFS_elig_indicator_84);

*Continuously eligible for Part A;
if elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then enrollment_elig=1; else enrollment_elig=0;

*Continuously eligible for Part A - continuously enrolled in MA;
if MA_elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then MA_enrollment_elig=1; else MA_enrollment_elig=0;

*Continuously eligible for Part A - continuously enrolled in FFS;
if FFS_elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then FFS_enrollment_elig=1; else FFS_enrollment_elig=0;
label MA_enrollment_elig="Continuous Enrollment in Medicare Advantage" 
      FFS_enrollment_elig="Continuous Enrollment in Fee-for-Service";
run; *70,556,574;

data temp.Merged2010_16_2;
set temp.Merged2010_16_1;
where enrollment_elig=1;
run; 
*69,270,785 records included;

data check_MA;
set temp.Merged2010_16_2;
where MA_enrollment_elig=1;
run; *17,620,617;

*Get unique record for each BENE_ID on same discharge date (added 20151217);
proc sort data=temp.Merged2010_16_2; by BENE_ID DSCHRGDT; run;
data temp.Merged2010_16_2;
set temp.Merged2010_16_2;
by BENE_ID DSCHRGDT;
if first.DSCHRGDT then output;
run; 
*69,258,622 records included (updated);

*Create indicator varaibles for 6 conditions;
data mp.Merged2010_16;
set temp.Merged2010_16_2;
if DRG_CD in (469,470) then tkr_thr_drg=1; else tkr_thr_drg=0;
if DRG_CD in (871,872) then sepsis_drg=1; else sepsis_drg=0;
if DRG_CD in (689,690) then uti_drg=1; else uti_drg=0;
if DRG_CD in (291,292,293) then chf_drg=1; else chf_drg=0;
if DRG_CD in (193,194,195) then pneu_drg=1; else pneu_drg=0;
if DRG_CD in (480,481,482,535,536) then hipfx_drg=1; else hipfx_drg=0;
* Mortality;
* if DSCHRGDT eq . | DEATH_DT eq . then DeadIn30Days=.;
if DSCHRGDT le DEATH_DT le DSCHRGDT+30 then DeadIn30Days=1; else DeadIn30Days=0;
* Create discharge year variable;
dschrg_year=year(dschrgdt);
* Continuously eligible for Part A - MA&FFS combination;
if MA_enrollment_elig=0 & FFS_enrollment_elig=0 then Combo_FFS_MA=1; else Combo_FFS_MA=0; 
keep BENE_ID ADMSNDT DSCHRGDT RACE SEX BENE_DOB DEATH_DT age_adm DRG_CD DSTNTNCD MEDPAR_ID tkr_thr_drg sepsis_drg uti_drg chf_drg pneu_drg hipfx_drg DeadIn30Days 
     PMT_AMT PRVDR_NUM SPCLUNIT SSLSSNF	BENE_ZIP UTIL_DAY LOSCNT DGNS_CD01 DGNS_CD02 DGNS_CD03 DGNS_CD04 DGNS_CD05 DGNS_CD06 DGNS_CD07 DGNS_CD08 DGNS_CD09 DGNS_CD10 
     DGNS_CD11 DGNS_CD12 DGNS_CD13 DGNS_CD14 DGNS_CD15 DGNS_CD16 DGNS_CD17 DGNS_CD18 DGNS_CD19 DGNS_CD20 DGNS_CD21 DGNS_CD22 DGNS_CD23 DGNS_CD24 DGNS_CD25 PT_ID 
     PRCDR_CD1-PRCDR_CD25 SRC_ADMS TYPE_ADM DGNS_E_1_CD DGNS_E_2_CD DGNS_E_3_CD DGNS_E_4_CD DGNS_E_5_CD DGNS_E_6_CD DGNS_E_7_CD DGNS_E_8_CD DGNS_E_9_CD DGNS_E_10_CD 
     DGNS_E_11_CD DGNS_E_12_CD MA_enrollment_elig FFS_enrollment_elig Combo_FFS_MA dschrg_year;
format DeadIn30Days ynf.;																							
label dschrg_year="Discharge Year" Combo_FFS_MA="Combination of Fee-for-Service and Medicare Advantage";
run; 
*69,258,622 unique records for acute care hospitals;

proc freq data=mp.Merged2010_16;
title 'DeadIn30Days,including death within 60 days after discharge';
table DeadIn30Days;
run;      

*Fill in race information for enrollment report table, added 20160419;
proc freq data=mp.Merged2010_16;
table RACE*SEX;
run;

proc sql;
select SEX, RACE,count(*)
from mp.Merged2010_16
group by SEX, RACE
order by SEX, RACE;
quit;

title1 "Medicare Advantage Enrollment by Year";
proc freq data=mp.Merged2010_16;
table dschrg_year*MA_enrollment_elig;
run;
title1;

title2 "FFS Enrollment by Year";
proc freq data=mp.Merged2010_16;
table dschrg_year*FFS_enrollment_elig;
run;
title2;

title3 "Medicare Advantage Enrollment by Year";
proc freq data=mp.Merged2010_16;
table dschrg_year*Combo_FFS_MA;
run;
title3;





/*********************************************************************************
 Step 2: Combine 2010-2016 MDS assessments and create SNF ADL variables;
*********************************************************************************/
***** Link MDS data with MedPAR data, check matched numbers;
proc contents data=MDS2.mds_raw_3_0_2010 out=mds_2010 noprint; run; * 4,815,782 records;
proc contents data=MDS2.mds2010 out=mds2010 noprint; run; * 4,815,782 records;
proc contents data=MDS2.mds28557_2011 out= mds28857_2011 noprint;run; * 19,708,721 records;
proc contents data=MDS2.mds28557_2012 out= mds28857_2012 noprint;run; * 20,103,216 records;
proc contents data=MDS2.mds28557_2013 out= mds28857_2013 noprint;run; * 20,195,059 records;
proc contents data=MDS2.mds28557_jan_jun_2014 out= mds28557_jan_jun_2014 noprint;run; * 10,181,364 records;
proc contents data=MDS2.mds28557_jul_dec_2014 out= mds28557_jul_dec_2014 noprint;run; * 10,124,910 records;
proc contents data=MDS2.mds51953_2015 out= mds51953_2015 noprint;run; *20,552,041;
proc contents data=MDS2.mds51953_2016 out= mds51953_2016 noprint;run; *20,388,529;

***** Link 2016 MDS Data Set with Xwalk to get bene_id;
* Check the number of missing value for RSDNT_INTRNL_ID;
proc sql;
	create table MDS_2016_Missing_id as 
	select * from MDS2.mds51953_2016 where missing(RSDNT_INTRNL_ID);
	quit; * 0 record;

* Check the number of missing value for STATE_CD;
proc sql;
	create table MDS_2016_Missing_State as 
	select * from MDS2.mds51953_2016 where missing(state_cd);
	quit; * 0 record;

* Match MDS 2016 data with 2016 xwalk file;
proc sql;
create table pac_mds.mds3_beneid_2016 as
select mds.*,xwalk.bene_id
from MDS2.mds51953_2016 as mds
left join MDS2.Mds_res_bene_xwalk_2016 as xwalk
on mds.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and mds.state_cd=xwalk.state_cd;
quit; * 20,521,899 records, duplicates created due to multilple bene id matched with resident id and state (20,388,529 --> 20,521,899);

* Check the duplicate records in table XWalk_2016;
proc sort data=MDS2.Mds_res_bene_xwalk_2016 out=xwalk_2016;
	by rsdnt_intrnl_id state_cd;
run;

data xwalk_2016_1;
	set xwalk_2016;
	by rsdnt_intrnl_id state_cd;
	if first.state_cd then dup=0;
	else dup=1;
	run;

data xwalk_2016_2;
	set xwalk_2016_1;
	where dup=1;
	run; *21,990;

* Store the duplicate records in a new data set within Mingy_PAC;
proc sql;
	create table Ming_PAC.Xwalk_2016_dupkey as 
	select RSDNT_INTRNL_ID, state_cd, bene_id from xwalk_2016
	where RSDNT_INTRNL_ID in (select RSDNT_INTRNL_ID from xwalk_2016_2);
	quit;

* Check the number of missing value for BENE_ID;
proc sql;
	create table xwalk_2016_Missing_bene_id as 
	select * from MDS2.Mds_res_bene_xwalk_2016 where missing(bene_id);
	quit; * 0 record;	

* Check the number of missing value for BENE_ID;
proc sql;
	create table MDS_2016_Missing_bene_id as 
	select * from pac_mds.mds3_beneid_2016 where missing(bene_id);
	quit; * 645,272 record - 3.16% missing in pac_mds.mds3_beneid_2016 data set;

* Link 2015 MDS Data Set with Xwalk to get bene_id;
* Check the number of missing value for RSDNT_INTRNL_ID;
proc sql;
	create table MDS_2015_Missing_id as 
	select * from MDS2.mds51953_2015 where missing(RSDNT_INTRNL_ID);
	quit; * 0 record;

* Check the number of missing value for STATE_CD;
proc sql;
	create table MDS_2015_Missing_State as 
	select * from MDS2.mds51953_2015 where missing(state_cd);
	quit; * 0 record;

* Match MDS 2015 data with 2016 xwalk file (could also be used for 2015 MDS);
proc sql;
create table pac_mds.mds3_beneid_2015 as
select mds.*,xwalk.bene_id
from MDS2.mds51953_2015 as mds
left join MDS2.Mds_res_bene_xwalk_2016 as xwalk
on mds.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and mds.state_cd=xwalk.state_cd;
quit; * 20,680,306 records, duplicates created due to multilple bene id matched with resident id and state (20,552,041--> 20,680,306);

* Check the number of missing value for BENE_ID;
proc sql;
	create table MDS_2015_Missing_bene_id as 
	select * from pac_mds.mds3_beneid_2015 where missing(bene_id);
	quit; * 530,006 record - 2.56% missing in pac_mds.mds3_beneid_2015 data set;

***** Link 2014 MDS Data Set with Xwalk to get bene_id;
* Create MDS 2014 data set by vertically combining Jan-Jun data set with Jul-Dec data set - 20,306,274;
proc sql;
create table Ming_PAC.mds28557_2014 as 
select * from MDS2.mds28557_jan_jun_2014
outer union corr 
select * from MDS2.mds28557_jul_dec_2014;
quit;

* Check the number of missing value for RSDNT_INTRNL_ID;
proc sql;
	create table MDS_2014_Missing_id as 
	select * from Ming_PAC.mds28557_2014 where missing(RSDNT_INTRNL_ID);
	quit; * 0 record;

* Check the number of missing value for STATE_CD;
proc sql;
	create table MDS_2014_Missing_State as 
	select * from Ming_PAC.mds28557_2014 where missing(state_cd);
	quit; * 0 record;

* Match MDS 2014 data with 2014 xwalk file;
proc sql;
create table pac_mds.mds3_beneid_2014 as
select mds.*,xwalk.bene_id
from Ming_PAC.mds28557_2014 as mds
left join MDS2.Mds3_res_bene_xwalk_28557_2014 as xwalk
on mds.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and mds.state_cd=xwalk.state_cd;
quit; * 20,330,303 records, duplicates created due to multilple bene id matched with resident id and state (20,306,274 --> 20,330,303);

* Check the duplicate records in table XWalk_2014;
proc sort data=MDS2.Mds3_res_bene_xwalk_28557_2014 out=xwalk_2014;
	by rsdnt_intrnl_id state_cd;
run;

data xwalk_2014_1;
	set xwalk_2014;
	by rsdnt_intrnl_id state_cd;
	if first.state_cd then dup=0;
	else dup=1;
	run;

data xwalk_2014_2;
	set xwalk_2014_1;
	where dup=1;
	run;

* Store the duplicate records in a new data set within Mingy_PAC;
proc sql;
	create table Ming_PAC.Xwalk_2014_dupkey as 
	select RSDNT_INTRNL_ID, state_cd, bene_id from xwalk_2014
	where RSDNT_INTRNL_ID in (select RSDNT_INTRNL_ID from xwalk_2014_2);
	quit;

* Check the number of missing value for BENE_ID;
proc sql;
	create table xwalk_2014_Missing_bene_id as 
	select * from MDS2.Mds3_res_bene_xwalk_28557_2014 where missing(bene_id);
	quit; * 0 record;	

* Check the number of missing value for BENE_ID;
proc sql;
	create table MDS_2014_Missing_bene_id as 
	select * from pac_mds.mds3_beneid_2014 where missing(bene_id);
	quit; * 575,052 record - 2.83% missing in pac_mds.mds3_beneid_2014 data set;

***** Link 2011 - 2013 MDS Data Set with Xwalk to get bene_id;
* Create the MDS data set for 2011-2013;
data pac_MDS.MDS3_raw_28557_2011_13;
set MDS2.mds28557_2011 MDS2.mds28557_2012 MDS2.mds28557_2013;
run; * 60,006,996 records; 

* Check the number of missing value for RSDNT_INTRNL_ID;
proc sql;
	create table MDS_2011_13_Missing_id as 
	select * from pac_MDS.MDS3_raw_28557_2011_13 where missing(RSDNT_INTRNL_ID);
	quit; * 0 record;

* Check the number of missing value for STATE_CD;
proc sql;
	create table MDS_2011_13_Missing_State as 
	select * from pac_MDS.MDS3_raw_28557_2011_13 where missing(state_cd);
	quit; * 0 record;

* Match MDS 2011-2013 data with xwalk file;
proc sql;
create table pac_mds.mds3_beneid_2011_13 as
select mds.*,xwalk.bene_id
from pac_mds.MDS3_raw_28557_2011_13 as mds
left join Mds2.mds3_res_bene_xwalk as xwalk
on mds.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and mds.state_cd=xwalk.state_cd;
quit; 
* 60,166,529 records, duplicates created due to multilple bene id matched with resident id and state;

* Check the number of missing value for BENE_ID;
proc sql;
	create table xwalk_2011_13_Missing_bene_id as 
	select * from Mds2.mds3_res_bene_xwalk where missing(bene_id);
	quit; * 0 record;	

* Check the number of missing value for BENE_ID;
proc sql;
	create table MDS_2011_13_Missing_bene_id as 
	select * from pac_mds.mds3_beneid_2011_13 where missing(bene_id);
	quit; * 1,498,261 record - 2.49% missing in pac_mds.mds3_beneid_2011_13 data set;

* Link 2010 MDS Data Set with Xwalk to get bene_id;
* Match MDS 2010 data with its xwalk file;
data Pac_MDS.MDS_raw_3_0_2010;
set MDS2.MDS_raw_3_0_2010;
resident_internal=put(rsdnt_intrnl_id, z10.);
length resident_internal $10 state_cd $2;
resident_id=cat(of state_cd,resident_internal);
run;

* Check the number of missing value for RSDNT_INTRNL_ID;
proc sql;
	create table MDS_2010_Missing_id as 
	select * from Pac_MDS.MDS_raw_3_0_2010 where missing(RSDNT_INTRNL_ID);
	quit; * 0 record;

* Check the number of missing value for STATE_CD;
proc sql;
	create table MDS_2010_Missing_State as 
	select * from Pac_MDS.MDS_raw_3_0_2010 where missing(state_cd);
	quit; * 0 record;

proc sql;
create table Pac_MDS.MDS_raw_3_0_2010_1 as 
select a.*, b.bene_id
from Pac_MDS.MDS_raw_3_0_2010 as a
left join Pac_MDS.resid_bene_xwalk_1 as b
on a.resident_id=b.resident_id;
quit; * 4,819,227;

* Check the number of missing value for BENE_ID;
proc sql;
	create table xwalk_2010_Missing_bene_id as 
	select * from PAC_MDS.Mds3_res_bene_xwalk where missing(bene_id);
	quit; * 0 record;

* Check the number of missing value for BENE_ID;
proc sql;
	create table MDS_2010_Missing_bene_id as 
	select * from Pac_MDS.MDS_raw_3_0_2010_1 where missing(bene_id);
	quit;  *193,860 record - 4.02% missing in Pac_MDS.MDS_raw_3_0_2010_1 data set;


***** Create 2010 - 2016 MDS Data Set with Bene_ID;
* Add 2010, 2011-2013, 2014, 2015 and 2016 MDS data sets together;
data pac_mds.mds3_beneid_2010_16;
set pac_mds.mds3_beneid_2010_14 pac_mds.mds3_beneid_2015 pac_mds.mds3_beneid_2016;
if bene_id eq ' ' then bene_flag=1; else bene_flag=0;
if A1600_ENTRY_DT eq '^' then MDS_ENTRY_DT=.; else MDS_ENTRY_DT=input(A1600_ENTRY_DT,yymmdd8.);
if A2000_DSCHRG_DT eq '^' then MDS_DSCHRG_DT=.; else MDS_DSCHRG_DT=input(A2000_DSCHRG_DT,yymmdd8.);
if A2300_ASMT_RFRNC_DT eq '^' then MDS_ASMT_DT=.; else MDS_ASMT_DT=input(A2300_ASMT_RFRNC_DT,yymmdd8.);
if TRGT_DT eq '^' then MDS_TRGT_DT=.; else MDS_TRGT_DT=input(TRGT_DT,yymmdd8.);
format MDS_ENTRY_DT MDS_DSCHRG_DT MDS_ASMT_DT MDS_TRGT_DT date9.;
run; * 2010-2014: 85,316,059 records / 2010-2016:126,518,264 records;

* Check the number of missing value for BENE_ID;
proc sql;
	create table MDS_2010_16_Missing_bene_id as 
	select RSDNT_INTRNL_ID from pac_mds.mds3_beneid_2010_16 where missing(bene_id);
	quit; * 3,442,451 record - 2.72% missing in pac_mds.mds3_beneid_2010_16 data set;

proc freq data=pac_mds.mds3_beneid_2010_16; table bene_flag; run;

proc sql; 
create table pac_mds.mds_missing_beneid_2010_16 as 
select distinct RSDNT_INTRNL_ID, state_cd, bene_id 
from pac_mds.mds3_beneid_2010_16 
where bene_flag eq 1; 
quit; * 788,778 records;

***** Create MDS2.0 and MDS3.0 Combined Data set (2010-2016);
* 1.Create MDS3.0 2010-2016 admission-level data set;
data mds3_2010_16_admsn_dschrg(keep=bene_id fac_prvdr_intrnl_id A0100B_CMS_CRTFCTN_NUM MDS_ENTRY_DT MDS_DSCHRG_DT A0310F_ENTRY_DSCHRG_CD);
retain bene_id A0100B_CMS_CRTFCTN_NUM MDS_ENTRY_DT MDS_DSCHRG_DT A0310F_ENTRY_DSCHRG_CD;
set pac_mds.mds3_beneid_2010_16(keep=bene_id fac_prvdr_intrnl_id A0100B_CMS_CRTFCTN_NUM MDS_ENTRY_DT MDS_DSCHRG_DT A0310F_ENTRY_DSCHRG_CD A0310B_PPS_CD);
where A0310F_ENTRY_DSCHRG_CD in ('01','10','11','12') and bene_id^="";
run; *52,133,835 records;

proc sort data=mds3_2010_16_admsn_dschrg; by bene_id MDS_ENTRY_DT MDS_DSCHRG_DT;
run;

data pac_mds.mds3_2010_16_admsn_dschrg;
set mds3_2010_16_admsn_dschrg;
by bene_id MDS_ENTRY_DT MDS_DSCHRG_DT;
if first.MDS_ENTRY_DT;
rename A0100B_CMS_CRTFCTN_NUM=PRVDR_NUM;
run; *28,087,317 records;

proc sql;
create table check_admsn_missing as 
select bene_id from pac_mds.mds3_2010_16_admsn_dschrg where MDS_ENTRY_DT=.;
quit; *0 missing;

proc sql;
create table check_dschrg_missing as 
select bene_id from pac_mds.mds3_2010_16_admsn_dschrg where MDS_DSCHRG_DT=.;
quit; *2,142,952(7.63%) missing;


* 2.Create MDS2.0 2010 admission-level data set;
data mds2_2010_admsn_dschrg(keep=bene_id MDS_ENTRY_DT MDS_DSCHRG_DT PRVDR_NUM);
retain bene_id AA6B_FAC_MCARE_NBR MDS_ENTRY_DT MDS_DSCHRG_DT;
set	pac_mds.mds2_2010_beneid;
MDS_ENTRY_DT=input(AB1_ENTRY_DT,yymmdd8.);
MDS_DSCHRG_DT=input(R4_DISCHARGE_DT,yymmdd8.);
 *Use target date as admission date if admission date is missing and asessment reason is entry or reentry;
if AB1_ENTRY_DT=. and AA8A_PRI_RFA in ("01","05","09") then MDS_ENTRY_DT=input(TARGET_DATE,yymmdd8.);
format MDS_ENTRY_DT MDS_DSCHRG_DT date9.;
rename AA6B_FAC_MCARE_NBR=PRVDR_NUM;
run; *12,823,862;

data mds2_2010_admsn;
set mds2_2010_admsn_dschrg;
where MDS_ENTRY_DT^=. and bene_id^="";
run; *6,616,787;

proc sort data=mds2_2010_admsn nodupkey; by bene_id MDS_ENTRY_DT; run; *5,488,896;

*Find discharge date from 2010 MDS2.0;
data mds2_2010_dschrg(keep=bene_id MDS_DSCHRG_DT PRVDR_NUM);
set mds2_2010_admsn_dschrg;
where MDS_DSCHRG_DT^=. and bene_id^="";
run; *3,042,513;

*Find discharge date from 2010 MDS3.0;
data mds3_2010_dschrg(keep=bene_id PRVDR_NUM MDS_DSCHRG_DT);
retain bene_id A0100B_CMS_CRTFCTN_NUM MDS_DSCHRG_DT;
set pac_mds.mds3_beneid_2010_16(keep=bene_id A0100B_CMS_CRTFCTN_NUM MDS_ENTRY_DT MDS_DSCHRG_DT);
where MDS_DSCHRG_DT^=. and bene_id^="" and year(MDS_ENTRY_DT)<=2010;
rename A0100B_CMS_CRTFCTN_NUM=PRVDR_NUM;
run; *2,309,986;

data mds_2010_dschrg_all; set mds2_2010_dschrg mds3_2010_dschrg; run; *5,352,499;

proc sql;
create table mds2_2010_admsn_dschrg_2 as 
select a.*, b.MDS_DSCHRG_DT as MDS_DSCHRG_DT_2
from mds2_2010_admsn as a left join mds_2010_dschrg_all as b
on a.bene_id=b.bene_id & a.MDS_ENTRY_DT<=b.MDS_DSCHRG_DT;
quit; *8,978,100;

proc sort data=mds2_2010_admsn_dschrg_2; by bene_id PRVDR_NUM MDS_ENTRY_DT descending MDS_DSCHRG_DT_2;run;

data tempn.mds2_2010_admsn_dschrg(drop=MDS_DSCHRG_DT_2);
set mds2_2010_admsn_dschrg_2;
by bene_id PRVDR_NUM MDS_ENTRY_DT descending MDS_DSCHRG_DT_2;
if first.MDS_ENTRY_DT;
MDS_DSCHRG_DT=MDS_DSCHRG_DT_2;
run; *5,488,896;

proc sql;
create table check_admsn_missing as 
select bene_id from tempn.mds2_2010_admsn_dschrg where MDS_ENTRY_DT=.;
quit; 

proc sql;
create table check_dschrg_missing as 
select bene_id from tempn.mds2_2010_admsn_dschrg where MDS_DSCHRG_DT=.;
quit; *256,424 (4.67%) missing;

* 3.Combine MDS2.0 and MDS3.0;
data tempn.mds_2010_16_admsn_dschrg;
set tempn.mds2_2010_admsn_dschrg pac_mds.mds3_2010_16_admsn_dschrg;
run; *33,576,213;

***** Link Merged MDS data to MedPar Data;
proc sql; * Total number of MedPar Discharge to SNF;
create table pac_snf_all as
select * from Pac.Merge_all_1016
where disch_pac_n eq 1 and hospice^=1
order by bene_id;
quit; * MedPar Discharge to SNF: 16,574,694 records;

proc sql; * Need to exclude those discharged before 01/OCT/2010 since MDS3.0 data only available after that date;
create table tempn.pac_snf as                         
select * from Pac.Merge_all_1016
where disch_pac_n eq 1 and DSCHRGDT gt 18536 and hospice^=1
order by bene_id;
quit;  *14,909,379 records;

data tempn.pac_snf;
set tempn.pac_snf;
pac_snf_unique=_N_; *Create an unique identifier to represent each record in the MedPAR SNF data set;
run;

/* Successful Discharge Raw Data: All records except for patients who were discharged to SNF within the last 100 days of 2016 */
proc sql;
create table tempn.pac_snf_nolast100 as
select * from Pac.Merge_all_1016
where (DSCHRGDT + 100) le 20819 and disch_pac_n eq 1 and hospice^=1
order by bene_id;
quit;  *16,305,279 records;

data tempn.pac_snf_nolast100;
set tempn.pac_snf_nolast100;
pac_snf_unique=_N_; *Create an unique identifier to represent each record in the MedPAR SNF data set;
run;

*Find a match in MDS on BENE_ID & SNF admission date within MDS entry date +/- 1 day;
proc sql;
create table tempn.snf_medpar_combined_m as
select medpar.*, snf.*
from tempn.pac_snf as medpar 
left join pac_mds.mds3_beneid_2010_16(rename=(bene_id=snf_bene_id)) as snf
on snf.snf_bene_id=medpar.bene_id and -1 le medpar.ADMSNDT_SNF-snf.MDS_ENTRY_DT le 1 and (snf.A0310F_ENTRY_DSCHRG_CD ='10' | snf.A0310B_PPS_CD in ('01','06') | A0310A_FED_OBRA_CD="01")
order by pac_snf_unique;
quit; *22,795,463 records;

*Check the number that could find a match;
proc sql; create table tempn.snf_matched_n as select distinct pac_snf_unique from tempn.snf_medpar_combined_m 
where not missing(snf_bene_id); quit; *13,412,622 records;
*Check the numbers that couldn't find a match;
proc sql; create table tempn.snf_notmatched_n as select pac_snf_unique, bene_id, ADMSNDT_SNF from tempn.snf_medpar_combined_m
where missing(snf_bene_id); quit;
*1,496,757 records couldn't find a match with bene_id and +/- 1 day of admission;

data PAC.snf_medpar_combined_n;
set tempn.snf_medpar_combined_m;
where snf_bene_id ne ' ';
run; *21,298,706 records;

proc sql; create table snf_check1 as select distinct pac_snf_unique from PAC.snf_medpar_combined_n; quit; *Matched: 13,412,622 (89.96%) records;

***** SNF ADL variable creation;
data PAC.snf_medpar_combined_n;
set PAC.snf_medpar_combined_n;
if A0310F_ENTRY_DSCHRG_CD eq '10' then valid_disch=1; else valid_disch=0;
if A0310B_PPS_CD eq '01' or A0310A_FED_OBRA_CD eq '01' then valid_admsn=1; else valid_admsn=0;
run; 

proc freq data=PAC.snf_medpar_combined_n; tables (valid_disch valid_admsn); run;

proc sql; create table tempn.snf_list1_n as select distinct pac_snf_unique from PAC.snf_medpar_combined_n where valid_disch=1; quit;
* 8,430,128 records in MedPAR that have a valid discharge assessment;

proc sql; create table tempn.snf_medpar_ADL1_n as select * from PAC.snf_medpar_combined_n 
where pac_snf_unique in (select * from tempn.snf_list1_n); quit;
* 16,034,288 records that have a valid discharge assessment;

* Check why so many without valid discharge assessment;
proc sql; create table tempn.snf_novalid_disch_n as 
select pac_snf_unique, ADMSNDT_SNF, DSCHRGDT_SNF, bene_id,MDS_ENTRY_DT, MDS_DSCHRG_DT, MDS_ASMT_DT, MDS_TRGT_DT, A0310A_FED_OBRA_CD, 
       A0310B_PPS_CD,A0310F_ENTRY_DSCHRG_CD, B0100_CMTS_CD
from PAC.snf_medpar_combined_n 
where pac_snf_unique not in (select * from tempn.snf_list1_n); 
quit; *5,264,418 records;

proc freq data=tempn.snf_novalid_disch_n; table A0310F_ENTRY_DSCHRG_CD*A0310B_PPS_CD; run;

proc freq data=tempn.snf_novalid_disch_n; table A0310A_FED_OBRA_CD; run;

proc sql; 
create table snf_novalid_list2_nn as 
select distinct pac_snf_unique 
from tempn.snf_novalid_disch_n 
where A0310A_FED_OBRA_CD in ('01','02'); 
quit; 
*2,700,004 records have discharged to long term care: A0310A_FED_OBRA_CD=01/02;

* check discharge and admission date using mds data;
proc sql; create table tempn.snf_novalid_list1_n as select distinct pac_snf_unique 
from tempn.snf_novalid_disch_n where MDS_DSCHRG_DT ne .; quit; * 650,932 records have a discharge date from MDS;

proc sql; create table snf_discharged_mds as select * from tempn.snf_novalid_disch_n where pac_snf_unique in (select * from tempn.snf_novalid_list1_n); quit;

proc sort data=snf_discharged_mds; by pac_snf_unique ADMSNDT_SNF; run; /* 668,798 records */

data snf_discharged_mds_u; merge snf_discharged_mds; by pac_snf_unique ADMSNDT_SNF; if first.pac_snf_unique; run; *650,932 records;

data tempn.snf_discharged_mds_u;
set snf_discharged_mds_u;
if ADMSNDT_SNF lt 18628 then adm_year=2010; 
else if 18628 le ADMSNDT_SNF lt 18993 then adm_year=2011; 
else if 18993 le ADMSNDT_SNF lt 19359 then adm_year=2012; 
else if 19359 le ADMSNDT_SNF lt 19724 then adm_year=2013; 
else if 19724 le ADMSNDT_SNF lt 20089 then adm_year=2014; 
else if 20089 le ADMSNDT_SNF lt 20454 then adm_year=2015; 
else if ADMSNDT_SNF ge 20454 then adm_year=2016;

if MDS_DSCHRG_DT lt 18628 then dis_year=2010; 
else if 18628 le MDS_DSCHRG_DT lt 18993 then dis_year=2011; 
else if 18993 le MDS_DSCHRG_DT lt 19359 then dis_year=2012; 
else if 19359 le MDS_DSCHRG_DT lt 19724 then dis_year=2013; 
else if 19724 le MDS_DSCHRG_DT lt 20089 then dis_year=2014; 
else if 20089 le MDS_DSCHRG_DT lt 20454 then dis_year=2015; 
else if MDS_DSCHRG_DT ge 20454 then dis_year=2016;
run;

proc freq data=tempn.snf_discharged_mds_u; tables (adm_year dis_year); run;

*Check discharge and admission date using medpar data;
proc sql; create table tempn.snf_novalid_list1_nm as select distinct pac_snf_unique 
from tempn.snf_novalid_disch_n where DSCHRGDT_SNF ne .; quit; *4,434,364 records have a discharge date from medpar;
proc sql; create table snf_discharged_med as select * from tempn.snf_novalid_disch_n where pac_snf_unique in (select * from tempn.snf_novalid_list1_nm); quit;
proc sort data=snf_discharged_med; by pac_snf_unique ADMSNDT_SNF; run; *4,675,928 records;

data snf_discharged_med_u; merge snf_discharged_med; by pac_snf_unique ADMSNDT_SNF; if first.pac_snf_unique; run; * 4,434,364 records;

data snf_discharged_med_u;
set snf_discharged_med_u;
if ADMSNDT_SNF lt 18628 then adm_year=2010; 
else if 18628 le ADMSNDT_SNF lt 18993 then adm_year=2011; 
else if 18993 le ADMSNDT_SNF lt 19359 then adm_year=2012; 
else if 19359 le ADMSNDT_SNF lt 19724 then adm_year=2013; 
else if 19724 le ADMSNDT_SNF lt 20089 then adm_year=2014; 
else if 20089 le ADMSNDT_SNF lt 20454 then adm_year=2015; 
else if ADMSNDT_SNF ge 20454 then adm_year=2016;

if DSCHRGDT_SNF lt 18628 then dis_year=2010; 
else if 18628 le DSCHRGDT_SNF lt 18993 then dis_year=2011; 
else if 18993 le DSCHRGDT_SNF lt 19359 then dis_year=2012; 
else if 19359 le DSCHRGDT_SNF lt 19724 then dis_year=2013;
else if 19724 le DSCHRGDT_SNF lt 20089 then dis_year=2014; 
else if 20089 le DSCHRGDT_SNF lt 20454 then dis_year=2015;  
else if DSCHRGDT_SNF ge 20454 then dis_year=2016;
run;

proc freq data=snf_discharged_med_u; tables (adm_year dis_year); run;

* Check admission date for those without discharge date in mds data;
proc sql; create table snf_notdischarged_mds as select * from tempn.snf_novalid_disch_n where pac_snf_unique not in (select * from tempn.snf_novalid_list1_n); quit; *2,522,564 records;
proc sort data=snf_notdischarged_mds; by pac_snf_unique ADMSNDT_SNF; run;
data snf_notdischarged_mds_u; merge snf_notdischarged_mds; by pac_snf_unique ADMSNDT_SNF; if first.pac_snf_unique; run;
data snf_notdischarged_mds_u;
set snf_notdischarged_mds_u;
if ADMSNDT_SNF lt 18628 then adm_year=2010; 
else if 18628 le ADMSNDT_SNF lt 18993 then adm_year=2011; 
else if 18993 le ADMSNDT_SNF lt 19359 then adm_year=2012; 
else if 19359 le ADMSNDT_SNF lt 19724 then adm_year=2013;
else if 19724 le ADMSNDT_SNF lt 20089 then adm_year=2014; 
else if 20089 le ADMSNDT_SNF lt 20454 then adm_year=2015; 
else if ADMSNDT_SNF ge 20454 then adm_year=2016;

if DSCHRGDT_SNF lt 18628 then dis_year=2010; 
else if 18628 le DSCHRGDT_SNF  lt 18993 then dis_year=2011; 
else if 18993 le DSCHRGDT_SNF  lt 19359 then dis_year=2012;  
else if 19359 le DSCHRGDT_SNF  lt 19724 then dis_year=2013; 
else if 19724 le DSCHRGDT_SNF  lt 20089 then dis_year=2014; 
else if 20089 le DSCHRGDT_SNF  lt 20454 then dis_year=2015; 
else if DSCHRGDT_SNF ge 20454 then dis_year=2016;
run; 
proc freq data=snf_notdischarged_mds_u; tables (adm_year dis_year); run;

* Check admission date for those without discharge date in mds data: all without discharge assessment in mds;
proc sort data=tempn.snf_novalid_disch_n; by pac_snf_unique ADMSNDT_SNF; run; *2,902,260 records;
data tempn.snf_novalid_disch_n_u; merge tempn.snf_novalid_disch_n; by pac_snf_unique ADMSNDT_SNF; if first.pac_snf_unique; run;
data tempn.snf_novalid_disch_n_u;
set tempn.snf_novalid_disch_n_u;
if ADMSNDT_SNF lt 18628 then adm_year=2010; 
else if 18628 le ADMSNDT_SNF lt 18993 then adm_year=2011;
else if 18993 le ADMSNDT_SNF lt 19359 then adm_year=2012; 
else if 19359 le ADMSNDT_SNF lt 19724 then adm_year=2013; 
else if 19724 le ADMSNDT_SNF lt 20089 then adm_year=2014; 
else if 20089 le ADMSNDT_SNF lt 20454 then adm_year=2015; 
else if ADMSNDT_SNF ge 20454 then adm_year=2016;
run; 
proc freq data=tempn.snf_novalid_disch_n_u; tables adm_year; run;

proc sql; create table snf_novalid_list2_n as select distinct pac_snf_unique from tempn.snf_novalid_disch_n 
where pac_snf_unique in (select * from tempn.snf_novalid_list1_n) and A0310A_FED_OBRA_CD in ('01','02'); quit; 
* 60,467 records have discharged to long term care: A0310A_FED_OBRA_CD=01/02;

proc sql; create table tempn.snf_list2_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL1_n where valid_admsn=1 & valid_disch ne 1; quit;
* Included: 7,006,432 unique records in MedPAR SNF that have a valid 5-day/admission assessment;

proc sql; create table tempn.snf_medpar_ADL2_n as select * from tempn.snf_medpar_ADL1_n where pac_snf_unique in (select * from tempn.snf_list2_n); quit;
* 14,428,246 records that have a valid 5-day/admission assessment;

/* Create indicator variables for:
   1) Missing ADL items at 5-day/admission assessment;	 A0310B_PPS_CD eq '01' or A0310A_FED_OBRA_CD
   2) Missing ADL items at discharge assessment;
   3) Missing MADL items at 5-day assessment;
   4) Missing MADL items at discharge assessment; */
data tempn.snf_medpar_ADL2_1_n;
set tempn.snf_medpar_ADL2_n;
if B0100_CMTS_CD eq '1' & (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') then flag_comatose=1;
if J1400_LIFE_PRGNS_CD eq '1' & (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') then flag_prognosis=1;
if O0100K2_HOSPC_POST_CD eq '1' & (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') then flag_hospice=1;
if (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') then do;
	if G0120A_BATHG_SELF_CD eq '-' | G0120B_BATHG_SPRT_CD eq '-' |
    G0110G1_DRESS_SELF_CD eq '-' | G0110G2_DRESS_SPRT_CD eq '-' |
    G0110I1_TOILTG_SELF_CD eq '-' | G0110I2_TOILTG_SPRT_CD eq '-' |
    G0110B1_TRNSFR_SELF_CD eq '-' | G0110B2_TRNSFR_SPRT_CD eq '-' |
    G0110H1_EATG_SELF_CD eq '-' | G0110H2_EATG_SPRT_CD eq '-'  | 
    H0300_URNRY_CNTNC_CD eq '-' | H0400_BWL_CNTNC_CD eq '-' then flag_miss_ADL_5day=1;
	if G0110B1_TRNSFR_SELF_CD eq '-' | G0110B2_TRNSFR_SPRT_CD eq '-' |
    G0110D1_WLK_CRDR_SELF_CD eq '-' | G0110D2_WLK_CRDR_SPRT_CD eq '-' |
	G0110E1_LOCOMTN_ON_SELF_CD eq '-' | G0110E2_LOCOMTN_ON_SPRT_CD eq '-' then flag_miss_MADL_5day=1;
end;
if A0310F_ENTRY_DSCHRG_CD eq '10' then do;
	if G0120A_BATHG_SELF_CD eq '-' | G0120B_BATHG_SPRT_CD eq '-' |
    G0110G1_DRESS_SELF_CD eq '-' | G0110G2_DRESS_SPRT_CD eq '-' |
    G0110I1_TOILTG_SELF_CD eq '-' | G0110I2_TOILTG_SPRT_CD eq '-' |
    G0110B1_TRNSFR_SELF_CD eq '-' | G0110B2_TRNSFR_SPRT_CD eq '-' |
    G0110H1_EATG_SELF_CD eq '-' | G0110H2_EATG_SPRT_CD eq '-'  | 
    H0300_URNRY_CNTNC_CD eq '-' | H0400_BWL_CNTNC_CD eq '-' then flag_miss_ADL_disch=1;
	if G0110B1_TRNSFR_SELF_CD eq '-' | G0110B2_TRNSFR_SPRT_CD eq '-' |
    G0110D1_WLK_CRDR_SELF_CD eq '-' | G0110D2_WLK_CRDR_SPRT_CD eq '-' |
	G0110E1_LOCOMTN_ON_SELF_CD eq '-' | G0110E2_LOCOMTN_ON_SPRT_CD eq '-' then flag_miss_MADL_disch=1;
end;
run; *14,428,246 records;

proc freq data=tempn.snf_medpar_ADL2_1_n;
tables (flag_comatose flag_prognosis flag_hospice flag_miss_ADL_5day flag_miss_MADL_5day flag_miss_ADL_disch flag_miss_MADL_disch);
run;


proc sql; create table tempn.snf_list3_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL2_1_n where flag_comatose=1; quit;
*829 records in MedPAR that comatose at 5-day assessment;
proc sql; create table tempn.snf_medpar_ADL3_n as select * from tempn.snf_medpar_ADL2_1_n where pac_snf_unique not in (select * from tempn.snf_list3_n); quit;
*14,426,466 records that didn't comatose at 5-day assessment;
proc sql; create table snf_medpar_ADL3_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL3_n; quit; *7,005,603 unique records that didn't comatose at 5-day assessment;

proc sql; create table tempn.snf_list4_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL3_n where flag_prognosis=1; quit;
* 31,087 records in MedPAR that have prognosis life <=6 month at 5-day assessment;
proc sql; create table tempn.snf_medpar_ADL4_n as select * from tempn.snf_medpar_ADL3_n where pac_snf_unique not in (select * from tempn.snf_list4_n); quit;
* 14,360,537 records that didn't have prognosis life <=6 month at 5-day assessment;
proc sql; create table snf_medpar_ADL4_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL4_n; quit; 
*6,974,516 unique records that didn't have prognosis life <=6 month at 5-day assessment;

proc sql; create table tempn.snf_list5_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL4_n where flag_hospice=1; quit;
* 4,131 records in MedPAR that hospice at 5-day assessment;
proc sql; create table tempn.snf_medpar_ADL5_n as select * from tempn.snf_medpar_ADL4_n where pac_snf_unique not in (select * from tempn.snf_list5_n); quit;
* 14,351,486 records that didn't hospice at 5-day assessment;
proc sql; create table snf_medpar_ADL5_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL5_n; quit; *6,970,385 records

* Get a subset of relative variables, can use pac_snf_unique to link it back;
proc sql;
create table Tempn.snf_medpar_ADL6_n as
select BENE_ID, medpar_id, ADMSNDT, DSCHRGDT, pac_snf_unique, ADMSNDT_SNF, DSCHRGDT_SNF_pseudo, flag_miss_ADL_5day, flag_miss_MADL_5day, flag_miss_ADL_disch, flag_miss_MADL_disch,
MDS_ENTRY_DT, MDS_DSCHRG_DT, MDS_ASMT_DT, MDS_TRGT_DT, A0310A_FED_OBRA_CD, A0310B_PPS_CD, A0310F_ENTRY_DSCHRG_CD, A0310G_PLND_DSCHRG_CD, B0100_CMTS_CD,
G0120A,G0120B,G0110I1,G0110I2,G0110H1,G0110H2,G0110D1,G0110D2, G0110E1,G0110E2,G0110G1,G0110G2,G0110B1,G0110B2,H0300,H0400,
A0900_BIRTH_DT,A0800_GNDR_CD,C0500_BIMS_SCRE_NUM,C0700_SHRT_TERM_MEMRY_CD,C1000_DCSN_MKNG_CD,B0700_SELF_UNDRSTOD_CD,I0600_HRT_FAILR_CD,I4500_STRK_CD,
I3900_HIP_FRCTR_CD,I4000_OTHR_FRCTR_CD,K0500A_PEN_CD
from Tempn.snf_medpar_ADL5_n(rename=(G0120A_BATHG_SELF_CD=G0120A G0120B_BATHG_SPRT_CD=G0120B G0110G1_DRESS_SELF_CD=G0110G1 G0110G2_DRESS_SPRT_CD=G0110G2
G0110B1_TRNSFR_SELF_CD=G0110B1 G0110B2_TRNSFR_SPRT_CD=G0110B2 G0110I1_TOILTG_SELF_CD=G0110I1 G0110I2_TOILTG_SPRT_CD=G0110I2
G0110H1_EATG_SELF_CD=G0110H1 G0110H2_EATG_SPRT_CD=G0110H2 G0110D1_WLK_CRDR_SELF_CD=G0110D1 G0110E1_LOCOMTN_ON_SELF_CD=G0110E1 G0110D2_WLK_CRDR_SPRT_CD=G0110D2 
G0110E2_LOCOMTN_ON_SPRT_CD=G0110E2 H0300_URNRY_CNTNC_CD=H0300 H0400_BWL_CNTNC_CD=H0400));
quit; *14,351,486 records;			  

data tempn.snf_medpar_ADL6_1_n;
set Tempn.snf_medpar_ADL6_n;
if A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01' | A0310F_ENTRY_DSCHRG_CD eq '10' then do;
* ADL variables;
array adl_self{5} G0120A G0110G1 G0110I1 G0110B1 G0110H1;
array adl_out{5} ADL_bath ADL_dress ADL_toilet ADL_trans ADL_eating;
do i=1 to 5;
	if adl_self(i) in ('0','7','8') then adl_out(i)=0;
	else if adl_self(i) in ('1','2','3','4') then adl_out(i)=1;
end;
if H0300 in ('0','9') then ADL_uri=0; else if H0300 in ('1','2','3')  then ADL_uri=1; 
if H0400 in ('0','9') then ADL_bwl=0; else if H0400 in ('1','2','3')  then ADL_bwl=1; 
if ADL_uri=0 and ADL_bwl=0 then ADL_conti=0; else ADL_conti=1;
ADL_total=sum(ADL_bath, ADL_dress, ADL_trans, ADL_toilet, ADL_eating, ADL_conti);
if ADL_total eq 0 & (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') then flag_ADL_impair=1;

* MADL variables;
array madl_self{3} G0110B1 G0110D1 G0110E1;
array madl_sprt{3} G0110B2 G0110D2 G0110E2;
array madl_out{3} MADL_trans MADL_walk MADL_Loco;
do i=1 to 3;
	if madl_self(i) in ('0','1','7','8','-') then madl_out(i)=0;
	else if madl_self(i) eq '2' then madl_out(i)=1;
	else if madl_self(i) in ('3','4') & madl_sprt(i) in ('0','1','2','-') then madl_out(i)=1;
	else if madl_self(i) in ('3','4') & madl_sprt(i) eq '3' then madl_out(i)=2;
end;
MADL_total=sum(MADL_trans, MADL_walk, MADL_Loco);
if MADL_total eq 0 & (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') then flag_MADL_impair=1;
end;
run; *14,351,486 records;


proc sql; create table tempn.snf_list5_n_2 as select distinct pac_snf_unique from tempn.snf_medpar_ADL6_1_n where flag_miss_adl_5day=1; quit; 
* 25,512 records in MedPAR that have missing ADL items at 5-day assessment;
proc sql; create table tempn.snf_medpar_ADL6_1_n_2 as select * from tempn.snf_medpar_ADL6_1_n where pac_snf_unique not in (select * from tempn.snf_list5_n_2); quit;
* 14,297,112 records that don't have missing ADL items at 5-day assessment;
proc sql; create table snf_medpar_ADL5_n_2 as select distinct pac_snf_unique from tempn.snf_medpar_ADL6_1_n_2; quit; *Included: 6,944,873 records;

proc sql; create table tempn.snf_list6_0_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL6_1_n_2 where flag_ADL_impair=1; quit; 
*18,967 records in MedPAR that without ADL impairment at 5-day assessment;
proc sql; create table tempn.snf_medpar_ADL6_0_n as select * from tempn.snf_medpar_ADL6_1_n_2 where pac_snf_unique 
not in (select * from tempn.snf_list6_0_n); quit;
*14,256,291 records that with ADL impairment at 5-day assessment;
proc sql; create table tempn.snf_list6_0_n_include as select distinct pac_snf_unique from tempn.snf_medpar_ADL6_0_n; quit; *6,925,906;

proc sql; create table tempn.snf_list6_1_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL6_0_n where flag_miss_ADL_disch=1; quit;
*61,489 records in MedPAR that have missing ADL items at discharge;
proc sql; create table tempn.snf_medpar_ADL7_1_n as select * from tempn.snf_medpar_ADL6_0_n where pac_snf_unique 
not in (select * from tempn.snf_list6_1_n); quit;
*14,128,772 records;
proc sql; create table tempn.snf_list6_1_n_include as select distinct pac_snf_unique from tempn.snf_medpar_ADL7_1_n; quit; 
*6,864,417 records that didn't have missing ADL items at discharge;

proc sql; create table tempn.snf_list7_1_n as select distinct pac_snf_unique from tempn.snf_medpar_ADL7_1_n where A0310G_PLND_DSCHRG_CD='2'; quit;
*417,992 records in MedPAR that have unplanned discharge;
proc sql;create table tempn.snf_medpar_ADL8_1_n as select * from tempn.snf_medpar_ADL7_1_n where pac_snf_unique 
not in (select * from tempn.snf_list7_1_n); quit;
*13,265,386 records;
proc sql; create table tempn.snf_list7_1_n_include as select distinct pac_snf_unique from tempn.snf_medpar_ADL8_1_n; quit; 
*6,446,425 records in MedPAR that didn't have unplanned discharge;

proc sql; create table tempn.snf_ADL_disch_n as 
select BENE_ID, medpar_id, ADMSNDT, DSCHRGDT,pac_snf_unique, MDS_DSCHRG_DT, ADL_bath as ADL_bath_2, ADL_dress as ADL_dress_2, ADL_trans as ADL_trans_2, ADL_toilet as ADL_toilet_2, ADL_eating as ADL_eating_2, ADL_conti as ADL_conti_2, ADL_total as ADL_total_2
from tempn.snf_medpar_ADL8_1_n 
where A0310F_ENTRY_DSCHRG_CD eq '10' 
order by pac_snf_unique and MDS_DSCHRG_DT; 
quit; *6,454,997 records;

proc sort data=tempn.snf_ADL_disch_n; by pac_snf_unique MDS_DSCHRG_DT; run;

data tempn.snf_ADL_disch_unique_n;
merge tempn.snf_ADL_disch_n;
by pac_snf_unique MDS_DSCHRG_DT;
if first.pac_snf_unique;
run; *6,446,425 records;

proc sql; create table tempn.snf_ADL_5day_n as 
select BENE_ID, medpar_id, ADMSNDT, DSCHRGDT,pac_snf_unique, MDS_ENTRY_DT, ADL_bath as ADL_bath_1, ADL_dress as ADL_dress_1, ADL_trans as ADL_trans_1, ADL_toilet as ADL_toilet_1, ADL_eating as ADL_eating_1, ADL_conti as ADL_conti_1, ADL_total as ADL_total_1
from tempn.snf_medpar_ADL8_1_n 
where (A0310B_PPS_CD eq '01' | A0310A_FED_OBRA_CD eq '01') 
order by pac_snf_unique and MDS_ENTRY_DT; 
quit; * 6,811,782 records;

proc sort data=tempn.snf_ADL_5day_n; by pac_snf_unique MDS_ENTRY_DT; run;

data tempn.snf_ADL_5day_unique_n;
merge tempn.snf_ADL_5day_n;
by pac_snf_unique MDS_ENTRY_DT;
if first.pac_snf_unique;
run; *6,446,425 records;

proc sql; 
create table tempn.snf_ADL_disch_5day_n as 
select disch.*, fiveday.* 
from tempn.snf_ADL_disch_unique_n as disch, tempn.snf_ADL_5day_unique_n as fiveday 
where disch.pac_snf_unique=fiveday.pac_snf_unique; 
quit; *6,446,425 records;

/* Final data set for SNF ADL variable creation*/
data tempn.snf_ADL_disch_5day_n;
set tempn.snf_ADL_disch_5day_n;
ADL_bath_d=ADL_bath_1-ADL_bath_2; ADL_dress_d=ADL_dress_1-ADL_dress_2; ADL_trans_d=ADL_trans_1-ADL_trans_2; ADL_toilet_d=ADL_toilet_1-ADL_toilet_2;
ADL_eating_d=ADL_eating_1-ADL_eating_2; ADL_conti_d=ADL_conti_1-ADL_conti_2; ADL_total_d=ADL_total_1-ADL_total_2;
if ADL_bath_d gt 0 then ADL_bath_improved=1; else ADL_bath_improved=0;
if ADL_dress_d gt 0 then ADL_dress_improved=1; else ADL_dress_improved=0;
if ADL_toilet_d gt 0 then ADL_toilet_improved=1; else ADL_toilet_improved=0;
if ADL_trans_d gt 0 then ADL_trans_improved=1; else ADL_trans_improved=0;
if ADL_eating_d gt 0 then ADL_eating_improved=1; else ADL_eating_improved=0;
if ADL_conti_d gt 0 then ADL_conti_improved=1; else ADL_conti_improved=0;
if ADL_total_d gt 0 then ADL_total_improved=1; else ADL_total_improved=0;
run;*6,446,425;

data pac.snf_ADL_disch_5day_n;
set tempn.snf_ADL_disch_5day_n;
run;

proc sql;
create table check_obs as 
select distinct pac_snf_unique 
from pac.snf_ADL_disch_5day_n;
quit;

proc freq data=tempn.snf_ADL_disch_5day_n;
tables (ADL_bath_1 ADL_dress_1 ADL_toilet_1 ADL_trans_1 ADL_eating_1 ADL_conti_1
        ADL_bath_2 ADL_dress_2 ADL_toilet_2 ADL_trans_2 ADL_eating_2 ADL_conti_2 
        ADL_bath_improved ADL_dress_improved ADL_toilet_improved ADL_trans_improved ADL_eating_improved ADL_conti_improved ADL_total_improved);
run;

proc means data=tempn.snf_ADL_disch_5day_n maxdec=3;
var ADL_total_1 ADL_total_2 ADL_total_d ADL_total_improved;
run;





/*********************************************************************************
 Step 3: Combine 2010-2016 OASIS assessments and create HHA ADL variables;
*********************************************************************************/
***** Link OASIS data with MedPAR data, check matched numbers;
proc contents data=OASIS.hha_raw_28557_2010 out=hha_raw_28557_2010; run; * 16,359,336 records;
proc contents data=OASIS.hha_raw_28557_2011 out=hha_raw_28557_2011; run; * 16,759,245 records;
proc contents data=OASIS.hha_raw_28557_2012 out=hha_raw_28557_2012; run; * 16,961,051 records;
proc contents data=OASIS.hha_raw_28557_2013 out=hha_raw_28557_2013; run; * 17,211,625 records;
proc contents data=OASIS.Oasis28557_jan_jun_2014 out=Oasis28557_jan_jun_2014; run; * 8,663,072 records;
proc contents data=OASIS.Oasis28557_jul_dec_2014 out=Oasis28557_jul_dec_2014; run; * 8,692,191 records;
proc contents data=OASIS.hha_raw_51953_2015 out=hha_raw_51953_2015 noprint; run; * 17,919,698 records;
proc contents data=OASIS.hha_raw_51953_2016 out=hha_raw_51953_2016 noprint; run; * 18,236,018 records;

***** Link 2015 and 2016 OASIS Data Set with Xwalk to get bene_id;
/* Vertically combine 2015 and 2016 OASIS data sets */
proc sql;
create table hha_raw_51953_1516 as 
select * from OASIS.hha_raw_51953_2015
outer union corr 
select * from OASIS.hha_raw_51953_2016;
quit; * 36,155,716 records;

* Create a Xwalk data set for 2015 and 2016;
data pac_hha.oasis_res_bene_xwalk_1516;
set oasis.oasis_res_bene_xwalk_2016;
RSDNT_INTRNL_ID=res_int_id+0;
format RSDNT_INTRNL_ID 10.;
rename state_id = state_cd;
run; 

* Merge 2015-2016 OASIS with 2015-2016 Xwalk;
proc sql;
create table pac_hha.hha_beneid_2015_16 as
select hha.*,xwalk.res_int_id,xwalk.bene_id 
from hha_raw_51953_1516 as hha
left join pac_hha.oasis_res_bene_xwalk_1516 as xwalk
on hha.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and hha.state_cd=xwalk.state_cd;
quit; * 36,294,166 records;

data pac_hha.hha_beneid_2015_16;
set pac_hha.hha_beneid_2015_16;
if bene_id eq ' ' then bene_flag=1; else bene_flag=0;
STRT_CARE_DT=input(M0030_STRT_CARE_DT,yymmdd10.);
DSCHRG_DEATH_DT=input(M0906_DSCHRG_DEATH_DT,yymmdd10.);
hha_raw_id=_N_;
format STRT_CARE_DT DSCHRG_DEATH_DT date9.;
run; *;

proc freq data=pac_hha.hha_beneid_2015_16; table bene_flag; run;

proc sql; create table hha_missing_beneid_1516 as select distinct res_int_id, state_cd from pac_hha.hha_beneid_2015_16 where bene_flag eq 1; quit; * 53 records;

***** Link 2014 OASIS Data Set with Xwalk to get bene_id;
* Create OASIS 2014 data set by vertically combining Jan-Jun data set with Jul-Dec data set - 20,306,274;
proc sql;
create table pac_hha.hha_raw_28557_2014 as 
select * from OASIS.Oasis28557_jan_jun_2014
outer union corr 
select * from OASIS.Oasis28557_jul_dec_2014;
quit; *17,355,263 records;

* Create a Xwalk data set for 2014;
data pac_hha.oasis_res_bene_xwalk_28557_2014;
set oasis.oasis_res_bene_xwalk_28557_2014;
RSDNT_INTRNL_ID=res_int_id+0;
format RSDNT_INTRNL_ID 10.;
rename state_id = state_cd;
run; 

* Merge 2014 HHA with Xwalk 2014;
proc sql;
create table pac_hha.hha_beneid_14 as
select hha.*,xwalk.res_int_id,xwalk.bene_id 
from pac_hha.hha_raw_28557_2014 as hha
left join pac_hha.oasis_res_bene_xwalk_28557_2014 as xwalk
on hha.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and hha.state_cd=xwalk.state_cd;
quit; 

data pac_hha.hha_beneid_14;
set pac_hha.hha_beneid_14;
if bene_id eq ' ' then bene_flag=1; else bene_flag=0;
STRT_CARE_DT=input(M0030_STRT_CARE_DT,yymmdd10.);
DSCHRG_DEATH_DT=input(M0906_DSCHRG_DEATH_DT,yymmdd10.);
hha_raw_id=_N_;
format STRT_CARE_DT DSCHRG_DEATH_DT date9.;
run;*17,386,234;

proc freq data=pac_hha.hha_beneid_14; table bene_flag; run;

proc sql; create table pac_hha.hha_missing_beneid as select distinct res_int_id, state_cd from pac_hha.hha_beneid_14 where bene_flag eq 1; quit; *52 records;

* Merge 2010-2013 HHA data sets into one large data set;
data pac_hha.hha_raw_28557_2010_13;
set OASIS.hha_raw_28557_2010 OASIS.hha_raw_28557_2011 OASIS.hha_raw_28557_2012 OASIS.hha_raw_28557_2013;
STRT_CARE_DT=input(M0030_STRT_CARE_DT,yymmdd10.);
DSCHRG_DEATH_DT=input(M0906_DSCHRG_DEATH_DT,yymmdd10.);
hha_raw_id=_N_;
format STRT_CARE_DT DSCHRG_DEATH_DT date9.;
run;
* 67,291,257 records;

* Merge 2010-2013 HHA data set with Xwalk;
proc sql;
create table pac_hha.hha_beneid_2010_13 as
select hha.*,xwalk.res_int_id,xwalk.bene_id
from pac_hha.hha_raw_28557_2010_13 as hha
left join pac_hha.oasis_res_bene_xwalk as xwalk
on hha.RSDNT_INTRNL_ID=xwalk.RSDNT_INTRNL_ID and hha.state_cd=xwalk.state_cd;
quit; 
* 67,765,965 records, duplicates created due to multilple bene id matched with resident id and state;

proc sort data=pac_hha.hha_beneid_2010_13; by hha_raw_id; run;
data pac_hha.hha_beneid_2010_13;
set pac_hha.hha_beneid_2010_13;
if bene_id eq ' ' then bene_flag=1; else bene_flag=0;
run; 
proc freq data=pac_hha.hha_beneid_2010_13; table bene_flag; run;
   

proc sql; create table pac_hha.hha_missing_beneid as select distinct res_int_id, state_cd from pac_hha.hha_beneid_2010_13 
where bene_flag eq 1; quit; * 53 records;

* Check if 2014 HHA data set has the same number of variables as 2010-2013 HHA data set;
proc contents data=pac_hha.hha_beneid_14 noprint out=hha_beneid_14(keep=name);
run;

proc contents data=pac_hha.hha_beneid_2010_13 noprint out=hha_beneid_2010_13(keep=name);
run;

Proc sql;create table check_vars as select name from hha_beneid_14 where name not in (select name from hha_beneid_2010_13);quit; 

* Create 2010-2014 HHA data set with bene_id;
data pac_hha.hha_beneid_2010_14;
set pac_hha.hha_beneid_2010_13 pac_hha.hha_beneid_14;
run; *85,152,199 records;

proc freq data=pac_hha.hha_beneid_2010_14; table bene_flag; run;

* Create a Xwalk data set;
data pac_hha.oasis_res_bene_xwalk_2010_14;
set pac_hha.oasis_res_bene_xwalk pac_hha.oasis_res_bene_xwalk_28557_2014;
run; * 17,653,784 records;


data pac_hha.hha_beneid_2015_16;
set  pac_hha.hha_beneid_2015_16(rename=(C_RSDNT_AGE_NUM=C_RSDNT_AGE_NUM_2));
C_RSDNT_AGE_NUM=input(C_RSDNT_AGE_NUM_2,best12.);
drop C_RSDNT_AGE_NUM_2;
run;

data pac_hha.hha_beneid_2010_16;
set pac_hha.hha_beneid_2010_14 pac_hha.hha_beneid_2015_16;
run;  *121,446,365 records;

proc freq data=pac_hha.hha_beneid_2010_16; table bene_flag; run;


/* Get admission assessment records - keep only useful variables that could identify: 1) beneficiary 2) facility 3) admission date 4) discharge date */
data pac_hha.hha_beneid_2010_16_adms;
set pac_hha.hha_beneid_2010_16 (keep=bene_id M0010_CMS_CRTFCTN_NUM M0100_RSN_FOR_ASMT_CD STRT_CARE_DT bene_flag);
where M0100_RSN_FOR_ASMT_CD in("01","03") and bene_flag=0;
run; *45,453,275 records;

/* Get discharge assessment records - no need to include M0100_RSN_FOR_ASMT_CD="10" because there is no such record in the data set */
data pac_hha.hha_beneid_2010_16_dsrg;
set pac_hha.hha_beneid_2010_16 (keep=bene_id M0010_CMS_CRTFCTN_NUM M0100_RSN_FOR_ASMT_CD DSCHRG_DEATH_DT bene_flag);
where M0100_RSN_FOR_ASMT_CD in ("06","07","08","09") and bene_flag=0;
run; *43,806,558 records;

proc sql;
create table pac_hha.hha_1016_adms_dsrg as 
select a.*, b.DSCHRG_DEATH_DT 
from pac_hha.hha_beneid_2010_16_adms as a 
left join pac_hha.hha_beneid_2010_16_dsrg as b
on a.bene_id=b.bene_id
where a.STRT_CARE_DT<=DSCHRG_DEATH_DT;
quit; *135,051,980 records;

proc sort data=pac_hha.hha_1016_adms_dsrg;
by BENE_ID STRT_CARE_DT DSCHRG_DEATH_DT;
run;

data pac_hha.hha_1016_adms_dsrg_unique;
set pac_hha.hha_1016_adms_dsrg;
by BENE_ID STRT_CARE_DT DSCHRG_DEATH_DT;
if first.STRT_CARE_DT then output;
run; *36,740,688;

proc sort data=pac_hha.hha_1016_adms_dsrg_unique(keep=BENE_ID STRT_CARE_DT) out=check nodupkey;
by BENE_ID STRT_CARE_DT ;
run;


***** Link Merged OASIS data to MedPar Data;
proc sql;
create table tempn.pac_hha as
select * from Pac.Merge_all_1016
where disch_pac_n eq 3 & hospice^=1
order by bene_id;
quit; *8,073,624;

data tempn.pac_hha;
set tempn.pac_hha;
pac_hha_unique=_N_;
run; *8,073,624;

proc sql;
create table tempn.hha_medpar_combined as
select medpar.*, hha.*
from tempn.pac_hha as medpar 
left join pac_hha.hha_beneid_2010_16(rename=(bene_id=hha_bene_id STRT_CARE_DT=hha_ADMSN_DT DSCHRG_DEATH_DT=hha_DSCHRG_DT)) as hha
on hha.hha_bene_id=medpar.bene_id and -1 le medpar.ADMSNDT_HHA-hha.hha_ADMSN_DT le 1
order by pac_hha_unique;
quit; *21,745,887 records; 

* Check the numbers that could find a match;
proc sql; create table tempn.hha_matched as select distinct pac_hha_unique from tempn.hha_medpar_combined where hha_bene_id ne ' '; quit;
*  records could find a match with bene_id and +/- 1 day of admission;

*Check the numbers that couldn't find a match;
proc sql; create table tempn.hha_notmatched as select distinct pac_hha_unique  from tempn.hha_medpar_combined where hha_bene_id eq ' '; quit;
*0 records couldn't find a match with bene_id and +/- 1 day of admission;

data PAC.hha_medpar_combined;
set tempn.hha_medpar_combined;
where hha_bene_id ne ' ';
run; *21,745,887 records; 
proc sql; create table hha_check1 as select distinct pac_hha_unique from PAC.hha_medpar_combined; quit; *8,073,624 records;


***** HHA ADL variable creation;
data PAC.hha_medpar_combined;
set PAC.hha_medpar_combined;
if M0100_RSN_FOR_ASMT_CD in ('07','09') then valid_disch=1; else valid_disch=0;
if M0100_RSN_FOR_ASMT_CD eq '01' then valid_start=1; else valid_start=0;
run; *21,745,887 records; 
proc freq data=PAC.hha_medpar_combined; tables (valid_disch valid_start); run;


proc sql; create table tempn.hha_list1 as select distinct pac_hha_unique from PAC.hha_medpar_combined where valid_disch=1; quit;
*6,949,225 records in MedPAR that have a valid discharge assessment;
proc sql; create table tempn.hha_medpar_ADL1 as select * from PAC.hha_medpar_combined where pac_hha_unique in (select * from tempn.hha_list1); quit;
*17,984,702 records that have a valid discharge assessment;

proc sql; create table tempn.hha_list2 as select distinct pac_hha_unique from tempn.hha_medpar_ADL1 where valid_start=1 & valid_disch ne 1; quit;
*6,935,650 records in MedPAR that have a valid admission assessment;
proc sql; create table tempn.hha_medpar_ADL2 as select * from tempn.hha_medpar_ADL1 where pac_hha_unique in (select * from tempn.hha_list2); quit;
*17,921,778 records that have a valid admission assessment;

proc freq data=tempn.hha_medpar_ADL2;
tables (M1830_BATHG_CD M1810_DRESS_UPR_CD M1820_DRESS_LWR_CD M1845_TOILT_HYGNE_CD M1840_TOILT_TRNSFR_CD
        M1850_TRNSFRG_CD  M1870_EATG_CD  M1610_URNRY_INCNTNC_CD  M1620_BWL_INCNTNC_FREQ_CD M1850_TRNSFRG_CD M1860_AMBLTN_CD);
run;

data tempn.hha_medpar_ADL2_1;
set tempn.hha_medpar_ADL2;
if M0100_RSN_FOR_ASMT_CD eq '01' then do;
	if M1830_BATHG_CD eq ' ' | M1810_DRESS_UPR_CD eq ' ' | M1820_DRESS_LWR_CD eq ' ' | M1845_TOILT_HYGNE_CD eq ' ' | M1840_TOILT_TRNSFR_CD eq ' ' |
    M1850_TRNSFRG_CD eq ' ' | M1870_EATG_CD eq ' ' | M1610_URNRY_INCNTNC_CD eq ' ' | M1620_BWL_INCNTNC_FREQ_CD eq ' '  then flag_miss_ADL_start=1;
	if M1850_TRNSFRG_CD eq ' ' | M1860_AMBLTN_CD eq ' ' then flag_miss_MADL_start=1;
end;
if M0100_RSN_FOR_ASMT_CD in ('07','09') then do;
	if M1830_BATHG_CD eq ' ' | M1810_DRESS_UPR_CD eq ' ' | M1820_DRESS_LWR_CD eq ' ' | M1845_TOILT_HYGNE_CD eq ' ' | M1840_TOILT_TRNSFR_CD eq ' ' |
    M1850_TRNSFRG_CD eq ' ' | M1870_EATG_CD eq ' ' | M1610_URNRY_INCNTNC_CD eq ' ' | M1620_BWL_INCNTNC_FREQ_CD eq ' ' then flag_miss_ADL_disch=1;
	if M1850_TRNSFRG_CD eq ' ' | M1860_AMBLTN_CD eq ' ' then flag_miss_MADL_disch=1;
end;
run;

proc sql; create table hha_medpar_ADL2_1 as select distinct pac_hha_unique from tempn.hha_medpar_ADL2_1; quit; *6,935,650 records;;

proc freq data=tempn.hha_medpar_ADL2_1;
tables (flag_miss_ADL_start flag_miss_ADL_disch flag_miss_MADL_start flag_miss_MADL_disch);
run;

* Get a subset of relative variables, can use pac_hha_unique to link it back;
proc sql; 
create table Tempn.hha_medpar_ADL3 as
select BENE_ID, medpar_id, ADMSNDT, DSCHRGDT, pac_hha_unique, ADMSNDT_HHA, DSCHRGDT_HHA, hha_ADMSN_DT, hha_DSCHRG_DT, M0100_RSN_FOR_ASMT_CD,M1830,M1810,M1820,M1845,M1840,M1850,M1870,M1610,M1620,M1860, flag_miss_ADL_disch,flag_miss_MADL_disch
from Tempn.hha_medpar_ADL2_1(rename=(M1830_BATHG_CD=M1830 M1810_DRESS_UPR_CD=M1810 M1820_DRESS_LWR_CD=M1820 M1845_TOILT_HYGNE_CD=M1845
M1840_TOILT_TRNSFR_CD=M1840 M1850_TRNSFRG_CD=M1850 M1870_EATG_CD=M1870 M1610_URNRY_INCNTNC_CD=M1610 M1620_BWL_INCNTNC_FREQ_CD=M1620 M1860_AMBLTN_CD=M1860));
quit; *17,921,778 records;

data tempn.hha_medpar_ADL3_1;
set Tempn.hha_medpar_ADL3;
if M0100_RSN_FOR_ASMT_CD in ('01','07','09') then do;
* ADL variables;
if M1830 in ('00','01','04') then ADL_bath=0; else if M1830 in ('02','03','05','06') then ADL_bath=1; 
if M1810 ='00' and M1820 ='00' then ADL_dress=0; else if M1810^=" " and M1820^=" " then ADL_dress=1;
if M1845 in ('00','01') and M1840 eq '00' then ADL_toilet=0; else if M1840^=" " and M1845^=" " then ADL_toilet=1; 
if M1850 in ('00','01')  then ADL_trans=0; else if M1850 in ('02','03','04','05') then ADL_trans=1; 
if M1870 in ('00','01','03') then ADL_eating=0; else if M1870 in ('02','04','05') then ADL_eating=1;
if M1610 in ('00','02') then ADL_uri=0; else if M1610 eq '01' then ADL_uri=2; 
if M1620 in ('00','UK','NA') then ADL_bwl=0; else if M1620 in ('01','02','03','04','05') then ADL_bwl=1; 
if ADL_uri=0 and ADL_bwl=0 then ADL_conti=0; else if ADL_uri^=. and ADL_bwl^=. then ADL_conti=1;
ADL_total=sum(ADL_bath, ADL_dress, ADL_trans, ADL_toilet, ADL_eating, ADL_conti);
if ADL_total eq 0 & M0100_RSN_FOR_ASMT_CD eq '01' then flag_ADL_impair=1;
* MADL variables;
if M1850 eq '00' then MADL_trans=0; else if M1850 in ('01','02') then MADL_trans=1; else if M1850 in ('03','04','05') then MADL_trans=2;
if M1860 in ('00','01','04') then MADL_ambl=0; else if M1860 in ('02','03') then MADL_ambl=1; else if M1860 in ('05','06') then MADL_ambl=2;
MADL_total=sum(MADL_trans, MADL_ambl);
if MADL_total eq 0 & M0100_RSN_FOR_ASMT_CD eq '01' then flag_MADL_impair=1;
end;
run;  

proc sql; create table tempn.hha_list3_1 as select distinct pac_hha_unique from tempn.hha_medpar_ADL3_1 where flag_ADL_impair=1; quit;
*373,348 records in MedPAR that without ADL impairment at start care assessment;
proc sql; create table tempn.hha_medpar_ADL4_1 as select * from tempn.hha_medpar_ADL3_1 where pac_hha_unique not in (select * from tempn.hha_list3_1); quit;
*17,023,512 records that with ADL impairment at start care assessment;
proc sql; create table hha_medpar_adl4_include as select distinct pac_hha_unique from tempn.hha_medpar_ADL4_1; quit;
*6,562,302 unique HHA records with ADL impairment at start care assessment;

proc sql; create table tempn.hha_list4_1 as select distinct pac_hha_unique from tempn.hha_medpar_ADL4_1 where flag_miss_ADL_disch=1; quit;
*275,565 records in MedPAR that with missing ADL item at discharge;
proc sql; create table tempn.hha_medpar_ADL5_1 as select * from tempn.hha_medpar_ADL4_1 where pac_hha_unique not in (select * from tempn.hha_list4_1); quit;
*15,975,049 records that without any missing ADL item at discharge;
proc sql; create table hha_medpar_adl5_include as select distinct pac_hha_unique from tempn.hha_medpar_ADL5_1; quit;
*6,286,737 unique HHA records with ADL impairment at start care assessment;

proc sql; create table hha_ADL_disch as 
select BENE_ID, medpar_id, ADMSNDT, DSCHRGDT,pac_hha_unique, hha_DSCHRG_DT,ADL_bath as ADL_bath_2, ADL_dress as ADL_dress_2, ADL_trans as ADL_trans_2, ADL_toilet as ADL_toilet_2, ADL_eating as ADL_eating_2, ADL_conti as ADL_conti_2, ADL_total as ADL_total_2
from tempn.hha_medpar_ADL5_1
where M0100_RSN_FOR_ASMT_CD in ('07','09'); 
quit; *6,308,384 records;

proc sort data=hha_ADL_disch; by pac_hha_unique hha_DSCHRG_DT; run;

data tempn.hha_ADL_disch_unique;
merge hha_ADL_disch;
by pac_hha_unique hha_DSCHRG_DT;
if first.pac_hha_unique;
run; *6,286,737 records;

proc sql; create table hha_ADL_start as 
select BENE_ID, medpar_id, ADMSNDT, DSCHRGDT,pac_hha_unique, hha_ADMSN_DT,ADL_bath as ADL_bath_1, ADL_dress as ADL_dress_1, ADL_trans as ADL_trans_1, ADL_toilet as ADL_toilet_1, ADL_eating as ADL_eating_1, ADL_conti as ADL_conti_1, ADL_total as ADL_total_1
from tempn.hha_medpar_ADL5_1 
where M0100_RSN_FOR_ASMT_CD eq '01'; 
quit; *6,290,506 records;

proc sort data=hha_ADL_start; by pac_hha_unique hha_ADMSN_DT; run;

data tempn.hha_ADL_start_unique;
merge hha_ADL_start;
by pac_hha_unique hha_ADMSN_DT;
if first.pac_hha_unique;
run; *6,290,506 records;

proc sql; create table tempn.hha_ADL_disch_start as select disch.*, start.* 
from tempn.hha_ADL_disch_unique as disch, tempn.hha_ADL_start_unique as start 
where disch.pac_hha_unique=start.pac_hha_unique; 
quit; *6,286,737 records;

data tempn.hha_ADL_disch_start;
set tempn.hha_ADL_disch_start;
ADL_bath_d=ADL_bath_1-ADL_bath_2; ADL_dress_d=ADL_dress_1-ADL_dress_2; ADL_trans_d=ADL_trans_1-ADL_trans_2; ADL_toilet_d=ADL_toilet_1-ADL_toilet_2;
ADL_eating_d=ADL_eating_1-ADL_eating_2; ADL_conti_d=ADL_conti_1-ADL_conti_2; ADL_total_d=ADL_total_1-ADL_total_2;
if ADL_bath_d gt 0 then ADL_bath_improved=1; else ADL_bath_improved=0;
if ADL_dress_d gt 0 then ADL_dress_improved=1; else ADL_dress_improved=0;
if ADL_toilet_d gt 0 then ADL_toilet_improved=1; else ADL_toilet_improved=0;
if ADL_trans_d gt 0 then ADL_trans_improved=1; else ADL_trans_improved=0;
if ADL_eating_d gt 0 then ADL_eating_improved=1; else ADL_eating_improved=0;
if ADL_conti_d gt 0 then ADL_conti_improved=1; else ADL_conti_improved=0;
if ADL_total_d gt 0 then ADL_total_improved=1; else ADL_total_improved=0;
run; *6,286,737 records;

proc freq data=tempn.hha_ADL_disch_start;
tables (ADL_bath_1 ADL_dress_1 ADL_toilet_1 ADL_trans_1 ADL_eating_1 ADL_conti_1 
        ADL_bath_2 ADL_dress_2 ADL_toilet_2 ADL_trans_2 ADL_eating_2 ADL_conti_2 
        ADL_bath_improved ADL_dress_improved ADL_toilet_improved ADL_trans_improved ADL_eating_improved ADL_conti_improved ADL_total_improved);
run;

proc means data=tempn.hha_ADL_disch_start maxdec=3;
var ADL_total_1 ADL_total_2 ADL_total_d;
run;





/*********************************************************************************
 Step 4: Combine 2010-2016 IRFPAI assessments and create IRF ADL variables;
*********************************************************************************/
*****Link IRFPAI data with MedPAR data, check matched numbers ;
proc contents data=IRFPAI.if_pai_raw_28557_2010 noprint out=if_pai_raw_28557_2010; run; * 415,943 records/189 variables;
proc contents data=IRFPAI.if_pai_raw_28557_2011 noprint out=if_pai_raw_28557_2011; run; * 425,109 records/189 variables;
proc contents data=IRFPAI.irf_pai_raw_28557_2012 noprint out=if_pai_raw_28557_2012; run; * 431,409 records/189 variables;
proc contents data=IRFPAI.irf_pai_raw_28557_2013 noprint out=if_pai_raw_28557_2013; run; * ;
proc contents data=IRFPAI.irf_pai_raw_28557_2014 noprint out=irf_pai_raw_28557_2014; run; * 443189 records/190 variables;
proc contents data=IRFPAI.irf_pai_raw_2015 noprint out=irf_pai_raw_2015; run; * 464,999 records/189 variables;
proc contents data=IRFPAI.irf_pai_raw_2016 noprint out=irf_pai_raw_2016; run; * 464,812 records/189 variables;

data pac.irf_pai_raw_28557_2010_13;
set IRFPAI.if_pai_raw_28557_2010 IRFPAI.if_pai_raw_28557_2011 IRFPAI.irf_pai_raw_28557_2012 IRFPAI.irf_pai_raw_28557_2013;
run; * 1709344 records;

* Combine the 2014 IRFPAI data set with 2010-2013 IRFPAI data set;
data pac.irf_pai_raw_28557_2010_14;
set pac.irf_pai_raw_28557_2010_13 IRFPAI.irf_pai_raw_28557_2014;
run; /* 2,152,533 records */

*Combine 2015 and 2016 IRFPAI data sets with 2010-2014 IRFPAI;
data pac.irf_pai_raw_28557_2010_16;
set pac.irf_pai_raw_28557_2010_14 IRFPAI.irf_pai_raw_2015 IRFPAI.irf_pai_raw_2016;
run; *3,082,344;

proc sql;
create table tempn.pac_irf as
select * from Pac.Merge_all_1016
where disch_pac_n eq 2 & hospice^=1
order by bene_id;
quit; *2,086,955 records;
data tempn.pac_irf;
set tempn.pac_irf;
pac_irf_unique=_N_;
run; *2,086,955 records;

proc sql;
create table tempn.irf_medpar_link as
select medpar.bene_id, medpar.ADMSNDT_IRF, medpar.pac_irf_unique, irf.bene_id as irf_bene_id, irf.admsn_dt as irf_admsn_dt
from tempn.pac_irf as medpar 
left join pac.irf_pai_raw_28557_2010_16 as irf
on irf.bene_id=medpar.bene_id and -1 le medpar.ADMSNDT_IRF-irf.admsn_dt le 1;
quit; *2,090,479 records;

proc sort data=tempn.irf_medpar_link; by pac_irf_unique; run;

data tempn.irf_medpar_link_unique;
merge tempn.irf_medpar_link;
by pac_irf_unique;
if first.pac_irf_unique;
run; *2,086,955 records;

data tempn.irf_medpar_link_unique;
set tempn.irf_medpar_link_unique;
if irf_bene_id ne ' ' then irfpai=1; else irfpai=0;
run;

proc freq data=tempn.irf_medpar_link_unique; table irfpai; run;

proc sql;
create table tempn.irf_medpar_link_1 as
select medpar.bene_id, medpar.ADMSNDT_IRF, medpar.pac_irf_unique ,irf.bene_id as irf_bene_id, irf.admsn_dt as irf_admsn_dt
from tempn.pac_irf as medpar 
left join pac.irf_pai_raw_28557_2010_16 as irf
on irf.bene_id=medpar.bene_id and -3 le medpar.ADMSNDT_IRF-irf.admsn_dt le 3;
quit; *2,091,737 records;

proc sort data=tempn.irf_medpar_link_1; by pac_irf_unique; run;

data tempn.irf_medpar_link_unique_1;
merge tempn.irf_medpar_link_1;
by pac_irf_unique;
if first.pac_irf_unique;
run; *2,086,955 records;

data tempn.irf_medpar_link_unique_1;
set tempn.irf_medpar_link_unique_1;
if irf_bene_id ne ' ' then irfpai=1; else irfpai=0;
run;

proc freq data=tempn.irf_medpar_link_unique_1; table irfpai; run;

data tempn.irf_medpar_link_unique_1_1;
set tempn.irf_medpar_link_unique_1;
where irfpai eq 0;
run; *106,844 records;

proc sql;
create table tempn.irf_medpar_link_1_2 as
select medpar.bene_id, medpar.ADMSNDT_IRF, medpar.pac_irf_unique, irf.bene_id as irf_bene_id, irf.admsn_dt as irf_admsn_dt
from tempn.irf_medpar_link_unique_1_1 as medpar, pac.irf_pai_raw_28557_2010_14 as irf
where irf.bene_id=medpar.bene_id;
quit; * 14,349 records;

proc sort data=tempn.irf_medpar_link_1_2; by pac_irf_unique; run;

data tempn.irf_medpar_link_unique_1_2;
merge tempn.irf_medpar_link_1_2;
by pac_irf_unique;
if first.pac_irf_unique;
run; *10,657 records;

data tempn.irf_medpar_link_unique_1_2;
set tempn.irf_medpar_link_unique_1_2;
format ADMSNDT_IRF date9.;
date_diff=ADMSNDT_IRF-irf_admsn_dt;
run;

proc means data=tempn.irf_medpar_link_unique_1_2;
var date_diff;
run;

***** Merge IRFPAI data with MedPAR data;
proc sql;
create table tempn.pac_irf as
select * from Pac.Merge_all_1016
where disch_pac_n eq 2 & hospice^=1
order by bene_id;
quit; *2,086,955 records;

data tempn.pac_irf;
set tempn.pac_irf;
pac_irf_unique=_N_;
run; *2,086,955 records;

proc sql;
create table tempn.pac_irf_nolast90 as
select * from tempn.pac_irf
where (DSCHRGDT + 90) le 20819 
order by bene_id;
quit; *2,060,516 records;

data tempn.pac_irf_nolast90;
set tempn.pac_irf_nolast90 (drop=pac_irf_unique);
pac_irf_unique=_N_;
run; *2,060,516 records;

proc sql;
create table tempn.irf_medpar_combined as
select medpar.*, irf.*
from tempn.pac_irf as medpar 
left join pac.irf_pai_raw_28557_2010_16(rename=(bene_id=irf_bene_id ADMSN_DT=irf_ADMSN_DT DSCHRG_DT=IRF_DSCHRG_DT)) as irf
on irf.irf_bene_id=medpar.bene_id and -1 le medpar.ADMSNDT_IRF-irf.irf_ADMSN_DT le 1
order by pac_irf_unique;
quit; *2,090,479 records;

data tempn.irf_medpar_combined_unique;
merge tempn.irf_medpar_combined;
by pac_irf_unique;
if first.pac_irf_unique;
run; *2,086,955 records;

data PAC.irf_medpar_combined;
set tempn.irf_medpar_combined_unique;
if irf_bene_id ne ' ' then irfpai=1; else irfpai=0;
run;
proc freq data=PAC.irf_medpar_combined; table irfpai; run;

data PAC.irf_medpar_matched;
set PAC.irf_medpar_combined;
where irfpai eq 1;
run; *1,978,870 records;

* Checking structure of IRF-PAI: each IRF stay only has one record in IRF-PAI data file;
proc sql; create table test as select distinct bene_id from PAC.irf_medpar_matched; quit; *1,636,512 records;
proc sort data=PAC.irf_medpar_matched; by bene_id IRF_ADMSN_DT; run; *1,978,870 records;
data test1;
merge PAC.irf_medpar_matched;
by bene_id IRF_ADMSN_DT;
if last.bene_id;
run; *1,636,512 records;
data test2;
merge PAC.irf_medpar_matched(in=all keep=bene_id IRF_ADMSN_DT) test1(in=single keep=bene_id IRF_ADMSN_DT);
by bene_id IRF_ADMSN_DT;
if all and not single;
run; *335,907 records;

data PAC.irf_medpar_matched;
set PAC.irf_medpar_matched;
if IRF_DSCHRG_DT eq . or DSCHRG_TO_LVG_SETG_CD = "11" then IRFPAI_DSCHRG_valid=0; else IRFPAI_DSCHRG_valid=1;
if IRF_ADMSN_DT eq . then IRFPAI_ADMSN_valid=0; else IRFPAI_ADMSN_valid=1;
run;
proc freq data=PAC.irf_medpar_matched; tables (IRFPAI_DSCHRG_valid IRFPAI_ADMSN_valid); run;

data tempn.irf_medpar_matched_valid;
set PAC.irf_medpar_matched;
where IRFPAI_DSCHRG_valid=1 and IRFPAI_ADMSN_valid=1;
run;*1,976,479 records;

proc sql; create table irf_medpar_matched_valid as select distinct pac_irf_unique from tempn.irf_medpar_matched_valid;quit;	*Included: 1,976,479 records;

/* Exclude the residents who were comatose at admission*/ 
data tempn.irf_medpar_matched_notcomatose;
set tempn.irf_medpar_matched_valid;
where CMTS_SW ^="1";
run; *Included: 1,976,067 records;

proc freq data=tempn.irf_medpar_matched_notcomatose;
tables (BATHG_ADMSN_CD BATHG_DSCHRG_CD DRSG_UPR_ADMSN_CD DRSG_UPR_DSCHRG_CD DRSG_LWR_ADMSN_CD DRSG_LWR_DSCHRG_CD
        TOILTG_ADMSN_CD TOILTG_DSCHRG_CD BED_CHR_WC_ADMSN_CD BED_CHR_WC_DSCHRG_CD SPHNCTR_BLADR_ADMSN_CD SPHNCTR_BLADR_DSCHRG_CD 
        SPHNCTR_BWL_ADMSN_CD SPHNCTR_BWL_DSCHRG_CD EATG_ADMSN_CD EATG_DSCHRG_CD WLK_WC_ADMSN_CD WLK_WC_BOTH_ADMSN_CD WLK_WC_DSCHRG_CD WLK_WC_BOTH_DSCHRG_CD 
        WLK_WC_GOAL_CD);
run;

proc freq data=tempn.irf_medpar_matched_notcomatose;
tables (WLK_WC_ADMSN_CD WLK_WC_BOTH_ADMSN_CD WLK_WC_DSCHRG_CD WLK_WC_BOTH_DSCHRG_CD WLK_WC_GOAL_CD);
run;

/* Exclude the patients who were discharged against medical advice (unplanned discharge) */
data  tempn.irf_medpar_matched_planned;
set  tempn.irf_medpar_matched_notcomatose;
where DSCHRG_AGNST_MDCL_ADVC_SW^="1";
run; * Included: 1,972,085 records;

/* Create ADL variables */
data tempn.irf_medpar_ADL;
set tempn.irf_medpar_matched_planned;
*Bathing;
if BATHG_ADMSN_CD in ('00','06','07') then BATHG_ADMSN=0; else if BATHG_ADMSN_CD in ('01','02','03','04','05') then BATHG_ADMSN=1; 
if BATHG_DSCHRG_CD in ('00','06','07') then BATHG_DSCHRG=0; else if BATHG_DSCHRG_CD in ('01','02','03','04','05') then BATHG_DSCHRG=1; 
*Dressing;
if DRSG_UPR_ADMSN_CD in ('00','06','07') then DRSG_UPR_ADMSN=0; else if DRSG_UPR_ADMSN_CD in ('01','02','03','04','05') then DRSG_UPR_ADMSN=1; 
if DRSG_UPR_DSCHRG_CD in ('00','06','07') then DRSG_UPR_DSCHRG=0; else if DRSG_UPR_DSCHRG_CD in ('01','02','03','04','05') then DRSG_UPR_DSCHRG=1; 
if DRSG_LWR_ADMSN_CD in ('00','06','07') then DRSG_LWR_ADMSN=0; else if DRSG_LWR_ADMSN_CD in ('01','02','03','04','05') then DRSG_LWR_ADMSN=1; 
if DRSG_LWR_DSCHRG_CD in ('00','06','07') then DRSG_LWR_DSCHRG=0; else if DRSG_LWR_DSCHRG_CD in ('01','02','03','04','05') then DRSG_LWR_DSCHRG=1; 
if DRSG_UPR_ADMSN=0 and DRSG_LWR_ADMSN=0 then DRSG_ADMSN = 0; else DRSG_ADMSN=1;
if DRSG_UPR_DSCHRG=0 and DRSG_LWR_DSCHRG=0 then DRSG_DSCHRG=0; else DRSG_DSCHRG=1;
*Toileting;
if TOILTG_ADMSN_CD in ('00','06','07') then TOILTG_ADMSN=0; else if TOILTG_ADMSN_CD in ('01','02','03','04','05') then TOILTG_ADMSN=1; 
if TOILTG_DSCHRG_CD in ('00','06','07') then TOILTG_DSCHRG=0; else if TOILTG_DSCHRG_CD in ('01','02','03','04','05') then TOILTG_DSCHRG=1; 
if TOILT_ADMSN_CD in ('00','06','07') then TOILT_ADMSN=0; else if TOILT_ADMSN_CD in ('01','02','03','04','05') then TOILT_ADMSN=1; 
if TOILT_DSCHRG_CD in ('00','06','07') then TOILT_DSCHRG=0; else if TOILT_DSCHRG_CD in ('01','02','03','04','05') then TOILT_DSCHRG=1;
if TOILTG_ADMSN=0 and TOILT_ADMSN=0 then TOILTING_ADMSN=0;else TOILTING_ADMSN=1;
if TOILTG_DSCHRG=0 and TOILT_DSCHRG=0 then TOILTING_DSCHRG=0;else TOILTING_DSCHRG=1;
* Transfer;
if BED_CHR_WC_ADMSN_CD in ('00','06','07') then BED_CHR_WC_ADMSN=0; else if BED_CHR_WC_ADMSN_CD in ('01','02','03','04','05') then BED_CHR_WC_ADMSN=1; 
if BED_CHR_WC_DSCHRG_CD in ('00','06','07') then BED_CHR_WC_DSCHRG=0; else if BED_CHR_WC_DSCHRG_CD in ('01','02','03','04','05') then BED_CHR_WC_DSCHRG=1; 
* Continence;
if SPHNCTR_BLADR_ADMSN_CD in ('00','06','07') then SPHNCTR_BLADR_ADMSN=0; else if SPHNCTR_BLADR_ADMSN_CD in ('01','02','03','04','05') then SPHNCTR_BLADR_ADMSN=1; 
if SPHNCTR_BLADR_DSCHRG_CD in ('00','06','07') then SPHNCTR_BLADR_DSCHRG=0; else if SPHNCTR_BLADR_DSCHRG_CD in ('01','02','03','04','05') then SPHNCTR_BLADR_DSCHRG=1; 
if SPHNCTR_BWL_ADMSN_CD in ('00','06','07') then SPHNCTR_BWL_ADMSN=0; else if SPHNCTR_BWL_ADMSN_CD in ('01','02','03','04','05') then SPHNCTR_BWL_ADMSN=1; 
if SPHNCTR_BWL_DSCHRG_CD in ('00','06','07') then SPHNCTR_BWL_DSCHRG=0; else if SPHNCTR_BWL_DSCHRG_CD in ('01','02','03','04','05') then SPHNCTR_BWL_DSCHRG=1; 
if SPHNCTR_BLADR_ADMSN=0 and  SPHNCTR_BWL_ADMSN=0 then SPHNCTR_ADMSN=0;else SPHNCTR_ADMSN=1;
if SPHNCTR_BLADR_DSCHRG=0 and SPHNCTR_BWL_DSCHRG=0 then SPHNCTR_DSCHRG=0; else SPHNCTR_DSCHRG=1;
* Eating;
if EATG_ADMSN_CD in ('00','06','07') then EATG_ADMSN=0; else if EATG_ADMSN_CD in ('01','02','03','04','05') then EATG_ADMSN=1; 
if EATG_DSCHRG_CD in ('00','06','07') then EATG_DSCHRG=0; else if EATG_DSCHRG_CD in ('01','02','03','04','05') then EATG_DSCHRG=1;

if WLK_WC_ADMSN_CD in ('00','06','07') then WLK_WC_ADMSN=0; else if WLK_WC_ADMSN_CD in ('03','04','05') then WLK_WC_ADMSN=1; else WLK_WC_ADMSN=2;
if WLK_WC_DSCHRG_CD in ('00','06','07') then WLK_WC_DSCHRG=0; else if WLK_WC_DSCHRG_CD in ('03','04','05') then WLK_WC_DSCHRG=1; else WLK_WC_DSCHRG=2;

ADL_total_1=sum(BATHG_ADMSN,DRSG_ADMSN, TOILTING_ADMSN,BED_CHR_WC_ADMSN,SPHNCTR_ADMSN,EATG_ADMSN);
ADL_total_2=sum(BATHG_DSCHRG,DRSG_DSCHRG,TOILTING_DSCHRG,BED_CHR_WC_DSCHRG,SPHNCTR_DSCHRG,EATG_DSCHRG);

MADL_total_1=sum(BED_CHR_WC_ADMSN,WLK_WC_ADMSN);
MADL_total_2=sum(BED_CHR_WC_DSCHRG,WLK_WC_DSCHRG);

if ADL_total_1 eq 0 then flag_ADL_impair=1; else flag_ADL_impair=0;
if MADL_total_1 eq 0 then flag_MADL_impair=1; else flag_MADL_impair=0;
BATHG_d=BATHG_ADMSN-BATHG_DSCHRG; if BATHG_d gt 0 then BATHG_improved=1; else BATHG_improved=0;
DRSG_d=DRSG_ADMSN-DRSG_DSCHRG; if DRSG_d gt 0 then DRSG_improved=1; else DRSG_improved=0;
TOILTING_d=TOILTING_ADMSN-TOILTING_DSCHRG; if TOILTING_d gt 0 then TOILTING_improved=1; else TOILTING_improved=0;
BED_CHR_WC_d=BED_CHR_WC_ADMSN-BED_CHR_WC_DSCHRG; if BED_CHR_WC_d gt 0 then BED_CHR_WC_improved=1; else BED_CHR_WC_improved=0;
SPHNCTR_d=SPHNCTR_ADMSN-SPHNCTR_DSCHRG; if SPHNCTR_d gt 0 then SPHNCTR_improved=1; else SPHNCTR_improved=0;
EATG_d=EATG_ADMSN-EATG_DSCHRG; if EATG_d gt 0 then EATG_improved=1; else EATG_improved=0;
WLK_WC_d=WLK_WC_ADMSN-WLK_WC_DSCHRG; if WLK_WC_d gt 0 then WLK_WC_improved=1; else WLK_WC_improved=0;
ADL_total_d=ADL_total_1-ADL_total_2; if ADL_total_d gt 0 then ADL_total_improved=1; else ADL_total_improved=0;
MADL_total_d=MADL_total_1-MADL_total_2; if MADL_total_d gt 0 then MADL_improved=1; else MADL_improved=0;
run; * 1,970,285 records;

proc freq data=tempn.irf_medpar_ADL; tables (flag_ADL_impair flag_MADL_impair); run;


data PAC.irf_medpar_ADL;
set tempn.irf_medpar_ADL;
where flag_ADL_impair eq 0;
run;*1,969,753;

proc freq data=tempn.irf_medpar_ADL;
where flag_ADL_impair eq 0;
tables (BATHG_ADMSN DRSG_ADMSN TOILTING_ADMSN BED_CHR_WC_ADMSN SPHNCTR_ADMSN EATG_ADMSN 
        BATHG_DSCHRG DRSG_DSCHRG TOILTING_DSCHRG BED_CHR_WC_DSCHRG SPHNCTR_DSCHRG EATG_DSCHRG 
        BATHG_improved DRSG_improved TOILTING_improved BED_CHR_WC_improved SPHNCTR_improved EATG_improved ADL_total_improved);
run; 

proc means data=tempn.irf_medpar_ADL maxdec=3; where flag_ADL_impair eq 0; var ADL_total_1 ADL_total_2 ADL_total_d; run;





/*********************************************************************************
 Step 5: Get post-discharge information for hospital discharge cohort and merge 
         in ADL variables from MDS, HHA and IRF data sets 
*********************************************************************************/
*Read IRF data from MedPAR data 2010-2016;
proc sql;
create table MedPAR2010_16_IRF as
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2010(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF)) 
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") union all
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2011(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF)) 
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") union all
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2012(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF)) 
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") union all
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2013(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF))
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") union all
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2014(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF)) 
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") union all
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2015(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF))
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") union all
select BENE_ID, ADMSNDT_IRF, DSCHRGDT_IRF, PMT_AMT_IRF, PRVDR_NUM, SPCLUNIT, UTIL_DAY, medpar_id from Medpar.Mp100mod_2016(rename=(ADMSNDT=ADMSNDT_IRF DSCHRGDT=DSCHRGDT_IRF PMT_AMT=PMT_AMT_IRF))
where SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099")
order by BENE_ID, ADMSNDT_IRF;
quit; *3,024,739; 
data mp.MedPAR2010_16_IRF_unique;
set MedPAR2010_16_IRF;
by BENE_ID ADMSNDT_IRF;
if first.ADMSNDT_IRF then output;
run; *3,024,646; 
* No need to generate pseudo discharge date for IRF because there is no missing.

*Get Other claim, discharge to other;
data medpar2010;
	set Medpar.Mp100mod_2010;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;
data medpar2011;
set Medpar.Mp100mod_2011;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;
data medpar2012;
set Medpar.Mp100mod_2012;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;
data medpar2013;
	set Medpar.Mp100mod_2013;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;
data medpar2014;
	set Medpar.Mp100mod_2014;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;
data medpar2015;
	set Medpar.Mp100mod_2015;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;
data medpar2016;
	set Medpar.Mp100mod_2016;
	if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or 1300<=substr(PRVDR_NUM,3,4)<=1399) & SPCLUNIT not in ('M','R','S','T') then type=0;
		else if substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') then type=1;
		else if SPCLUNIT in ('R','T') or ("3025"<=substr(prvdr_num,3,4)<="3099") then type=2;
		else type=4;
	keep BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM PMT_AMT type UTIL_DAY medpar_id;
run;

proc sql;
create table medpar2010_16_other as
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2010 where type eq 4 union all
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2011 where type eq 4 union all
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2012 where type eq 4 union all
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2013 where type eq 4 union all
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2014 where type eq 4 union all
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2015 where type eq 4 union all
select BENE_ID, ADMSNDT as ADMSNDT_other, DSCHRGDT as DSCHRGDT_other, PRVDR_NUM as other_PRVDRNUM, PMT_AMT as PMT_AMT_other, UTIL_DAY as UTIL_DAY_other, medpar_id as medpar_id_other 
from medpar2016 where type eq 4;
quit; *4,031,053 records;
proc sort data=medpar2010_16_other; by BENE_ID ADMSNDT_other; run; 

data mp.other2010_16_unique;
set medpar2010_16_other;
by BENE_ID ADMSNDT_other;
if first.ADMSNDT_other then output;
run; *4,030,039 records;

*Merge SNF, IRF and HHA data with hospital data;
proc sql;
create table temp.merge_all_2010_16 as
select distinct main.*, snf.MDS_ENTRY_DT as ADMSNDT_SNF, snf.MDS_DSCHRG_DT as DSCHRGDT_SNF, snf.PRVDR_NUM as PRVDRNUM_SNF, 
                        irf.ADMSNDT_IRF, irf.DSCHRGDT_IRF, irf.PRVDR_NUM as PRVDRNUM_IRF, irf.PMT_AMT_IRF, irf.UTIL_DAY as UTIL_DAY_IRF, irf.medpar_id as medpar_id_irf,
                        hha.STRT_CARE_DT as ADMSNDT_HHA, hha.DSCHRG_DEATH_DT as DSCHRGDT_HHA, hha.M0010_CMS_CRTFCTN_NUM as PRVDRNUM_HHA, 
                        other.ADMSNDT_other, other.DSCHRGDT_other, other.other_PRVDRNUM, other.PMT_AMT_other, other.UTIL_DAY_other, other.medpar_id_other 
from mp.Merged2010_16(rename=(PRVDR_NUM=HOSP_PRVDRNUM)) as main
left join tempn.mds_2010_16_admsn_dschrg as snf on main.BENE_ID=snf.BENE_ID
left join mp.MedPAR2010_16_IRF_unique as irf on main.BENE_ID=irf.BENE_ID
left join pac_hha.hha_1016_adms_dsrg_unique as hha on main.BENE_ID=hha.BENE_ID
left join mp.other2010_16_unique as other on main.BENE_ID=other.BENE_ID;
quit; *575,190,817 records; 

*Patients should be sent to post-acute care instutitions within 3 days after the hospital discharge date; 
data temp.merge_all_2010_16_2;
set temp.merge_all_2010_16;
if 0 le ADMSNDT_SNF-DSCHRGDT le 3 then gap_snf=ADMSNDT_SNF-DSCHRGDT; else gap_snf=.;
if 0 le ADMSNDT_IRF-DSCHRGDT le 3 then gap_irf=ADMSNDT_IRF-DSCHRGDT; else gap_irf=.;
if 0 le ADMSNDT_HHA-DSCHRGDT le 3 then gap_hha=ADMSNDT_HHA-DSCHRGDT; else gap_hha=.;
if 0 le ADMSNDT_other-DSCHRGDT le 3 then gap_other=ADMSNDT_other-DSCHRGDT; else gap_other=.;
if gap_snf ne . | gap_irf ne . | gap_hha ne . | gap_other ne . then do;
    if min(gap_snf, gap_irf, gap_hha, gap_other) eq gap_other then do; disch_pac_n=4; gap=gap_other; end;
	if min(gap_snf, gap_irf, gap_hha, gap_other) eq gap_hha then do; disch_pac_n=3; gap=gap_hha; end;
	if min(gap_snf, gap_irf, gap_hha, gap_other) eq gap_irf then do; disch_pac_n=2; gap=gap_irf; end;
	if min(gap_snf, gap_irf, gap_hha, gap_other) eq gap_snf then do; disch_pac_n=1; gap=gap_snf; end;
end;
if gap eq . then gap=99;
run; 

proc sort data=temp.merge_all_2010_16_2; by BENE_ID DSCHRGDT gap; run;
data temp.merge_all_2010_16_2;
set temp.merge_all_2010_16_2;
by BENE_ID DSCHRGDT gap;
if first.DSCHRGDT then output;
run; *69,258,622 records;

*Use ibash to run these parts;
data mp.merge_all_2010_16;
set temp.merge_all_2010_16_2;
if disch_pac_n eq . then disch_pac_n=0;
dschrg_year=year(dschrgdt);
label tkr_thr_drg='Major joint replacement'
      sepsis_drg='Sepsis or Septicemia'
      uti_drg='Kidney & urinary tract infections'
      pneu_drg='Pneumonia & pleurisy'
      chf_drg='Heart failure & shock'
      hipfx_drg='Hip & pelvis fracture'
      dschrg_year='Discharge Year';
format disch_pac_n pacf_n.;
run;

proc freq data=mp.merge_all_2010_16;
title 'Conditions by PAC, 2010-2016';
tables (tkr_thr_drg sepsis_drg uti_drg chf_drg pneu_drg hipfx_drg)*DISCH_PAC_N;
run;

proc freq data=mp.merge_all_2010_16;
title 'Death within 30 days after discharge';
tables (DeadIn30Days)*DISCH_PAC_N;
run;


****** Create in Nursing Home in 100 days prior to hospitalization indicator;
*Merge with MDS data in order to find hospitalizations that have NH stay within prior 100 days;
proc sql;
create table merge_all_2010_16 as
select a.*, b.MDS_TRGT_DT1
from mp.merge_all_2010_16 as a
left join tempn.mds_prior_0916(rename=(MDS_TRGT_DT=MDS_TRGT_DT1)) as b  /*tempn.mds_prior_0916 - A combined data set of MDS2.0 and MDS 3,0 from 2009-2016*/
on a.bene_id=b.bene_id and 0 lt a.ADMSNDT-b.MDS_TRGT_DT1 le 100;
quit; *96,355,562;
proc sort data=merge_all_2010_16 nodupkey; by medpar_id; run; 

*Identify NH stays in prior 100 days;
data mp.merge_all_2010_16 (drop=MDS_TRGT_DT1);
set merge_all_2010_16;
if MDS_TRGT_DT1^=. then NH_Stay_Prior100=1; else NH_Stay_Prior100=0;
if DSTNTNCD^=3 and disch_pac_n=1 then Possible_Long_Term_Stay=1; else =0;
label NH_Stay_Prior100="Nursing Home Stay in Prior 100 Days" Possible_Long_Term_Stay="Possible Long Term Stay in SNF";
run;

ods rtf file='[PATH]/PAC_Destinations_1016_with_MA(No_Prior_NH).rtf';
proc freq data=mp.merge_all_2010_16;
title 'Frequency table of Post Acute Care, 2010-2016 (No Prior Nursing Home Stay)';
tables disch_pac_n*dschrg_year / norow;
where NH_Stay_Prior100=0;
run;
ods rtf close;

ods rtf file='[PATH]/PAC_Destinations_1016_with_MA(No_Long_Term).rtf';
proc freq data=mp.merge_all_2010_16;
title 'Frequency table of Post Acute Care, 2010-2016 (Exclude Possible Long Term Stay in SNF';
tables disch_pac_n*dschrg_year / norow;
where Possible_Long_Term_Stay=0;
run;
ods rtf close;

ods rtf file='[PATH]/PAC_Destinations_1016_with_MA(No_Prior_NH_and_Long_Term).rtf';
proc freq data=mp.merge_all_2010_16;
title 'Frequency table of Post Acute Care, 2010-2016 (Exclude Prior Nursing Home Stay and Possible Long Term Stay in SNF)';
tables disch_pac_n*dschrg_year / norow;
where Possible_Long_Term_Stay=0 & NH_Stay_Prior100=0;
run;
ods rtf close;


***** Get Readmission information;
proc sql;
create table Pac.readm2010_2016 as
select * from readm.hw_readm_0916_final
where ADMIT ge 18263 & DISCH+60 le 20819;
quit; *88,223,331;

proc sql;
create table Pac.merge_all_2010_16 as
select all.*, readm.*
from mp.merge_all_2010_16 as all
left join Pac.readm2010_2016 as readm
on all.BENE_ID=readm.HICNO and all.ADMSNDT>=readm.ADMIT and all.DSCHRGDT<=readm.DISCH;
quit; *69,391,104;

proc sort data=Pac.merge_all_2010_16 nodupkey; by medpar_id; run; *69,258,622 records;

proc freq data=Pac.merge_all_2010_16;
table RADM30*disch_pac_n;
table (hxinfection otherinfectious metacancer severecancer othercancer diabetes malnutrition liverdisease hematological alcohol 
psychological motordisfunction seizure chf cadcvd arrhythmias copd lungdisorder ondialysis ulcers septicemia metabolicdisorder 
irondeficiency cardiorespiratory renalfailure pancreaticdisease arthritis respiratordependence transplants coagulopathy hipfracture);
run;

*Check number of matched readmission indicators;
proc sql;
create table check_readm_matched as 
select HICNO from Pac.merge_all_2010_16
where not missing(HICNO);
quit; *67,997,615 (98.18%);


***** CREATE PAYMENT VARIABLES AND DAYS OF USE, ADDED 20160406;
* Read SNF data from MedPAR data 2010-2016;
proc sql;
create table MedPAR2010_16_SNF as
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2010(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF)) 
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') union all
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2011(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF)) 
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') union all
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2012(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF)) 
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') union all
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2013(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF))
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') union all
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2014(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF)) 
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') union all
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2015(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF))
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z') union all
select BENE_ID, ADMSNDT_SNF, DSCHRGDT_SNF, LOSCNT, UTIL_DAY, PMT_AMT_SNF, PRVDR_NUM, medpar_id from Medpar.Mp100mod_2016(rename=(ADMSNDT=ADMSNDT_SNF DSCHRGDT=DSCHRGDT_SNF PMT_AMT=PMT_AMT_SNF))
where substr(PRVDR_NUM,3,1) in ('5','6','U','W','Y','Z')
order by BENE_ID, ADMSNDT_SNF;
quit; *18,368,283 records;

data MedPAR2010_16_SNF_unique;
set MedPAR2010_16_SNF;
by BENE_ID ADMSNDT_SNF;
if first.ADMSNDT_SNF then output;
run; * 18,365,809 records;

data mp.MedPAR2010_16_SNF_unique;
set MedPAR2010_16_SNF_unique;
DSCHRGDT_SNF_pseudo=DSCHRGDT_SNF;
if DSCHRGDT_SNF eq . then DSCHRGDT_SNF_pseudo=ADMSNDT_SNF+UTIL_DAY;
run;

*Read Home Health Agency data from HHA data 2010-2016;
proc sql;
create table hha2010_16 as
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004952_2010 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004953_2010 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004953_2011 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004954_2011 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004954_2012 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004955_2012 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004955_2013 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_j_req004956_2013 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_2014 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_k_req007681_2015 union all
select BENE_ID, CLM_ID, PRVDR_NUM, CLM_FROM_DT, CLM_THRU_DT, CLM_PMT_AMT, CLM_HHA_TOT_VISIT_CNT from Hha.Hha_base_claims_k_req007681_2016
order by BENE_ID, CLM_FROM_DT;
quit; *15,824,521 records;

data mp.hha2010_16_unique;
set hha2010_16;
by BENE_ID CLM_FROM_DT;
if first.CLM_FROM_DT then output;
run; *14,613,272 records;


*Merge payment, utilization day count and MedPAR ID variables into 2010-2016 data set for SNF and HHA Fee-for-Service records;
proc sql;
create table merge_all_2010_16 as 
select a.*, b.DSCHRGDT_SNF_pseudo as DSCHRGDT_SNF_2, b.ADMSNDT_SNF as ADMSNDT_SNF_2,
       b.UTIL_DAY as UTIL_DAY_SNF, b.PMT_AMT_SNF, b.medpar_id as medpar_id_snf, 
       c.CLM_FROM_DT as ADMSNDT_HHA_2,c.CLM_HHA_TOT_VISIT_CNT as VISITCNT_HHA, c.CLM_PMT_AMT as PMT_AMT_HHA, c.CLM_ID as CLM_ID_HHA
from Pac.merge_all_2010_16 as a 
left join mp.MedPAR2010_16_SNF_unique as b on a.bene_id=b.bene_id and 0<=b.ADMSNDT_SNF-a.dschrgdt<=3 and a.disch_pac_n=1
left join mp.hha2010_16_unique as c	on a.bene_id=c.bene_id and 0<=c.CLM_FROM_DT-a.dschrgdt<=3 and a.disch_pac_n=3;
quit; *69,336,206 records;

*Calculate the absolute value of difference between admission dates in MDS versus SNF claim and OASIS versus HHA claim;
data merge_all_2010_16_2;
set merge_all_2010_16;
if disch_pac_n=1 then admsndt_diff=abs(ADMSNDT_SNF-ADMSNDT_SNF_2);
else if disch_pac_n=3 then admsndt_diff=abs(ADMSNDT_HHA-ADMSNDT_HHA_2);
run;

*Sort the data set by MedPAR ID and absolute value of difference;
proc sort data=merge_all_2010_16_2; by medpar_id admsndt_diff; run; 

*Keep the smallest difference for each MedPAR ID;
data Pac.merge_all_2010_16_2(drop=admsndt_diff ADMSNDT_SNF_2 DSCHRGDT_SNF_2 ADMSNDT_HHA_2);
set merge_all_2010_16_2;
by medpar_id admsndt_diff;
if first.medpar_id;
run; *69,258,622;

*Check the percentage of SNF/HHA records that could be matched to payment record - the percentage of successfully matched payment is a bit lower for SNF due to long-term care discharges;
ods rtf file="[PATH]/Matched_SNF_HHA_Claims(FFS).rtf";
title1 "Percentage of SNF Discharges with Matched SNF Claims";
proc sql;
select dschrg_year, count(disch_pac_n) as SNF_Dschrg label="SNF Discharges (Defined by MDS)" FORMAT = COMMA18., 
                    count(PMT_AMT_SNF) as PMT_AMT_SNF label="SNF Payments  (Defined by MedPAR)" FORMAT = COMMA18.,  
                    count(PMT_AMT_SNF)/count(disch_pac_n) as Matched_Pct label="Percent of Matched" FORMAT = PERCENT10.2 
from Pac.merge_all_2010_16_2 
where disch_pac_n=1 & FFS_enrollment_elig=1
group by dschrg_year;
quit;
title1;

title2 "Percentage of HHA Discharges with Matched HHA Claims";
proc sql;
select dschrg_year, count(disch_pac_n) as HHA_Dschrg label="HHA Discharges (Defined by OASIS)" FORMAT = COMMA18., 
                    count(PMT_AMT_HHA) as PMT_AMT_HHA label="HHA Payments (Defined by HHA Claim)" FORMAT = COMMA18., 
                    count(PMT_AMT_HHA)/count(disch_pac_n) as Matched_Pct label="Percent of Matched" FORMAT = PERCENT10.2 
from Pac.merge_all_2010_16_2
where disch_pac_n=3 & FFS_enrollment_elig=1
group by dschrg_year;
quit;
title2;
ods rtf close;


*Create payment and length of stay variables;
data Pac.merge_all_2010_16_2;
set Pac.merge_all_2010_16_2;
if DISCH_PAC_N eq 1 then do; PAC_DSCHRGDT=DSCHRGDT_SNF; PAC_ADMSNDT=ADMSNDT_SNF; PAC_PMT_AMT=PMT_AMT_SNF; end;
else if DISCH_PAC_N eq 2 then do; PAC_DSCHRGDT=DSCHRGDT_IRF; PAC_ADMSNDT=ADMSNDT_IRF; PAC_PMT_AMT=PMT_AMT_IRF; end;
else if DISCH_PAC_N eq 3 then do; PAC_DSCHRGDT=DSCHRGDT_HHA; PAC_ADMSNDT=ADMSNDT_HHA; PAC_PMT_AMT=PMT_AMT_HHA; end;
else if DISCH_PAC_N eq 4 then do; PAC_DSCHRGDT=DSCHRGDT_other; PAC_ADMSNDT=ADMSNDT_other; PAC_PMT_AMT=PMT_AMT_other; end;
else if DISCH_PAC_N eq 0 then do; PAC_DSCHRGDT=.; PAC_ADMSNDT=.; PAC_PMT_AMT=0; end;
if PMT_AMT lt 0 then neg_PMT=1; else neg_PMT=0;
if PAC_PMT_AMT lt 0 then neg_PAC_PMT=1; else neg_PAC_PMT=0;
/* if payment amount is less than 0: revise it to 0 */
PMT_AMT_PSEUDO = PMT_AMT; if neg_PMT=1 then PMT_AMT_PSEUDO=0;
PAC_PMT_AMT_PSEUDO = PAC_PMT_AMT; if neg_PAC_PMT=1 then PAC_PMT_AMT_PSEUDO=0;
if DISCH_PAC_N ne 0 then do;
	* within 60 days after hospital admission;
	if ADMSNDT+59 le DSCHRGDT then do; 
		Hosp_Days_60=60; PAC_Days_60=0; Hosp_PACDays_60=60;
		Hosp_Pmt_60=PMT_AMT_PSEUDO/(DSCHRGDT-ADMSNDT+1)*60; PAC_Pmt_60=0; Hosp_PACPmt_60=PMT_AMT_PSEUDO/(DSCHRGDT-ADMSNDT+1)*60; end;
	else if DSCHRGDT lt ADMSNDT+59 lt PAC_ADMSNDT then do;
		Hosp_Days_60=DSCHRGDT-ADMSNDT+1; PAC_Days_60=0; Hosp_PACDays_60=DSCHRGDT-ADMSNDT+1; 
		Hosp_Pmt_60=PMT_AMT_PSEUDO; PAC_Pmt_60=0; Hosp_PACPmt_60=PMT_AMT_PSEUDO; end;
	else if PAC_ADMSNDT le ADMSNDT+59 lt PAC_DSCHRGDT then do; 
		Hosp_Days_60=DSCHRGDT-ADMSNDT+1; PAC_Days_60=ADMSNDT+59-PAC_ADMSNDT+1;
		Hosp_PACDays_60=(DSCHRGDT-ADMSNDT+1)+(ADMSNDT+59-PAC_ADMSNDT+1); 
		Hosp_Pmt_60=PMT_AMT_PSEUDO; PAC_Pmt_60=PAC_PMT_AMT_PSEUDO/(PAC_DSCHRGDT-PAC_ADMSNDT+1)*(ADMSNDT+59-PAC_ADMSNDT+1); 
		Hosp_PACPmt_60=PMT_AMT_PSEUDO+PAC_PMT_AMT_PSEUDO/(PAC_DSCHRGDT-PAC_ADMSNDT+1)*(ADMSNDT+59-PAC_ADMSNDT+1); end;
	else if ADMSNDT+59 ge PAC_DSCHRGDT then do; 
		Hosp_Days_60=DSCHRGDT-ADMSNDT+1; PAC_Days_60=PAC_DSCHRGDT-PAC_ADMSNDT+1;
		Hosp_PACDays_60=(DSCHRGDT-ADMSNDT+1)+(PAC_DSCHRGDT-PAC_ADMSNDT+1);
		Hosp_Pmt_60=PMT_AMT_PSEUDO; PAC_Pmt_60=PAC_PMT_AMT_PSEUDO; Hosp_PACPmt_60=PMT_AMT_PSEUDO+PAC_PMT_AMT_PSEUDO; end;
	* within 30 days after PAC admission;
	if PAC_ADMSNDT+29 le PAC_DSCHRGDT then do;
		PACDays_30=30; PACPmt_30=PAC_PMT_AMT_PSEUDO/PACDays_30*30;
	end;
	else if PAC_ADMSNDT+29 gt PAC_DSCHRGDT then do;
		PACDays_30=PAC_DSCHRGDT-PAC_ADMSNDT+1; PACPmt_30=PAC_PMT_AMT_PSEUDO;
	end;
end;
else do;
	if ADMSNDT+59 le DSCHRGDT then do; Hosp_Days_60=60; Hosp_PACDays_60=60; 
		Hosp_Pmt_60=PMT_AMT_PSEUDO/(DSCHRGDT-ADMSNDT+1)*60; Hosp_PACPmt_60=PMT_AMT_PSEUDO/(DSCHRGDT-ADMSNDT+1)*60; end;
	else if ADMSNDT+59 gt DSCHRGDT then do; Hosp_Days_60=DSCHRGDT-ADMSNDT+1; Hosp_PACDays_60=DSCHRGDT-ADMSNDT+1;
		Hosp_Pmt_60=PMT_AMT_PSEUDO; Hosp_PACPmt_60=PMT_AMT_PSEUDO; end;
	PACPmt_30=0; PACDays_30=0; PAC_Pmt_60=0; PAC_Days_60=0;
format PAC_ADMSNDT PAC_DSCHRGDT ADMSNDT_SNF ADMSNDT_IRF DSCHRGDT_IRF DSCHRGDT_SNF date9.; 
end;
run; *69,258,622;

***** Check readmission rate and mortality rate, added 20161021;
*Calculate total payment within 60 days after hospital admission;
data temp.merge_all_2010_16_all_trans;
	set mp.MedPAR2010_16_SNF_unique (rename=(PRVDR_NUM=SNF_PRVDRNUM))
	mp.MedPAR2010_16_IRF_unique (rename=(PRVDR_NUM=IRF_PRVDRNUM))
	mp.hha2010_16_unique (rename=(CLM_FROM_DT=ADMSNDT_HHA CLM_THRU_DT=DSCHRGDT_HHA CLM_PMT_AMT=PMT_AMT_HHA PRVDR_NUM=HHA_PRVDRNUM))
	mp.other2010_16_unique
	mp.Merged2010_16(rename=(ADMSNDT=ADMSNDT_ACUTE DSCHRGDT=DSCHRGDT_ACUTE PMT_AMT=PMT_AMT_ACUTE PRVDR_NUM=ACUTE_PRVDRNUM));
run; *109,292,388;

data merge_all_2010_16_all_trans;
	set temp.merge_all_2010_16_all_trans(keep = BENE_ID ADMSNDT_SNF DSCHRGDT_SNF_pseudo PMT_AMT_SNF SNF_PRVDRNUM ADMSNDT_IRF
	DSCHRGDT_IRF PMT_AMT_IRF IRF_PRVDRNUM ADMSNDT_HHA DSCHRGDT_HHA PMT_AMT_HHA HHA_PRVDRNUM ADMSNDT_other DSCHRGDT_other
	other_PRVDRNUM PMT_AMT_other ADMSNDT_ACUTE DSCHRGDT_ACUTE PMT_AMT_ACUTE PMT_AMT_ACUTE);
	rename DSCHRGDT_SNF_pseudo=DSCHRGDT_SNF;
run;

proc sql;
create table temp.merge_all_2010_16_trans as
	select distinct main.BENE_ID, main.ADMSNDT, main.DSCHRGDT, main.PMT_AMT, main.PRVDR_NUM as HOSP_PRVDRNUM, post.*
	from mp.Merged2010_16 as main
	left join merge_all_2010_16_all_trans as post on main.BENE_ID=post.BENE_ID;
quit; *534,697,059;

*keep acute-pac bundle only if pac admission is within 60 days after hospital admission;
data temp.merge_all_2010_16_trans_2;
set temp.merge_all_2010_16_trans;
if 0 le ADMSNDT_SNF-ADMSNDT le 59 then gap_1=ADMSNDT_SNF-ADMSNDT; else gap_1=.;
if 0 le ADMSNDT_IRF-ADMSNDT le 59 then gap_2=ADMSNDT_IRF-ADMSNDT; else gap_2=.;
if 0 le ADMSNDT_HHA-ADMSNDT le 59 then gap_3=ADMSNDT_HHA-ADMSNDT; else gap_3=.;
if 0 le ADMSNDT_other-ADMSNDT le 59 then gap_4=ADMSNDT_other-ADMSNDT; else gap_4=.;
*We require lt instead of le to avoid bundles with two same discharges;
if 0 lt ADMSNDT_ACUTE-ADMSNDT le 59 then gap_5=ADMSNDT_ACUTE-ADMSNDT; else gap_5=.;
if gap_1=. & gap_2=. & gap_3=. & gap_4=. & gap_5=. then delete;
*There should be only 1 nonmissing variable the five variables in each line;
PMT_AMT_60_AFTER=min(PMT_AMT_SNF, PMT_AMT_IRF, PMT_AMT_HHA, PMT_AMT_other, PMT_AMT_ACUTE);
DSCHRGDT_60_AFTER=min(DSCHRGDT_SNF, DSCHRGDT_IRF, DSCHRGDT_HHA, DSCHRGDT_other, DSCHRGDT_ACUTE);
ADMSNDT_60_AFTER=min(ADMSNDT_SNF, ADMSNDT_IRF, ADMSNDT_HHA, ADMSNDT_other, ADMSNDT_ACUTE);
run; *54,608,599; 

proc sort data=temp.merge_all_2010_16_trans_2;
	by BENE_ID ADMSNDT DSCHRGDT;
run;

*Calculate each of pac and hospital payments within 60 days after hospital admission;
data temp.merge_all_2010_16_trans_3;
set temp.merge_all_2010_16_trans_2;
if DSCHRGDT_60_AFTER >= ADMSNDT+59 then Pmt_After_Hosp_60=PMT_AMT_60_AFTER/(DSCHRGDT_60_AFTER-ADMSNDT_60_AFTER+1)*(ADMSNDT+59-ADMSNDT_60_AFTER+1);
if DSCHRGDT_60_AFTER < ADMSNDT+59 then Pmt_After_Hosp_60=PMT_AMT_60_AFTER;
if Pmt_After_Hosp_60 < 0 then Pmt_After_Hosp_60 = 0;
DSCHRG_ID=BENE_ID||'_'||ADMSNDT||'_'||DSCHRGDT;
run; *54,608,599;

*Calculate the sum of pac and hospital payments for each hospital admission;
proc sql;
create table temp.merge_all_2010_16_trans_4 as
	select BENE_ID, ADMSNDT, DSCHRGDT, PMT_AMT, SUM(Pmt_After_Hosp_60) as Pmt_After_Hosp_60_sum, HOSP_PRVDRNUM, DSCHRGDT_60_AFTER, ADMSNDT_60_AFTER
	from temp.merge_all_2010_16_trans_3
	group by DSCHRG_ID;
quit;

proc sort data=temp.merge_all_2010_16_trans_4 NODUP;
	by BENE_ID ADMSNDT DSCHRGDT;
run; *54,608,121;

*Merge into the original dataset;
proc sql;
create table Pac.merge_all_2010_16_3 as
	select distinct main.*, payment.BENE_ID, payment.ADMSNDT, payment.DSCHRGDT, payment.HOSP_PRVDRNUM, payment.DSCHRGDT_60_AFTER, payment.ADMSNDT_60_AFTER, payment.Pmt_After_Hosp_60_sum
	from Pac.merge_all_2010_16_2 as main
	left join temp.merge_all_2010_16_trans_4 as payment
	on main.BENE_ID=payment.BENE_ID and main.ADMSNDT=payment.ADMSNDT and main.DSCHRGDT=payment.DSCHRGDT;
quit; *89,953,620;

data Pac.merge_all_2010_16_4(drop = ADMSNDT_60_AFTER DSCHRGDT_60_AFTER);
	set Pac.merge_all_2010_16_3;
	if Pmt_After_Hosp_60_sum =. then Total_Pmt_60 = Hosp_Pmt_60;
		else Total_Pmt_60=Hosp_Pmt_60+Pmt_After_Hosp_60_sum;
run; *89,953,620;

proc sort data=Pac.merge_all_2010_16_4 NODUP; by dschrg_year ; run;	*69,258,622;

proc sort data=Pac.merge_all_2010_16_4
	out=Pac.Merge_all_1016;
	by BENE_ID ADMSNDT;
run;

*Label variables in Pac.Merge_all_1016;
DATA Pac.Merge_all_1016;
	SET Pac.Merge_all_1016;
	if Pmt_After_Hosp_60_sum=. then Pmt_After_Hosp_60_sum=0;
	if DSTNTNCD in (41,42,50,51) then hospice=1;
    else if DSTNTNCD not in (41,42,50,51) and DSTNTNCD ne . then  hospice=0;
    else hospice=.;
	LABEL
		gap_snf = 'Gap between hospital discharge date and SNF admission date (maximum 3)'
		gap_irf = 'Gap between hospital discharge date and IRF admission date (maximum 3)'
		gap_hha = 'Gap between hospital discharge date and HHA admission date (maximum 3)'
		gap_other = 'Gap between hospital discharge date and admission date of other providers (maximum 3)'
		disch_pac_n = 'Discharge destination'
		gap = 'Gap between hospital discharge date and admission date of PAC or other providers (99 when gap bigger than 3)'
		dschrgdt_snf_pseudo = 'Inferred discharge date of SNF based on admission date and LOS'
		PAC_DSCHRGDT = 'discharge date of PAC or other providers'
		PAC_ADMSNDT = 'admission date of PAC or other providers'
		PAC_PMT_AMT = 'payment amount to PAC or other providers'
		neg_PMT = '1=the payment to hospitals is less than 0'
		neg_PAC_PMT = '1=the payment to PAC or other providers'
		PMT_AMT_pseudo = 'Payment amount to hospitals, 0 if payment is negative'
		PAC_PMT_AMT_pseudo = 'Payment amount to PAC or other providers, 0 if payment is negative'
		Hosp_PACDays_60 = 'Number of days in hospital and first PAC within 60 days after hospital admission'
		Hosp_PACPmt_60 = 'Total payment amount to hospitals and first PAC within 60 days after hospital admission'
		Hosp_Days_60 = 'Number of days in hospital within 60 days after hospital admission'
		PAC_Days_60 = 'Number of days in first PAC within 60 days after hospital admission'
		Hosp_Pmt_60 = 'Payment amount to hospital within 60 days after hospital admission'
		Pac_Pmt_60 = 'Payment amount to first PAC within 60 days after hospital admission'
		PACDays_30 = 'Number of days in PAC within 30 days after PAC admission'
		PACPmt_30 = 'Payment to PAC within 30 days after PAC admission'
		Pmt_After_Hosp_60_sum = 'Payment amount to all providers after discharge within 60 days after hospital admission'
		Total_Pmt_60 = 'Payment amount to all providers within 60 days after hospital admission'
		hospice="Hospice Indicator";
run;





/*********************************************************************************
 Step 6: Merge in variables from POS files, HSA files, HCRIS files and other data
         source and create a final analytical data set for statistical analysis 
*********************************************************************************/
*Vertically combine the ADL data sets of SNF, IRF and HHA in order to merge ADL variables into PAC data set;
data tempn.snf_irf_hha_adl_2010_16;
set  pac.snf_ADL_disch_5day_n tempn.hha_ADL_disch_start 
     PAC.irf_medpar_ADL(rename=(
	 BATHG_ADMSN=ADL_bath_1 DRSG_ADMSN=ADL_dress_1 TOILTING_ADMSN=ADL_toilet_1 BED_CHR_WC_ADMSN=ADL_trans_1 EATG_ADMSN=ADL_eating_1 SPHNCTR_ADMSN=ADL_conti_1
     BATHG_DSCHRG=ADL_bath_2 DRSG_DSCHRG=ADL_dress_2 TOILTING_DSCHRG=ADL_toilet_2 BED_CHR_WC_DSCHRG=ADL_trans_2 EATG_DSCHRG=ADL_eating_2 SPHNCTR_DSCHRG=ADL_conti_2 
     BATHG_improved=ADL_bath_improved DRSG_improved=ADL_dress_improved TOILTING_improved=ADL_toilet_improved BED_CHR_WC_improved=ADL_trans_improved EATG_improved=ADL_eating_improved 
     SPHNCTR_improved=ADL_conti_improved));
	 keep bene_id medpar_id ADL:;
run; *14,702,915;

*Merge ADL variables into PAC data set;
proc sql;
create table tempn.pac_all_final as 
select a.*, b.* 
from Pac.Merge_all_1016 as a left join tempn.snf_irf_hha_adl_2010_16 as b
on a.medpar_id=b.medpar_id;
quit; *69,258,622;

*Check the missing values of ADL variables and indicator of successful discharge to community;
proc means data=tempn.pac_all_final n nmiss;
var ADL_bath_1 ADL_dress_1 ADL_toilet_1 ADL_trans_1 ADL_eating_1 ADL_conti_1
    ADL_bath_2 ADL_dress_2 ADL_toilet_2 ADL_trans_2 ADL_eating_2 ADL_conti_2 
    ADL_bath_improved ADL_dress_improved ADL_toilet_improved ADL_trans_improved ADL_eating_improved ADL_conti_improved ADL_total_improved
	ADL_total_1 ADL_total_2 ADL_total_d;
class disch_pac_n;
where hospice^=1;
run;

*1. Create an unique identifier (pac_unique) for each MedPar claim and, 
 2. Create new identifiers for five most common DRGs,
 3. Put labels for ADL variables and indicator for successful discharge to community;
data pac_all_final_2;
set tempn.pac_all_final;
*Exclude hospice records;
where hospice^=1;
if drg_cd=470 then tkr_thr_drg_new=1;else tkr_thr_drg_new=0;
if drg_cd=871 then sepsis_drg_new=1; else sepsis_drg_new=0;
if drg_cd=690 then uti_drg_new=1; else uti_drg_new=0;
if drg_cd=291 then chf_drg_new=1;else chf_drg_new=0;
if drg_cd=481 then hipfx_drg_new=1;else hipfx_drg_new=0;
label   ADL_bath_1="ADL Bathing Score at Admission" ADL_dress_1="ADL Dressing Score at Admission" ADL_toilet_1="ADL Toilet Score at Admission" 
        ADL_trans_1="ADL Transfer Score at Admission" ADL_eating_1="ADL Eating Score at Admission" ADL_conti_1="ADL Continence Score at Admission"
        ADL_bath_2="ADL Bathing Score at Discharge" ADL_dress_2="ADL Dressing Score at Discharge" ADL_toilet_2="ADL Toilet Score at Discharge" 
        ADL_trans_2="ADL Transfer Score at Discharge" ADL_eating_2="ADL Eating Score at Discharge" ADL_conti_2="ADL Continence Score at Discharge" 
        ADL_bath_improved="ADL Bathing Score Improvement" ADL_dress_improved="ADL Dressing Score Improvement" ADL_toilet_improved="ADL Toilet Score Improvement" 
        ADL_trans_improved="ADL Transfer Score Improvement" ADL_eating_improved="ADL Eating Score Improvement" ADL_conti_improved="ADL Continence Score Improvement" ADL_total_improved="ADL Total Score Improvement"
        ADL_total_1="ADL Total Score at Admission" ADL_total_2="ADL Total Score at Discharge" ADL_total_d="ADL Total Score Difference between Admission and Discharge" 
        tkr_thr_drg_new="Major Joint Replacement" sepsis_drg_new="Sepsis or Septicemia" uti_drg_new="Kidney & Urinary Tract Infections" chf_drg_new="Heart Failure & Shock" hipfx_drg_new="Hip & Pelvis Fracture";
run;  *66,967,023 records;

* Merge the analytical data set with POS file to get the zip code, number of beds, profit status and teaching status of each hospital;
* Set up year variable for POS files ;
data POS.pos2010; set POS.pos2010_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2010;  run;
data POS.pos2011; set POS.pos2011_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2011;  run;
data POS.pos2012; set POS.pos2012_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2012;  run;
data POS.pos2013; set POS.pos2013_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2013;  run;
data POS.pos2014; set POS.pos2014_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2014;  run;
data POS.pos2015; set POS.pos2015_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2015;  run;
data POS.pos2016; set POS.pos2016_orig(keep=zip_cd prvdr_ctgry_cd GNRL_CNTL_TYPE_CD  crtfd_bed_cnt mdcl_schl_afltn_cd prvdr_num state_cd); year_pos=2016;  run;

* Vertically combine 7-year POS files;
data POS.pos2010_2016;
set POS.pos2010 POS.pos2011 POS.pos2012 POS.pos2013 POS.pos2014 POS.pos2015 POS.pos2016;
run; *959,246 records;

proc sort data=POS.pos2010_2016; by prvdr_num descending year_pos;run; 
data POS.pos2010_2016_nodup;
set  POS.pos2010_2016;
by prvdr_num;
if first.prvdr_num;
run; *151,555 records;

proc sql;create table tempn.pos_not_found as select distinct hosp_prvdrnum from pac_all_final_2 where hosp_prvdrnum not in (select prvdr_num from POS.pos2010_2016);quit; 
*1,214 hospitals from analytcial data sets don't exist in POS file;
proc sql;create table tempn.pos_not_found_patient as select * from pac_all_final_2 where hosp_prvdrnum not in (select prvdr_num from POS.pos2010_2016);quit;
*71,166 MedPAR records have provider numbers that don't exist in POS file;

Proc sql;
create table tempn.pac_all_final_2 as 
select a.*, b.*
from pac_all_final_2 as a
inner join 
POS.pos2010_2016_nodup as b
on a.hosp_prvdrnum=b.prvdr_num;
quit; *66,895,857 records;

*Merge analytical data set with 7-year HSA file;
Proc sql;
create table pac_all_final_3 as 
select a.*, b.hsanum, b.hsacity, b.hsastate, b.hrrnum, b.hrrcity, b.hrrstate
from tempn.pac_all_final_2 as a
left join 
tempn.hsa_zip_cw_1016 as b
on a.zip_cd=b.zip and a.dschrg_year=b.year_hsa;
quit; *66,895,857 records; 

*Check the number of records being merged successfully;
proc sql;
create table check_merge as 
select hrrnum from pac_all_final_3 where hrrnum ^= .;
quit; *66,600,401 records / 99.56% successful rate;

*Collapse the data set to hospital-level and exclude the hospitals with missing hrr number;
proc sql;
create table pac_hosp_pos_hrr as 
select distinct hosp_prvdrnum, crtfd_bed_cnt, hrrnum from pac_all_final_3
where hrrnum is not missing;
quit; *5,080 records;

*Calculate HHI index;
proc sql;
create table pac_hosp_pos_hrr_2 as
select *,sum(crtfd_bed_cnt) as crtfd_bed_cnt_sum from pac_hosp_pos_hrr
group by hrrnum;
quit;

data pac_hosp_pos_hrr_3;
set pac_hosp_pos_hrr_2;
crtfd_bed_cnt_ms_sq=(crtfd_bed_cnt/crtfd_bed_cnt_sum)**2 ; 
run;

proc sql;
create table pac_all_pos_hrr_4 as
select *,sum(crtfd_bed_cnt_ms_sq) as hhi_hrr from pac_hosp_pos_hrr_3
group by hrrnum;
quit;

*Merge the HHI index into the patient-level data set;
proc sql;
create table pac_all_final_4 as
select a.*, b.crtfd_bed_cnt_sum, b.crtfd_bed_cnt_ms_sq, b.hhi_hrr from 
pac_all_final_3 as a left join pac_all_pos_hrr_4 as b
on a.hosp_prvdrnum=b.hosp_prvdrnum and a.hrrnum=b.hrrnum;
quit; *66,895,857;

*Creating dichotomous indicators for profit status, teaching hospital, large hospital and competitive market status;
data pac_all_final_5(compress=binary);
set pac_all_final_4 tempn.pos_not_found_patient;
    * Create hospital and market characteristics indicators;
	if GNRL_CNTL_TYPE_CD in (4,9) then for_profit=1;
	else if GNRL_CNTL_TYPE_CD in (1,2,3,5,6,7,8,10) then for_profit=0;
	if mdcl_schl_afltn_cd in (1,2,3) then teaching_hosp=1 ;
	else if  mdcl_schl_afltn_cd=4 then teaching_hosp=0 ;
	if 0 le crtfd_bed_cnt le 250 then large_hosp=0;
	else if crtfd_bed_cnt gt 250 then large_hosp=1;
	else if crtfd_bed_cnt=. then large_hosp=.;
	if 0 le hhi_hrr le 0.15 then comp_mkt=1;
	else if hhi_hrr gt 0.15 then comp_mkt=0;
	else if hhi_hrr=. then comp_mkt=.;
    * Create the severity of illness indicator by summing up comorbidities;
	SOI=sum(of hxinfection--HipFracture);
	if SOI>=6 then Risk="High";
	if 0<=SOI<6 then Risk="Low";
    * Create discharge destination dummy variables;
	if  disch_pac_n=0 then HOME=1; else HOME=0;
	if 	disch_pac_n in (1,2,3) then PAC=1; else PAC=0;
	if  disch_pac_n=1 then SNF=1; else SNF=0;
	if  disch_pac_n=2 then IRF=1; else IRF=0;
	if  disch_pac_n=3 then HHA=1; else HHA=0;
label teaching_hosp="Teaching Hospital" for_profit="For Profit Hospital" hhi_hrr="HHI Index" large_hosp="Large Hospital" 
      comp_mkt="Competitive Market" DSCHRG_YEAR="Discharge Year" DSCHRG_MONTH="Discharge Month" DSCHRG_Quarter="Discharge Quarter" 
      SOI="Severity of Illness";
run; *66,967,023 records;

*Check if the dichotomus variables are created as the way we expected;
proc freq data=pac_all_final_5;
tables (large_hosp comp_mkt for_profit teaching_hosp);
run;

proc sql;
create table tempn.pac_all_final_3 as 
select a.*, b.*
from pac_all_final_5 as a left join tempn.dn100mod2010_2016_dual_status as b
on a.bene_id=b.bene_id and a.DSCHRG_YEAR=b.RFRNC_YR;
quit;

data tempn.pac_all_final_4 (drop=RFRNC_YR dual_stus_cd:);
set tempn.pac_all_final_3;
array dual_cd{12} dual_stus_cd_01-dual_stus_cd_12;
do i=1 to 12;
	if month(dschrgdt)=i then dual_stus_cd=dual_cd{i};
end;
if dual_stus_cd in ("02","04","08") then dual_stus=1; else dual_stus=0;
if dual_stus_cd="99" then dual_stus=.;
label dual_stus="Dual Eligible Status";
run;

/*****************************************************************************************************************
 Calculate: 1)distance to closest SNF within same HSA
            2)distance to closest IRF within same HSA
            3)distance to closest HHA within same HSA
*****************************************************************************************************************/ 
*Check the number of SNF/IRF/HHA which are not found in POS file;
proc sql;create table pos_not_found_snf as select distinct prvdrnum_snf from tempn.pac_all_final_4 where prvdrnum_snf not in (select prvdr_num from POS.pos2010_2016_nodup) and snf=1;quit; 
*1,384 SNFs;
proc sql;create table tempn.pos_not_found_snf as select * from tempn.pac_all_final_4 where prvdrnum_snf in (select prvdrnum_snf from pos_not_found_snf) and snf=1;quit; 
*714,694 SNF discharges (4.3% of total);
proc sql;create table pos_not_found_irf as select distinct prvdrnum_irf from tempn.pac_all_final_4 where prvdrnum_irf not in (select prvdr_num from POS.pos2010_2016_nodup) and irf=1;quit; 
* 1 IRF;
proc sql;create table tempn.pos_not_found_irf as select * from tempn.pac_all_final_4 where prvdrnum_irf in (select prvdrnum_irf from pos_not_found_irf) and irf=1;quit; 
*66 IRF discharges;
proc sql;create table pos_not_found_hha as select distinct prvdrnum_hha from tempn.pac_all_final_4 where prvdrnum_hha not in (select prvdr_num from POS.pos2010_2016_nodup) and hha=1;quit; 
*274 HHAs;
proc sql;create table tempn.pos_not_found_hha as select * from tempn.pac_all_final_4 where prvdrnum_hha in (select prvdrnum_hha from pos_not_found_hha) and hha=1;quit; 
*30,898 HHA discharges (0.38% of total);
proc sql;create table tempn.pos_no_zipcode as select * from POS.pos2010_2016_nodup where zip_cd="";quit;  *270;


*Merge in SNF state code and facility ID for SNF records without valid Medicare provider number;
proc sql;
create table tempn.pos_not_found_snf_2 as
select a.*, b.state_cd as state_cd_snf, b.fac_prvdr_intrnl_id as fac_prvdr_intrnl_id_snf
from tempn.pos_not_found_snf as a
left join tempn.mds_2010_16_fac_info as b
on a.bene_id=b.bene_id and a.admsndt_snf=b.MDS_ENTRY_DT;
quit; *714,844;

proc sort data=tempn.pos_not_found_snf_2 nodupkey; by medpar_id; run; *714,694;

*Merge with SNF provider number-facility ID crosswalk to get valid SNF provider number;
proc sql;
create table tempn.pos_not_found_snf_3 as
select a.*, b.mcare_id
from tempn.pos_not_found_snf_2 as a
left join tempn.mds_fac_mcare_10_14_1516 as b
on a.state_cd_snf=b.state_cd and a.fac_prvdr_intrnl_id_snf=b.fac_prvdr_intrnl_id and a.dschrg_year=b.year;
quit; *714,694;

proc sql;
create table tempn.pac_all_final_5 as 
select a.*, b.mcare_id 
from tempn.pac_all_final_4 as a 
left join tempn.pos_not_found_snf_3 as b
on a.medpar_id=b.medpar_id;
quit; *66,967,023;

data tempn.pac_all_final_5(drop=mcare_id);
set tempn.pac_all_final_5;
if mcare_id^="" then prvdrnum_snf=mcare_id;
run;

proc sql;
create table pos_not_found_snf as 
select prvdrnum_snf from tempn.pac_all_final_5 where prvdrnum_snf not in (select prvdr_num from POS.pos2010_2016_nodup) and snf=1;
quit;*101,554 (0.61% of all SNF discharges); 

proc sql;
create table pos_not_found_snf_unique as 
select distinct prvdrnum_snf_new_2 from tempn.pac_all_final_5 where prvdrnum_snf not in (select prvdr_num from POS.pos2010_2016_nodup) and snf=1;
quit; *1,103-->6.19% of all 17,818 unique SNF provider numbers;

*Merge with POS file to get the zip code of SNF/IRF/HHA;
Proc sql;
create table pac_all_final_6 as 
select a.*, b.zip_cd as snf_zipcd, b.state_cd as snf_state_cd, c.zip_cd as irf_zipcd, c.state_cd as irf_state_cd, d.zip_cd as hha_zipcd, d.state_cd as hha_state_cd, e.state_cd as hosp_state_cd
from tempn.pac_all_final_5 as a
left join POS.pos2010_2016_nodup as b on a.prvdrnum_snf=b.prvdr_num
left join POS.pos2010_2016_nodup as c on a.prvdrnum_irf=c.prvdr_num
left join POS.pos2010_2016_nodup as d on a.prvdrnum_hha=d.prvdr_num
left join POS.pos2010_2016_nodup as e on a.hosp_prvdrnum=e.prvdr_num;
quit;

*Check the percentage of PAC records that have a matched zip code;
proc sql;create table snf_zipcode as select snf_zipcd from pac_all_final_6 where snf_zipcd^="" and snf=1;quit; *16,473,140 records (99.39%);
proc sql;create table irf_zipcode as select irf_zipcd from pac_all_final_6 where irf_zipcd^="" and irf=1;quit; *2,086,889 records (99.99%);
proc sql;create table hha_zipcode as select hha_zipcd from pac_all_final_6 where hha_zipcd^="" and hha=1;quit; *8,042,726 records (99.62%);	 
proc sql;create table hosp_statecode as select hosp_state_cd from pac_all_final_6 where hosp_state_cd^="";quit; *66,895,857 records (99.89%);


Proc sql;
create table pac_all_final_7 as 
select a.*, b.LONGDEG as LONGDEG_BENE, b.LATDEG as LATDEG_BENE, b.statecode as STATE_CD_BENE
from pac_all_final_6 as a
left join zip.Zipcode_1016 as b on a.bene_zip=b.zip_char and a.DSCHRG_YEAR=b.year;
quit;*66,967,023;

data tempn.pac_all_final_6;
set pac_all_final_7 ;
where STATE_CD_BENE not in ("FM", "GU", "MH", "MP", "PR", "PW", "VI") and hosp_state_cd not in ("FM", "GU", "MH", "MP", "PR", "PW", "VI") and 
      snf_state_cd  not in ("FM", "GU", "MH", "MP", "PR", "PW", "VI") and irf_state_cd not in  ("FM", "GU", "MH", "MP", "PR", "PW", "VI") and 
	  hha_state_cd  not in ("FM", "GU", "MH", "MP", "PR", "PW", "VI");
run;  *66,659,096 records (99.54%);


*Merge with HSA file to get the hsa/hrr number for each beneficiary's zip code;
Proc sql;
create table pac_all_final_8 as 
select a.*, b.hsanum as hsanum_bene, b.hrrnum as hrrnum_bene
from tempn.pac_all_final_6 as a left join tempn.hsa_zip_cw_1016 as b
on a.bene_zip=b.zip and a.DSCHRG_YEAR=b.year_hsa;
quit; *66,659,096 records;

*Collapse the beneficiaries' records down to zipcode-year level (HSA could change over years);
Proc sql;
create table tempn.pac_all_zip_level as 
select distinct bene_zip, DSCHRG_YEAR, STATE_CD_BENE, LONGDEG_BENE, LATDEG_BENE, hsanum_bene, hrrnum_bene from pac_all_final_8 where bene_zip^="";
quit; *267,081 records;

data tempn.pac_all_zip_level_2;
set tempn.pac_all_zip_level;
where LONGDEG_BENE^=. and LATDEG_BENE^=. and hsanum_bene^=.;
run; *262,848 records (98.42%);

*Get a subset of SNF/IRF/HHA information from analytical data set;
proc sql;create table snf as select distinct prvdrnum_snf as prvdrnum, snf_zipcd as zipcd, DSCHRG_YEAR, disch_pac_n from pac_all_final_8 where snf=1;quit; *111,608 records;
proc sql;create table irf as select distinct prvdrnum_irf as prvdrnum, irf_zipcd as zipcd, DSCHRG_YEAR, disch_pac_n from pac_all_final_8 where irf=1;quit; *7,940 records;
proc sql;create table hha as select distinct prvdrnum_hha as prvdrnum, hha_zipcd as zipcd, DSCHRG_YEAR, disch_pac_n from pac_all_final_8 where hha=1;quit; *71,850 records;
data pac;set snf irf hha;run; *191,398 records;

*Merge with HSA file to get the hsa/hrr number for each SNF/IRF/HHA;
Proc sql;
create table tempn.pac_hsa as 
select a.*, b.hsanum, b.hsastate, b.hrrnum, b.hrrstate
from pac as a
left join 
tempn.hsa_zip_cw_1016 as b
on a.zipcd=b.zip and a.DSCHRG_YEAR=b.year_hsa;
quit;  *191,398 records;

*Merge with zipcode data set to get longitude and latitude information for each SNF/IRF/HHA;
*Zip code data set contains longitude, latitude, state abbreviation and calendar year for each zip code. 
*The raw zip code files are downed from SAS Maps Online: http://support.sas.com/rnd/datavisualization/mapsonline/html/misc.html;
Proc sql;
create table tempn.pac_long_lat as 
select a.*, b.LONGDEG, b.LATDEG
from tempn.pac_hsa as a left join zip.Zipcode_1016 as b on a.zipcd=b.zip_char and a.DSCHRG_YEAR=b.year;
quit; 

data tempn.pac_long_lat_2;
set tempn.pac_long_lat;
where zipcd^="" and LONGDEG^=. and LATDEG^=. and hsanum^=.;
run; *189,151 records (98.83%);

proc sql;
create table tempn.pac_all_distance as 
select a.* , b.disch_pac_n, b.LONGDEG, b.LATDEG, b.zipcd from 
tempn.pac_all_zip_level_2 as a left join tempn.pac_long_lat_2 as b on a.hsanum_bene=b.hsanum and a.DSCHRG_YEAR=b.DSCHRG_YEAR;
quit; *6,498,757 records;

proc sql;create table check_hsa_march_1 as select disch_pac_n from tempn.pac_all_distance where disch_pac_n=.;quit; *3,477 records (1.84% unmatched);

data tempn.pac_all_distance_2;
set tempn.pac_all_distance;
* Replace the "0.000000" longitude and latitude for several special beneficiary zip codes (i.e. census-designated place) with their actual longitude and latitude found from US Census Bureau website; 
* Convert decimal degrees to radians;
LONG_BENE = atan(1)/45 * LONGDEG_BENE;
LONG = atan(1)/45 * LONGDEG;
LAT_BENE = atan(1)/45 * LATDEG_BENE;
LAT = atan(1)/45 * LATDEG;
if bene_zip=zipcd then dist=0; 
else do; 
Distance = 3949.99 * arcos(sin(LAT_BENE) * sin(LAT) + cos(LAT_BENE) * cos(LAT) * cos(LONG_BENE - LONG));
dist=round(distance,0.01);
end;
where disch_pac_n^=.;
run; 

data tempn.pac_all_distance_3;
set tempn.pac_all_distance_2;
where LONGDEG_BENE^=0.000000 and LATDEG_BENE^=0.000000 and LONGDEG^=0.000000 and LATDEG^=0.000000;
run;*6,495,140 recors;

proc sort data=tempn.pac_all_distance_3;
by bene_zip DSCHRG_YEAR disch_pac_n dist;
run;

data tempn.pac_all_distance_4;
set tempn.pac_all_distance_3;
by bene_zip DSCHRG_YEAR disch_pac_n dist;
if first.disch_pac_n;
run; *613,232 records;

proc sql;create table check_1 as select distinct bene_zip, DSCHRG_YEAR from pac_all_final_8;quit; *267,088; 
proc sql;create table check_2 as select distinct bene_zip, DSCHRG_YEAR from tempn.pac_all_distance_4;quit;  
*259,364-->97.11% of records in analytical data set should have distance to at least one PAC;

proc transpose data=tempn.pac_all_distance_4 out=tempn.pac_all_distance_5 suffix=_Dist_hsa;
var  dist;
by 	 bene_zip DSCHRG_YEAR;
id 	 disch_pac_n;
run; *259,364 records --> no duplicate;

data tempn.pac_all_distance_6;
retain bene_zip  SNF_Dist_Hsa IRF_Dist_Hsa HHA_Dist_Hsa dd_hhasnf_Hsa;
set  tempn.pac_all_distance_5;
dd_hhasnf_Hsa=HHA_Dist_Hsa-SNF_Dist_Hsa;
label SNF_Dist_Hsa="Distance to Nearest SNF within HSA" IRF_Dist_Hsa="Distance to Nearest IRF within HSA" 
      HHA_Dist_Hsa="Distance to Nearest HHA within HSA" dd_hhasnf_Hsa="Differential Distance (HHA-SNF) within HSA";
run;

*Merge closest SNF/IRF/HHA distance back into the analytical data set;
Proc sql;
create table tempn.pac_all_final_7 as 
select a.*, b.SNF_Dist_Hsa, b.IRF_Dist_Hsa, b.HHA_Dist_Hsa, b.dd_hhasnf_Hsa
from pac_all_final_8 as a left join tempn.pac_all_distance_6  as b
on a.bene_zip=b.bene_zip and a.DSCHRG_YEAR=b.DSCHRG_YEAR;
quit; *66,659,096 records;


/*****************************************************************************************************************
 Calculate: 1)distance to closest SNF within same HRR
            2)distance to closest IRF within same HRR
            3)distance to closest HHA within same HRR
*****************************************************************************************************************/ 
proc sql;
create table tempn.pac_all_distance_hrr as 
select a.* , b.disch_pac_n, b.LONGDEG, b.LATDEG, b.zipcd from 
tempn.pac_all_zip_level_2 as a left join tempn.pac_long_lat_2 as b on a.hrrnum_bene=b.hrrnum and a.DSCHRG_YEAR=b.DSCHRG_YEAR;
quit; *39,140,845;

proc sql;create table check_hrr_march as select disch_pac_n from tempn.pac_all_distance_hrr where disch_pac_n=.;quit; * 0 --> 100% matched;

data tempn.pac_all_distance_hrr_2;
set tempn.pac_all_distance_hrr;
*Replace the "0.000000" longitude and latitude for several special beneficiary zip codes (i.e. census-designated place) with their actual longitude and latitude found from US Census Bureau website; 
*Convert decimal degrees to radians;
LONG_BENE = atan(1)/45 * LONGDEG_BENE;
LONG = atan(1)/45 * LONGDEG;
LAT_BENE = atan(1)/45 * LATDEG_BENE;
LAT = atan(1)/45 * LATDEG;
if bene_zip=zipcd then dist=0; 
else do; 
Distance = 3949.99 * arcos(sin(LAT_BENE) * sin(LAT) + cos(LAT_BENE) * cos(LAT) * cos(LONG_BENE - LONG));
dist=round(distance,0.01);
end;
run; *39,140,845;

data tempn.pac_all_distance_hrr_3;
set tempn.pac_all_distance_hrr_2;
where LONGDEG_BENE^=0.000000 and LATDEG_BENE^=0.000000 and LONGDEG^=0.000000 and LATDEG^=0.000000;
run; *39,140,207;

proc sort data=tempn.pac_all_distance_hrr_3;
by bene_zip DSCHRG_YEAR disch_pac_n dist;
run;

data tempn.pac_all_distance_hrr_4;
set tempn.pac_all_distance_hrr_3;
by bene_zip DSCHRG_YEAR disch_pac_n dist;
if first.disch_pac_n;
run; *783,866;

proc sql;create table check_1 as select distinct bene_zip, DSCHRG_YEAR from tempn.pac_all_final_7;quit; *267,088; 
proc sql;create table check_2 as select distinct bene_zip, DSCHRG_YEAR from tempn.pac_all_distance_hrr_4;quit;  
*262,841 --> 98.41% of records in analytical data set should have distance to at least one PAC within HRR;

proc transpose data=tempn.pac_all_distance_hrr_4 out=tempn.pac_all_distance_hrr_5 suffix=_Dist_HRR;
var  dist;
by 	 bene_zip DSCHRG_YEAR;
id 	 disch_pac_n;
run; *262,841 records --> no duplicate;

data tempn.pac_all_distance_hrr_6;
retain bene_zip SNF_Dist_Hrr IRF_Dist_Hrr HHA_Dist_Hrr DD_HHASNF_HRR;
set tempn.pac_all_distance_hrr_5;
DD_HHASNF_HRR=HHA_Dist_HRR-SNF_Dist_HRR;
label SNF_Dist_HRR="Distance to Nearest SNF within HRR" IRF_Dist_HRR="Distance to Nearest IRF within HRR" 
      HHA_Dist_HRR="Distance to Nearest HHA within HRR" DD_HHASNF_HRR="Differential Distance (HHA-SNF) within HRR";
run;

*Merge closest SNF/IRF/HHA distance back into the analytical data set;
Proc sql;
create table tempn.pac_all_final_8 as 
select a.*, b.SNF_Dist_HRR, b.IRF_Dist_HRR, b.HHA_Dist_HRR, b.DD_HHASNF_HRR
from tempn.pac_all_final_7 as a left join tempn.pac_all_distance_hrr_6  as b
on a.bene_zip=b.bene_zip and a.DSCHRG_YEAR=b.DSCHRG_YEAR;
quit; *66,659,096;

*Create data summary of distance to closest SNF/IRF/HHA and differential distance for both bene_zip-discharge year level and discharge level (HRR);
ods rtf file="[PATH]/Summary_Distance.rtf" startpage=no;;
title1 "Summary of Distance to Nearest PAC within HSA and HRR";
proc means data=tempn.pac_all_final_8  n nmiss mean median std min max maxdec=2;
var SNF_Dist_HSA IRF_Dist_HSA HHA_Dist_HSA DD_HHASNF_HSA SNF_Dist_Hrr IRF_Dist_Hrr HHA_Dist_Hrr DD_HHASNF_HRR;
run;
title1;
ods rtf close; 
*Maximum value zip code: Adak, formerly Adak Station, is a town located on Adak Island, in the Aleutians West Census Area, Alaska, United States;

/*****************************************************************************************************************
 Calculate: 1)distance to the hospital which patient went to
            2)distance to closest hospital within HRR
*****************************************************************************************************************/ 
proc sql;
create table tempn.distance_to_hosp as 
select a.*, b.LONGDEG as hosp_longdeg, b.LATDEG as hosp_latdeg from 
tempn.pac_all_final_8 as a left join zip.Zipcode_1016 as b 
on a.zip_cd=b.zip_char and a.DSCHRG_YEAR=b.year;
quit; *66,659,096;

data tempn.distance_to_hosp_2;
set tempn.distance_to_hosp;
*Replace the "0.000000" longitude and latitude for several special beneficiary zip codes (i.e. census-designated place) with their actual longitude and latitude found from US Census Bureau website; 
*Convert decimal degrees to radians;
LONG_BENE = atan(1)/45 * LONGDEG_BENE;
hosp_LONG = atan(1)/45 * hosp_LONGDEG;
LAT_BENE = atan(1)/45 * LATDEG_BENE;
hosp_LAT = atan(1)/45 * hosp_LATDEG;
if bene_zip=zip_cd then hosp_dist=0; 
else if LONGDEG_BENE=0.000000 or LONGDEG_BENE=. or LATDEG_BENE=0.000000 or LATDEG_BENE=. or 
        hosp_LONGDEG=0.000000 or hosp_LONGDEG=. or hosp_LATDEG=0.000000 or hosp_LATDEG=. then hosp_dist=.;
else do; 
Distance = 3949.99 * arcos(sin(LAT_BENE) * sin(hosp_LAT) + cos(LAT_BENE) * cos(hosp_LAT) * cos(LONG_BENE - hosp_LONG));
Hosp_Dist=round(distance,0.01);
end;
label Hosp_Dist="Distance to Hospital";
run;  *66,659,096;

proc sql;
create table tempn.distance_bene as 
select distinct bene_zip, dschrg_year, hrrnum_bene , LONG_BENE, LAT_BENE from tempn.distance_to_hosp_2
where LONGDEG_BENE^=0.000000 and LONGDEG_BENE^=. and LATDEG_BENE^=0.000000 and LATDEG_BENE^=. ;
quit; *262,922 records;

proc sql;
create table tempn.distance_hosp as 
select distinct zip_cd, dschrg_year, hrrnum, hosp_LONG, hosp_LAT from tempn.distance_to_hosp_2
where hosp_LONGDEG^=0.000000 and hosp_LONGDEG^=. and hosp_LATDEG^=0.000000 and hosp_LATDEG^=.;
quit; *30,781 records;

proc sql;
create table tempn.distance_hosp_bene_hrr as 
select a.*, b.hosp_LONG, b.hosp_LAT, b.zip_cd from 
tempn.distance_bene as a left join tempn.distance_hosp as b 
on a.hrrnum_bene=b.hrrnum and a.DSCHRG_YEAR=b.DSCHRG_YEAR;
quit; *6,343,604;

data tempn.distance_hosp_bene_hrr_2;
set tempn.distance_hosp_bene_hrr;
*Replace the "0.000000" longitude and latitude for several special beneficiary zip codes (i.e. census-designated place) with their actual longitude and latitude found from US Census Bureau website; 
*Convert decimal degrees to radians;
if bene_zip=zip_cd then Min_Hosp_Dist=0; 
else do; 
Distance = 3949.99 * arcos(sin(LAT_BENE) * sin(hosp_LAT) + cos(LAT_BENE) * cos(hosp_LAT) * cos(LONG_BENE - hosp_LONG));
Min_Hosp_Dist_Hrr=round(distance,0.01);
end;
run; *6,343,604;

proc sort data=tempn.distance_hosp_bene_hrr_2;
by bene_zip DSCHRG_YEAR Min_Hosp_Dist_Hrr;
run;

data tempn.distance_hosp_bene_hrr_3;
set tempn.distance_hosp_bene_hrr_2;
by bene_zip DSCHRG_YEAR Min_Hosp_Dist_Hrr;
if first.DSCHRG_YEAR;
run;  *262,922 records;

Proc sql;
create table tempn.pac_all_final_9 as 
select a.*, b.Min_Hosp_Dist_Hrr	label="Distance to Closest Hospital within HRR"
from tempn.distance_to_hosp_2(drop=distance) as a left join tempn.distance_hosp_bene_hrr_3  as b
on a.bene_zip=b.bene_zip and a.DSCHRG_YEAR=b.DSCHRG_YEAR;
quit; *66,659,096 records; 

/*****************************************************************************************************************
 Create Urban Rural Indicator for Patient
*****************************************************************************************************************/ 
proc import datafile="[PATH]/final310.xlsx" out=tempn.ruca dbms=xlsx replace;run;

data tempn.ruca_2;
set tempn.ruca;
zip_ruca=put(zipcoden,z5.);
run;

proc sql;
create table temp.pac_all_analytical_ruca as 
select a.*, b.RUCA30 from 
tempn.pac_all_final_9 as a left join tempn.ruca_2 as b
on a.bene_zip=b.zip_ruca;
quit; *66,659,096 records;

proc sql;create table check_merge as select bene_id from temp.pac_all_analytical_ruca where RUCA30=.;
quit; *60,401 missing --> 0.09%;

proc freq data=tempn.ruca_2;
table RUCA30 ;
run;

data tempn.pac_all_final_10;
set temp.pac_all_analytical_ruca;
if 1<=RUCA30<=3 then Urban=1;else Urban=0;
if 7<=RUCA30<=10.3 then Rural=1;else Rural=0;
label Urban="Urban Indicator" Rural="Rural Indicator";
run; *66,659,096 records;

/*****************************************************************************************************************
 Create variables for # of SNF, # of HHA and # of SNF - # of HHA in each HSA and HRR for each year
*****************************************************************************************************************/
*Count # of SNF in each HSA;
proc sql;
create table tempn.pac_hsa_snf_count as 
select *, count(prvdrnum) as snf_count_hsa from tempn.pac_hsa
where disch_pac_n=1 and hsanum^=. and DSCHRG_YEAR^=.
group by hsanum, DSCHRG_YEAR;
quit;  *109,839;

*Count # of HHA in each HSA;
proc sql;
create table tempn.pac_hsa_hha_count as 
select *, count(prvdrnum) as hha_count_hsa from tempn.pac_hsa
where disch_pac_n=3 and hsanum^=. and DSCHRG_YEAR^=.
group by hsanum, DSCHRG_YEAR;
quit;  *71,387;

*Count # of SNF in each HRR;
proc sql;
create table tempn.pac_hrr_snf_count as 
select *, count(prvdrnum) as snf_count_hrr from tempn.pac_hsa
where disch_pac_n=1 and hrrnum^=. and DSCHRG_YEAR^=.
group by hrrnum, DSCHRG_YEAR;
quit;   *109,839;

*Count # of HHA in each HRR;
proc sql;
create table tempn.pac_hrr_hha_count as 
select *, count(prvdrnum) as hha_count_hrr from tempn.pac_hsa
where disch_pac_n=3 and hrrnum^=. and DSCHRG_YEAR^=.
group by hrrnum, DSCHRG_YEAR;
quit;  *71,387;

*Collapse the data sets to HSA/HRR - Discharge Year level;
proc sort data=tempn.pac_hsa_snf_count nodupkey;by hsanum DSCHRG_YEAR;run;
proc sort data=tempn.pac_hsa_hha_count nodupkey;by hsanum DSCHRG_YEAR;run;
proc sort data=tempn.pac_hrr_snf_count nodupkey;by hrrnum DSCHRG_YEAR;run;
proc sort data=tempn.pac_hrr_hha_count nodupkey;by hrrnum DSCHRG_YEAR;run;

data tempn.pac_hsa_nomissing;
set tempn.pac_hsa;
where hsanum^=. and hrrnum^=.; * Exclude records with missing hsanum/hrrnum;
run; *189,151;

*Merge SNF/HHA count variables into HSA/HRR - Discharge Year level data set;
proc sql;
create table tempn.pac_count as 
select a.*, b.snf_count_hsa, c.hha_count_hsa, d.snf_count_hrr, e.hha_count_hrr 
from tempn.pac_hsa_nomissing as a 
left join tempn.pac_hsa_snf_count as b on a.hsanum=b.hsanum and a.DSCHRG_YEAR=b.DSCHRG_YEAR
left join tempn.pac_hsa_hha_count as c on a.hsanum=c.hsanum and a.DSCHRG_YEAR=c.DSCHRG_YEAR
left join tempn.pac_hrr_snf_count as d on a.hrrnum=d.hrrnum and a.DSCHRG_YEAR=d.DSCHRG_YEAR
left join tempn.pac_hrr_hha_count as e on a.hrrnum=e.hrrnum and a.DSCHRG_YEAR=e.DSCHRG_YEAR;
quit; *189,151;

proc sort data=tempn.pac_count nodupkey;
by hsanum hrrnum DSCHRG_YEAR;
run; 

*Reset the missing SNF/HHA count variable to 0;
data tempn.pac_count_2;
set tempn.pac_count (drop=prvdrnum);
if snf_count_hsa=. then snf_count_hsa=0;
if hha_count_hsa=. then hha_count_hsa=0;
if snf_count_hrr=. then snf_count_hrr=0;
if hha_count_hrr=. then hha_count_hrr=0;
run;

data tempn.pac_count_3;
set tempn.pac_count_2;
diff_hhasnf_hsa=hha_count_hsa-snf_count_hsa;
diff_hhasnf_hrr=hha_count_hrr-snf_count_hrr;
label snf_count_hsa="Number of SNF (HSA)" hha_count_hsa="Number of HHA (HSA)" snf_count_hrr="Number of SNF (HRR)" hha_count_hrr="Number of HHA (HRR)"  
      diff_hhasnf_hsa="Difference between HHA # and SNF # (HSA)" diff_hhasnf_hrr="Difference between HHA # and SNF # (HRR)";
rename hsanum=hsanum_bene hrrnum=hrrnum_bene;
run; *23,203;

proc sort data=tempn.pac_count_3;
by DSCHRG_YEAR hrrnum_bene hsanum_bene;
run;

proc export data=tempn.pac_count_3 outfile="[PATH]/hha_snf_count.dta" dbms=dta replace;run;

*Merge SNF/HHA count variables into analytical data set;
proc sql;
create table tempn.pac_all_final_11 as 
select a.*, b.snf_count_hsa, b.hha_count_hsa, b.snf_count_hrr, b.hha_count_hrr, b.diff_hhasnf_hsa, b.diff_hhasnf_hrr
from tempn.pac_all_final_10 as a left join tempn.pac_count_3 as b
on a.hsanum_bene=b.hsanum_bene and a.hrrnum_bene=b.hrrnum_bene and a.dschrg_year=b.dschrg_year;
quit;*66,659,096;

ods rtf file="[PATH]/Summary_SNF_HHA_Count.rtf";
title "Summary of SNF/HHA Count Variables";
proc means data=tempn.pac_all_final_11 n nmiss mean min p10 p25 median p75 p90 max maxdec=2;
var  snf_count_hsa hha_count_hsa snf_count_hrr hha_count_hrr  diff_hhasnf_hsa diff_hhasnf_hrr;
label snf_count_hsa="Number of SNF (HSA)" hha_count_hsa="Number of HHA (HSA)" snf_count_hrr="Number of SNF (HRR)" hha_count_hrr="Number of HHA (HRR)"  
      diff_hhasnf_hsa="Difference between HHA # and SNF # (HSA)" diff_hhasnf_hrr="Difference between HHA # and SNF # (HRR)";
run;
title;
ods rtf close;


/*****************************************************************************************************************
 Create variables for # of beneficiary for each HSA/HRR in each year 
*****************************************************************************************************************/
data tempn.Dn100mod_2010_16_num (drop=bene_zip);
format bene_zipcode $5.;
set Denom.Dn100mod_2010(keep=bene_id bene_zip RFRNC_YR) Denom.Dn100mod_2011(keep=bene_id bene_zip RFRNC_YR) Denom.Dn100mod_2012(keep=bene_id bene_zip RFRNC_YR)
    Denom.Dn100mod_2013(keep=bene_id bene_zip RFRNC_YR) Denom.Dn100mod_2014(keep=bene_id bene_zip RFRNC_YR) Denom.Dn100mod_2015(keep=bene_id bene_zip RFRNC_YR)
    Denom.Dn100mod_2016(keep=bene_id bene_zip RFRNC_YR);
bene_zipcode=substr(bene_zip,1,5);
run; *385,661,111 records;

proc sort data=tempn.Dn100mod_2010_16_num out=sort_test nodupkey;
by bene_id RFRNC_YR;
run; *No duplicate;

*Merge with HSA file to get the hsa/hrr number for each SNF/IRF/HHA;
Proc sql;
create table tempn.Dn100mod_2010_16_num_2 as 
select a.*, b.hsanum, b.hsastate, b.hrrnum, b.hrrstate
from tempn.Dn100mod_2010_16_num as a
left join tempn.hsa_zip_cw_1016 as b
on a.bene_zipcode=b.zip and a.RFRNC_YR=b.year_hsa;
quit; *385,661,111 records;

proc sql;create table check_merge_hsa as select bene_id from tempn.Dn100mod_2010_16_num_2 where hsanum=.;quit; *9,281,207 --> 2.4%;

Proc sql;
create table tempn.Dn_2010_16_count_hsa as 
select *, count(bene_id) as bene_count_hsa
from tempn.Dn100mod_2010_16_num_2
group by hsanum, RFRNC_YR;
quit;*385,661,111 records; 

data tempn.Dn_2010_16_count_hsa_2;
set tempn.Dn_2010_16_count_hsa (keep=RFRNC_YR hsanum hsastate hrrnum hrrstate bene_count_hsa);
run;
proc sort data=tempn.Dn_2010_16_count_hsa_2 nodup; by RFRNC_YR hsanum hrrnum; run; *17,185;

Proc sql;
create table tempn.Dn_2010_16_count_hrr as 
select *, count(bene_id) as bene_count_hrr
from tempn.Dn100mod_2010_16_num_2
group by hrrnum, RFRNC_YR;
quit;*385,661,111 records;

data tempn.Dn_2010_16_count_hrr_2;
set tempn.Dn_2010_16_count_hrr (keep=RFRNC_YR hsanum hsastate hrrnum hrrstate bene_count_hrr);
run;
proc sort data=tempn.Dn_2010_16_count_hrr_2 nodup; by RFRNC_YR hsanum hrrnum; run; *17,185;

Proc sql;
create table tempn.Dn_2010_16_count_hsa_hrr as 
select a.*, b.bene_count_hrr
from tempn.Dn_2010_16_count_hsa_2 as a
left join tempn.Dn_2010_16_count_hrr_2 as b
on a.hsanum=b.hsanum and a.hrrnum=b.hrrnum and a.RFRNC_YR=b.RFRNC_YR;
quit; *24,059;

data tempn.Dn_2010_16_count_hsa_hrr_2;
set tempn.Dn_2010_16_count_hsa_hrr;
where hsanum^=. and hrrnum^=.;
rename hsanum=hsanum_bene hrrnum=hrrnum_bene RFRNC_YR=dschrg_year;
label bene_count_hsa="Number of Beneficiaries within HSA" bene_count_hrr="Number of Beneficiaries within HRR"  ;
run; *24,052;

proc export data=tempn.Dn_2010_16_count_hsa_hrr_2 outfile="[PATH]/bene_count.dta" dbms=dta replace;run;

Proc sql;
create table tempn.pac_all_final_12 as 
select a.*, b.bene_count_hsa, b.bene_count_hrr
from tempn.pac_all_final_11 as a
left join tempn.Dn_2010_16_count_hsa_hrr_2 as b
on a.hsanum_bene=b.hsanum_bene and a.hrrnum_bene=b.hrrnum_bene and a.dschrg_year=b.dschrg_year;
quit; *66,659,096 records;


/*****************************************************************************************************************
 Calculate # of PAC Days and Hospital Days
*****************************************************************************************************************/
data pac_days_count;
set tempn.pac_all_final_12(rename=(util_day=Hosp_Days_All));
Hosp_Days=DSCHRGDT-ADMSNDT+1;
if DISCH_PAC_N eq 1 then PAC_DSCHRGDT=DSCHRGDT_SNF; 
label Hosp_Days="Length of Hospital Stay between Admission and Discharge" Hosp_Days_All="Number of Days in the Hospital";
run; *66,659,096 records;

data pac_days_count_2;
set  pac_days_count;
if disch_pac_n=0 then Pac_Days_All=.;
if disch_pac_n in (1,2,3,4) then Pac_Days_All=PAC_DSCHRGDT-PAC_ADMSNDT+1;
if Pac_Days_All<0 & Pac_Days_All^=. then Pac_Days_All=0;
label Pac_Days_All="Number of Days in the First PAC";
run;

data tempn.pac_all_final_13;
set pac_days_count_2;
if disch_pac_n=0 then  Hosp_PAC_Days_All=Hosp_Days_All;
if disch_pac_n^=0 then Hosp_PAC_Days_All=Hosp_Days_All+Pac_Days_All;
Hosp_PAC_Pmt_All=pmt_amt_pseudo+pac_pmt_amt_pseudo;
label Hosp_PAC_Days_All="Total Number of Days in the Hospital and PAC Episode" 
      Hosp_PAC_Pmt_All="Total Amount of Medicare Spending in the Hospital and PAC Episode";
run; *66,659,096 records;

proc means data=tempn.pac_all_final_13 n nmiss mean std min max maxdec=2;
var  Hosp_Days_All Hosp_Days Pac_Days_All Hosp_PAC_Days_All pmt_amt_pseudo pac_pmt_amt_pseudo Hosp_PAC_Pmt_All;
run;


***** Create PAC within Same HSA/HRR Indicators;
*Create indicators to identify beneficiaries that went to PAC facilities that within the same HSA/HRR of their residence; 
proc sql;
create table tempn.pac_hsahrr as 
select a.*, b.hsanum as snf_hsanum, b.hrrnum as snf_hrrnum, c.hsanum as irf_hsanum, c.hrrnum as irf_hrrnum, d.hsanum as hha_hsanum, d.hrrnum as hha_hrrnum
from tempn.pac_all_final_13	as a
left join tempn.pac_hsa as b on a.prvdrnum_snf=b.prvdrnum and a.dschrg_year=b.dschrg_year and a.disch_pac_n=b.disch_pac_n
left join tempn.pac_hsa as c on a.prvdrnum_irf=c.prvdrnum and a.dschrg_year=c.dschrg_year and a.disch_pac_n=c.disch_pac_n
left join tempn.pac_hsa as d on a.prvdrnum_hha=d.prvdrnum and a.dschrg_year=d.dschrg_year and a.disch_pac_n=d.disch_pac_n;
quit; *66,659,096 records;

data tempn.pac_all_final_14;
set tempn.pac_hsahrr ;
if disch_pac_n=1 and snf_hsanum=hsanum_bene then PAC_Within_Same_HSA=1;
else if disch_pac_n=2 and irf_hsanum=hsanum_bene then PAC_Within_Same_HSA=1;
else if disch_pac_n=3 and hha_hsanum=hsanum_bene then PAC_Within_Same_HSA=1;
else if disch_pac_n in (0,4) then PAC_Within_Same_HSA=.;
else PAC_Within_Same_HSA=0;

if disch_pac_n=1 and snf_hrrnum=hrrnum_bene then PAC_Within_Same_HRR=1;
else if disch_pac_n=2 and irf_hrrnum=hrrnum_bene then PAC_Within_Same_HRR=1;
else if disch_pac_n=3 and hha_hrrnum=hrrnum_bene then PAC_Within_Same_HRR=1;
else if disch_pac_n in (0,4) then PAC_Within_Same_HRR=.;
else PAC_Within_Same_HRR=0;

label PAC_Within_Same_HSA="Went to PAC within the Same HSA"	PAC_Within_Same_HRR="Went to PAC within the Same HRR";
run;

proc sort data=tempn.pac_all_final_14;
by disch_pac_n;
run;


***** Create Non-discretionary Hospitalization Indicators;
data tempn.radm1016;
set radm.radm2010_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07) 
    radm.radm2011_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07)
    radm.radm2012_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07) 
    radm.radm2013_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07)
	radm.radm2014_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07)
    radm.radm2015_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07)
	radm.radm2016_dx10_update(keep=HICNO provid admit disch RADM30ALL RADM30_planned RADM30_unplanned RADM30 RADM30_preventable drgcd PQI11 PQI08 PQI05 PQI12 PQI07);
num=_n_;
if PQI11=1 or PQI08=1 or PQI05=1 or PQI12=1 or PQI07=1 then disct=1; else disct=0; 
run; *90,348,446;

*Sort the data set by bene_id, admission date and discharge date descendingly;
proc sort data=tempn.radm1016; by HICNO descending admit descending disch;run;

*Use LAG function to get the DRG code for readmission;
data tempn.radm1016_2;
set tempn.radm1016;
by HICNO descending admit descending  disch;
drgcd_lag=lag(drgcd);
HICNO_lag=lag(HICNO);
disct_lag=lag(disct);
if radm30=1 and HICNO=HICNO_lag then drg_cd_radm=drgcd_lag;
if radm30=1 and HICNO=HICNO_lag then dsct_hosp_v2=disct_lag; 
label dsct_hosp_v2="Discretionary Hospitalization (Version 2)";
run;

Proc sql; create table check_radm30 as select hicno from tempn.radm1016_2 where radm30=1 and disch<=20760; quit; *10,050,679 records;
Proc sql; create table check_radm_drg_1 as select hicno from tempn.radm1016_2 where drg_cd_radm^=. and disch<=20760; quit; *10,001,188 records (99.51%);
Proc sql; create table check_radm_drg_2 as select hicno from tempn.radm1016_2 where radm30=1 and drg_cd_radm^=. and disch<=20760; quit; *10,001,188 records (99.51%);

data tempn.radm1016_3;
set tempn.radm1016_2;
*1;
if 280<=drg_cd_radm<=284 then radm_ami=1;else radm_ami=0;
*2;
if 70<=drg_cd_radm<=72 then radm_cereb_do=1; else radm_cereb_do=0;
*3;
if 480<=drg_cd_radm<=482 then radm_hip_rep=1; else radm_hip_rep=0;
*4;
if 350<=drg_cd_radm<=352 then radm_ifhr=1; else radm_ifhr=0;
*5;
if 329<=drg_cd_radm<=331 then radm_mbo=1; else radm_mbo=0;
*6;
if 411<=drg_cd_radm<=419 then radm_ccy=1; else radm_ccy=0;
*7;
if 377<=drg_cd_radm<=379 then radm_gast_bld=1; else radm_gast_bld=0;
*8;
if 338<=drg_cd_radm<=343 then radm_appy=1; else radm_appy=0;
*9;
if drg_cd_radm=189 then radm_resp_flr=1; else radm_resp_flr=0;
*10;
if 870<=drg_cd_radm<=872 or 94<=drg_cd_radm<=96 or 288<=drg_cd_radm<=290 then radm_seve_inf=1; else radm_seve_inf=0;
*11;
if radm_ami=1 or radm_cereb_do=1 or radm_hip_rep=1 or radm_ifhr=1 or radm_mbo=1 or
   radm_ccy=1 or radm_gast_bld=1 or radm_appy=1 or radm_resp_flr=1 or radm_seve_inf=1 then non_dsct_hosp=1; else non_dsct_hosp=0;

if radm30=1 and non_dsct_hosp=0 then dsct_hosp_v1=1; else dsct_hosp_v1=0;

if dsct_hosp_v2=. then dsct_hosp_v2=0;
label radm_ami="Acute Myocardial Infarction (Readmission)" radm_cereb_do="Cerebrovascular Disorders (Readmission)" radm_hip_rep="Hip Repair (Readmission)" radm_ifhr="Inguinal and Femoral Hernia Repair (Readmission)" 
      radm_mbo="Major Bowel Operation (Readmission)" radm_ccy="Cholecystectomy (Readmission)" radm_gast_bld="Gastrointestinal Bleed (Readmission)" radm_appy="Appendectomy (Readmission)" 
	  radm_resp_flr="Respiratory Failure (Readmission)"	radm_seve_inf="Severe Infection (Readmission)" non_dsct_hosp="Non-discretionary Hospitalization" drg_cd_radm="DRG Code of Readmission" 
      dsct_hosp_v1="Discretionary Hospitalization (Version 1)";
run; *90,348,446 records;

Proc sql;
create table tempn.pac_all_final_15 as 
select a.*, b.radm_ami, b.radm_cereb_do, b.radm_hip_rep, b.radm_ifhr, b.radm_mbo,
            b.radm_ccy, b.radm_gast_bld, b.radm_appy, b.radm_resp_flr, b.radm_seve_inf, b.non_dsct_hosp, b.dsct_hosp_v1, b.dsct_hosp_v2, 
            b.drg_cd_radm, b.num
from tempn.pac_all_final_14 as a left join tempn.radm1016_3 as b 
on a.bene_id=b.HICNO and a.admsndt>=b.admit and a.dschrgdt<=b.disch;
quit; *66,791,744 records;

proc sort data=tempn.pac_all_final_15 nodupkey; by bene_id admsndt dschrgdt;run; *66,659,096 records;


***** Merge in Hospital-based PAC Indicators;
Proc sql;
create table tempn.pac_all_final_16 as 
select a.*, b.hosp_snf, b.hosp_hha, b.hosp_pac from 
tempn.pac_all_final_15 as a left join pac.hosp_based_pac_1016_final as b
on a.hosp_prvdrnum=b.hosp_prvdrnum and a.dschrg_year=b.year;
quit; *66,659,096;

proc sort data=tempn.pac_all_final_16; by dschrg_year; run;


***** Create Admitted from Nursing Home Directly Indicator;
*Merge with MDS data in order to find hospitalizations that were admitted from a nursing home directly (within 3 days);
proc sql;
create table tempn.pac_all_final_17 as
select a.*, b.MDS_TRGT_DT1
from tempn.pac_all_final_16 as a
left join tempn.mds_prior_0916(rename=(MDS_TRGT_DT=MDS_TRGT_DT1)) as b  
on a.bene_id=b.bene_id and 0 lt a.ADMSNDT-b.MDS_TRGT_DT1 le 3;
quit; 
proc sort data=tempn.pac_all_final_17 nodupkey; by medpar_id; run; 

*Identify NH stays in prior 100 days;
data tempn.pac_all_final_18 (drop=MDS_TRGT_DT1);
set tempn.pac_all_final_17;
if MDS_TRGT_DT1^=. then NH_Stay_Prior3=1; else NH_Stay_Prior3=0;

*Recode string variables to numeric;
if sex="1" then sex_num=1;
else if sex="2" then sex_num=2;
else if sex="0" then sex_num=3;

if race="0" then race_num=7;
else if race="1" then race_num=1;
else if race="2" then race_num=2; 
else if race="3" then race_num=3;
else if race="4" then race_num=4;
else if race="5" then race_num=5;
else if race="6" then race_num=6;

label NH_Stay_Prior3="Nursing Home Stay in Prior 3 Days";
run; *66,659,096;


***** Create Indicator for Patients Received SNF Hospice Care;
*Get assessments from 2010-2016 MDS3.0 that indicate beneficiaries received hospice services while in the SNF;
data pac_mds.mds3_hospice_2010_16;
set pac_mds.mds3_beneid_2010_16 (keep=bene_id mds_entry_dt mds_dschrg_dt A0310F_ENTRY_DSCHRG_CD A0310B_PPS_CD A0310A_FED_OBRA_CD O0100K2_HOSPC_POST_CD);
where O0100K2_HOSPC_POST_CD="1" & bene_id^="" & mds_entry_dt^=.;
run;

proc sort data=pac_mds.mds3_hospice_2010_16 nodupkey; by bene_id mds_entry_dt;
run;

*Get assessments from 2010 MDS2.0 that indicate beneficiaries received hospice services while in the SNF; 
data mds2_hospice_2010;
set pac_mds.mds2_2010_beneid (keep=bene_id AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA TARGET_DATE P1AO_hospice);
where P1AO_hospice="1" & bene_id^="";
run;

proc sql;
create table mds2_hospice_2010_2 as 
select bene_id, AB1_ENTRY_DT, R4_DISCHARGE_DT, AA8A_PRI_RFA, TARGET_DATE, P1AO_hospice 
from pac_mds.mds2_2010_beneid
where bene_id in (select bene_id from mds2_hospice_2010);
quit;

data mds2_hospice_2010_3(drop=AB1_ENTRY_DT R4_DISCHARGE_DT);
set mds2_hospice_2010_2;
MDS_ENTRY_DT=input(AB1_ENTRY_DT,yymmdd8.);
MDS_DSCHRG_DT=input(R4_DISCHARGE_DT,yymmdd8.);
format MDS_ENTRY_DT MDS_DSCHRG_DT date9.;
run;

proc sql; create table entry_in_2010 as select bene_id from mds2_hospice_2010_3 where MDS_ENTRY_DT>=18263; quit;
proc sql; create table mds2_hospice_2010_4 as select * from mds2_hospice_2010_3 where bene_id in (select bene_id from entry_in_2010); quit;
proc sort data=mds2_hospice_2010_4; by bene_id TARGET_DATE; run; 

data mds2_hospice_2010_5;
set mds2_hospice_2010_4;
MDS_ENTRY_DT_LAG1=lag1(MDS_ENTRY_DT);
MDS_ENTRY_DT_LAG2=lag2(MDS_ENTRY_DT);
MDS_ENTRY_DT_LAG3=lag3(MDS_ENTRY_DT);
MDS_ENTRY_DT_LAG4=lag4(MDS_ENTRY_DT);
MDS_ENTRY_DT_LAG5=lag5(MDS_ENTRY_DT);
MDS_ENTRY_DT_LAG6=lag6(MDS_ENTRY_DT);
bene_id_LAG1=lag1(bene_id);
bene_id_LAG2=lag2(bene_id);
bene_id_LAG3=lag3(bene_id);
bene_id_LAG4=lag4(bene_id);
bene_id_LAG5=lag5(bene_id);
bene_id_LAG6=lag6(bene_id);
run;

data mds2_hospice_2010_6;
set mds2_hospice_2010_5;
by bene_id TARGET_DATE;
if P1AO_hospice="1" & MDS_ENTRY_DT^=. then MDS_ENTRY_DT_2=MDS_ENTRY_DT;
else if P1AO_hospice="1" & MDS_ENTRY_DT=. & bene_id=bene_id_LAG1 & MDS_ENTRY_DT_LAG1^=. then MDS_ENTRY_DT_2=MDS_ENTRY_DT_LAG1;
else if P1AO_hospice="1" & MDS_ENTRY_DT=. & MDS_ENTRY_DT_LAG1=. & bene_id=bene_id_LAG2 & MDS_ENTRY_DT_LAG2^=. then MDS_ENTRY_DT_2=MDS_ENTRY_DT_LAG2;
else if P1AO_hospice="1" & MDS_ENTRY_DT=. & MDS_ENTRY_DT_LAG1=. & MDS_ENTRY_DT_LAG2=. & bene_id=bene_id_LAG3 & MDS_ENTRY_DT_LAG3^=. then MDS_ENTRY_DT_2=MDS_ENTRY_DT_LAG3;
else if P1AO_hospice="1" & MDS_ENTRY_DT=. & MDS_ENTRY_DT_LAG1=. & MDS_ENTRY_DT_LAG2=. & MDS_ENTRY_DT_LAG3=. & bene_id=bene_id_LAG4 & MDS_ENTRY_DT_LAG4^=. then MDS_ENTRY_DT_2=MDS_ENTRY_DT_LAG4;
else if P1AO_hospice="1" & MDS_ENTRY_DT=. & MDS_ENTRY_DT_LAG1=. & MDS_ENTRY_DT_LAG2=. & MDS_ENTRY_DT_LAG3=. & MDS_ENTRY_DT_LAG4=. & bene_id=bene_id_LAG5 & MDS_ENTRY_DT_LAG5^=. then MDS_ENTRY_DT_2=MDS_ENTRY_DT_LAG5;
else if P1AO_hospice="1" & MDS_ENTRY_DT=. & MDS_ENTRY_DT_LAG1=. & MDS_ENTRY_DT_LAG2=. & MDS_ENTRY_DT_LAG3=. & MDS_ENTRY_DT_LAG4=. & MDS_ENTRY_DT_LAG5=. & bene_id=bene_id_LAG6 & MDS_ENTRY_DT_LAG6^=. 
then MDS_ENTRY_DT_2=MDS_ENTRY_DT_LAG6;
if first.TARGET_DATE & P1AO_hospice="1" then MDS_ENTRY_DT_2=input(TARGET_DATE,yymmdd8.);
format MDS_ENTRY_DT_2 date9.;
run;

data pac_mds.mds2_hospice_2010(rename=(P1AO_hospice=O0100K2_HOSPC_POST_CD MDS_ENTRY_DT_2=MDS_ENTRY_DT));
set mds2_hospice_2010_6(drop=MDS_ENTRY_DT);
run;

data pac_mds.mds_hospice_2010_2016;
set pac_mds.mds3_hospice_2010_16(keep=bene_id MDS_ENTRY_DT O0100K2_HOSPC_POST_CD) 
    pac_mds.mds2_hospice_2010(keep=bene_id MDS_ENTRY_DT O0100K2_HOSPC_POST_CD); 
run; *1,572,376;
proc sort data=pac_mds.mds_hospice_2010_2016 nodupkey; by bene_id  MDS_ENTRY_DT; run; *1,451,977;

proc sql;
create table tempn.pac_all_analytical_1016 as
select medpar.*, hospice.O0100K2_HOSPC_POST_CD as snf_hospice label="Received Hospice Care at SNF"
from tempn.pac_all_final_18 as medpar 
left join pac_mds.mds_hospice_2010_2016 as hospice
on medpar.bene_id=hospice.bene_id and -1 le medpar.ADMSNDT_SNF-hospice.MDS_ENTRY_DT le 1 and disch_pac_n=1;
quit; *66,659,703;

proc sort data=tempn.pac_all_analytical_1016 nodupkey; by medpar_id; run; *66,659,096;

data tempn.hospice_at_snf_1016(keep=medpar_id snf_hospice);
set tempn.pac_all_analytical_1016;
where snf_hospice="1";
run;  *471,008;

proc export data=tempn.hospice_at_snf_1016 outfile="[PATH]/hospice_at_snf_1016.dta" dbms=dta replace;run;


***** Create Indicator for Patients with End-stage Disease;
*Get assessments from 2010-2016 MDS3.0 that indicate beneficiaries with end-stage disease;
data pac_mds.mds3_endstage_2010_16(keep=bene_id MDS_ENTRY_DT LIFE_PRGNS_6MONTH);
set pac_mds.mds3_beneid_2010_16 (keep=bene_id mds_entry_dt mds_dschrg_dt A0310B_PPS_CD A0310A_FED_OBRA_CD J1400_LIFE_PRGNS_CD);
where J1400_LIFE_PRGNS_CD="1" & bene_id^="" & mds_entry_dt^=. & (A0310B_PPS_CD in ('01','06') | A0310A_FED_OBRA_CD="01");
rename J1400_LIFE_PRGNS_CD=LIFE_PRGNS_6MONTH;
run; *384,594;

proc sort data=pac_mds.mds3_endstage_2010_16 nodupkey; by bene_id mds_entry_dt;
run; *378,138;

*Get assessments from 2010-2016 MDS2.0 that indicate beneficiaries with end-stage disease;
data mds2_endstage_2010;
set pac_mds.mds2_2010_beneid (keep=bene_id AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA TARGET_DATE J5C_END_STG_DISEAS);
where J5C_END_STG_DISEAS="1" & bene_id^="" & AA8A_PRI_RFA="01";
run; *27,798;

data pac_mds.mds2_endstage_2010(keep=bene_id MDS_ENTRY_DT LIFE_PRGNS_6MONTH);
set mds2_endstage_2010(keep=bene_id AB1_ENTRY_DT J5C_END_STG_DISEAS);
MDS_ENTRY_DT=input(AB1_ENTRY_DT,yymmdd8.);
format MDS_ENTRY_DT date9.;
rename J5C_END_STG_DISEAS=LIFE_PRGNS_6MONTH;
run;

proc sort data=pac_mds.mds2_endstage_2010 nodupkey; by bene_id mds_entry_dt;
run; *27,740;

data pac_mds.mds_endstage_2010_16;
set pac_mds.mds3_endstage_2010_16 pac_mds.mds2_endstage_2010;
run; *405,878;

proc sort data=pac_mds.mds_endstage_2010_16 nodupkey; by bene_id  MDS_ENTRY_DT; run; *405,800;

proc sql;
create table tempn.pac_all_analytical_1016_2 as
select medpar.*, b.LIFE_PRGNS_6MONTH as LIFE_PRGNS_6MONTH label="Life Prognosis Less Than Six Months"
from tempn.pac_all_analytical_1016 as medpar 
left join pac_mds.mds_endstage_2010_16 as b
on medpar.bene_id=b.bene_id and -1 le medpar.ADMSNDT_SNF-b.MDS_ENTRY_DT le 1 and disch_pac_n=1;
quit; *66,659,111;

proc sort data=tempn.pac_all_analytical_1016_2 nodupkey; by medpar_id; run; *66,659,096; 

data tempn.LIFE_PRGNS_6MONTH_snf_1016(keep=medpar_id LIFE_PRGNS_6MONTH);
set tempn.pac_all_analytical_1016_2;
where LIFE_PRGNS_6MONTH="1";
run; *148,238;

proc export data=tempn.LIFE_PRGNS_6MONTH_snf_1016 outfile="[PATH]/LIFE_PRGNS_6MONTH_snf_1016.dta" dbms=dta replace;run;


***** Create No Nursing Home Stay in Prior 30-day Indicator;
proc sql;
create table tempn.pac_all_analytical_1016_3 as
select a.*, b.MDS_TRGT_DT1
from tempn.pac_all_analytical_1016_2 as a
left join tempn.mds_prior_0916(rename=(MDS_TRGT_DT=MDS_TRGT_DT1)) as b  
on a.bene_id=b.bene_id and 0 lt a.ADMSNDT-b.MDS_TRGT_DT1 le 30;
quit; *74,347,923; 
proc sort data=tempn.pac_all_analytical_1016_3 nodupkey; by medpar_id; run; *66,659,096; 

data tempn.pac_all_analytical_1016_4(drop=MDS_TRGT_DT1);
set tempn.pac_all_analytical_1016_3;
if MDS_TRGT_DT1^=. then NH_Stay_Prior30=1; else NH_Stay_Prior30=0;
label NH_Stay_Prior30="Nursing Home Stay in Prior 30 Days";
run; 

data tempn.NH_Stay_Prior30_1016(keep=medpar_id NH_Stay_Prior30);
set tempn.pac_all_analytical_1016_3;
run;

proc export data=tempn.NH_Stay_Prior30_1016 outfile="[PATH]/NH_Stay_Prior30_1016.dta" dbms=dta replace;run;


***** Calculate Interval between Last MDS Assessments and Hospital Admission;
proc sql;
create table tempn.pac_all_analytical_1016_5 as
select a.*, b.MDS_TRGT_DT1
from tempn.pac_all_analytical_1016_4 as a
left join tempn.mds_prior_0916(rename=(MDS_TRGT_DT=MDS_TRGT_DT1)) as b  
on a.bene_id=b.bene_id and 0 lt a.ADMSNDT-b.MDS_TRGT_DT1 le 100;
quit; 
proc sort data=tempn.pac_all_analytical_1016_5 nodupkey; by medpar_id; run;  *66,659,096; 


***** Merge in total Medicare spending amount in the prior year based on MedPAR;
proc sql;
create table tempn.pac_all_analytical_1016_6 as 
select a.*, b.pmt_amt_sum as Prior_Pmt_Amt_Sum label="Total Medicare Spending in the Prior Year"
from tempn.pac_all_analytical_1016_5 as a
left join tempn.Bene_Pmt_2009_16
on a.bene_id=b.bene_id and a.dschrg_year=b.dschrg_year+1;
quit; *66,659,096; 

proc sql; create table check_missing as select bene_id from tempn.pac_all_analytical_1016_6 where Prior_Pmt_Amt_Sum=.; quit; *40,849,131 (61.28%); 

*Save final analytical data set and drop unnecessary variables;
options validvarname=upcase;
data pac.pac_all_analytical_1016(drop=hicno history_case para para_b postmod_a premo_a ma post_flag provid TRANS_COMBINE PRIOR12 POST1 sample INTERVAL CONDITION i MDS_TRGT_DT1 num);
set tempn.pac_all_analytical_1016_6;
Asmnt_Hosp_Admsn_Int=admsndt-MDS_TRGT_DT1;
if Prior_Pmt_Amt_Sum=. then Prior_Pmt_Amt_Sum=0;
label Asmnt_Hosp_Admsn_Int="Interval between Last MDS Assessment and Hospital Admission";
run;


***** Export the analytical data set to stata data set;
proc export data=pac.pac_all_analytical_1016 outfile="[Path]/pac_all_analytical_1016.dta" dbms=dta replace;run;

/* Print a list of variables in the analytical data set */
ods pdf file="[Path]/Variable_List.pdf";
title "List of Variables in PAC Use Analytical Data Set";
proc contents data=pac.pac_all_analytical_1016 varnum;
run;
title;
ods pdf close;

