

options nocenter  nonumber linesize= 120 pagesize= 85 formchar='|----|+|---' nodate nofmterr fmtsearch=(library.fmts);
ods listing;
ods html close;
Title1 "HPCRC Project";
options dtreset fullstimer;

footnote;
%let saveloc=14SEP17;

/* run before code execution*/
%let SAS_ListingDateTimeStamp   = Stratified_univariate_listing_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let ListingOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..txt;
ods listing file="&ListingOutFile";


%let SAS_LogDateTimeStamp   = Stratified_univariate_log_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let LogOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_LogDateTimeStamp..txt;;
filename logfile "&LogOutFile";
proc printto log="&LogOutFile" ;
run;
*******************************************************************
*  PROGRAM NAME:  4_stratified_analysis
*  PROJECT:      Epplein HPCRC study
*  PROGRAMMER:   Laura Hendrix
*  DATE: 15SEP17
*  DESCRIPTION:  logistic regression models - stratify by race and control
	for age, sex etc since matching broken

+++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATE 18SEP17 remove subjects with race=latino
*******************************************************************    ;
 
libname x 'H:\epplein\project2_hpcrc\data';
libname library 'H:\Epplein\Project2_HpCRC\data\formats';

data model;
set x.hpcrc_final_30AUG17;
if study='CLUE' then delete;
format _all_;
currsmok=0;
if smoking=2 then currsmok=1;
else if smoking=. then currsmok=.;
if latino=1 then delete;
run;

%macro logistic_white (var, cat, strata, stratacat);
proc logistic data=model;
class cohort(ref='2')/param=ref;
model casecontrol(ref='0')= hp_class age sex cohort ;
where &var=&cat & &strata=&stratacat;
title1 "Odds of CRC by HP, &var = &cat, &strata = &stratacat";
run;
%mend;

%macro logistic_nonwhite (var, cat, strata, stratacat);
proc logistic data=model;
class cohort(ref='2')
race(ref='2')/param=ref;
model casecontrol(ref='0')= hp_class age sex cohort race ;
where &var=&cat & &strata=&stratacat;
title1 "Odds of CRC by HP, &var = &cat, &strata = &stratacat";
run;
%mend;



/* 1. SMOKING STATUS*/


 %let SAS_ListingDateTimeStamp   = Stratified_univariate_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let pdfOutFile  = H:\Epplein\project2_hpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..pdf;
ods pdf file="&pdfOutFile";


	/* a. White */
%logistic_white(currsmok,0,racebin,0) 
%logistic_white(currsmok,1,racebin,0)
%logistic_white(currsmok,.,racebin,0)  

	/* b. Non-white */
%logistic_nonwhite(currsmok,0,racebin,1) 
%logistic_nonwhite(currsmok,1,racebin,1)
%logistic_nonwhite(currsmok,.,racebin,1)

/* 2. BMI */

	/* a. White */
%logistic_white(bmi_gt30,0,racebin,0) 
%logistic_white(bmi_gt30,1,racebin,0)
%logistic_white(bmi_gt30,.,racebin,0)  

	/* b. Non-white */
%logistic_nonwhite(bmi_gt30,0,racebin,1) 
%logistic_nonwhite(bmi_gt30,1,racebin,1)
%logistic_nonwhite(bmi_gt30,.,racebin,1)


/* 3. DIABETES */

	/* a. White */
%logistic_white(diabetes_cat,0,racebin,0) 
%logistic_white(diabetes_cat,1,racebin,0)
%logistic_white(diabetes_cat,9,racebin,0)  

	/* b. Non-white */
%logistic_nonwhite(diabetes_cat,0,racebin,1) 
%logistic_nonwhite(diabetes_cat,1,racebin,1)
%logistic_nonwhite(diabetes_cat,9,racebin,1)


/* 4. FAMILY HX CRC */

	/* a. White */
%logistic_white(crc_famhist_cat,0,racebin,0) 
%logistic_white(crc_famhist_cat,1,racebin,0)
%logistic_white(crc_famhist_cat,9,racebin,0)  

	/* b. Non-white */
%logistic_nonwhite(crc_famhist_cat,0,racebin,1) 
%logistic_nonwhite(crc_famhist_cat,1,racebin,1)
%logistic_nonwhite(crc_famhist_cat,9,racebin,1)


/* 5.  CRC SCREENING */

	/* a. White */
%logistic_white(crc_screening_cat,0,racebin,0) 
%logistic_white(crc_screening_cat,1,racebin,0)
%logistic_white(crc_screening_cat,9,racebin,0)  

	/* b. Non-white */
%logistic_nonwhite(crc_screening_cat,0,racebin,1) 
%logistic_nonwhite(crc_screening_cat,1,racebin,1)
%logistic_nonwhite(crc_screening_cat,9,racebin,1)

ods pdf close;
proc printto;run;

/*

%logistic(Hp_class, smoker);                  	%logistic(Omp_b,smoker);
%logistic(CagA_b,smoker);                        %logistic(VacA_b,smoker);
%logistic(HcpC_b,smoker);                        %logistic(HP0305_b,smoker);
%logistic(GroEl_b,smoker);                       %logistic(NapA_b,smoker);
%logistic(HyuA_b,smoker);                        %logistic(Cad_b,smoker);
%logistic(HpaA_b,smoker);                        %logistic(CagM_b,smoker);
%logistic(UreA_b,smoker);                        %logistic(Catalase_b,smoker);
%logistic(Cagd_b,smoker);                        %logistic(HP0231_b,smoker);
%logistic (count_5ags,smoker)						%logistic (racecat,smoker)
%logistic (bmi_gt30,smoker)				%logistic (diabetes_cat,smoker)
%logistic (crc_famhist_cat,smoker)		%logistic (crc_screening_cat,smoker)
%logistic (cohort,smoker)				%logistic (dxagecat,smoker)
