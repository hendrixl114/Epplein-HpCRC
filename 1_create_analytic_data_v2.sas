options nocenter  nonumber linesize= 200 pagesize= 200 formchar='|----|+|---' nodate nofmterr fmtsearch=(library.fmts);
ods listing;
ods html close;
Title1 "HPCRC Project";
options dtreset fullstimer spool;

footnote;
%let saveloc=23AUG17;

/* run before code execution*/
%let SAS_ListingDateTimeStamp   = Create_analytic_dataset_listing_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let ListingOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..txt;
ods listing file="&ListingOutFile";


%let SAS_LogDateTimeStamp   = Create_analytic_dataset_log_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let LogOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_LogDateTimeStamp..txt;;
filename logfile "&LogOutFile";
proc printto log="&LogOutFile" ;
run;
*******************************************************************
*  PROGRAM NAME:  Create_analytic_dataset_v2
*  PROJECT:      Epplein HP-China study
*  PROGRAMMER:   Laura Hendrix
*  DATE: 23AUG17
*  DESCRIPTION:  import raw Excel data and create analytic dataset

/* NOTES:
	-ID1 1001-1076 appear to only have serology results, QC=1, no 
	other data except tube_no

Update 05JUN17 Meira is contacting investigators to clarify questions 
	regarding variable names and missing data

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATE 23AUG17 - update dataset created 17MAY17 for Meira's initial analysis

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATE 30AUG17 - RECODED VARIABLE 'FOLLOW_YEARS' FROM PLCO DATASET

*******************************************************************    ;
 

libname x 'H:\epplein\project2_hpcrc\data';
libname library 'H:\epplein\project2_hpcrc\data\formats';
LIBNAME  m 'H:\Epplein\MeiraEpplein\working\11_FINAL';
libname final1 'H:\Epplein\Project2_HpCRC\data\PLCO';
libname final2 'h:\epplein\project2_hpcrc\data\mec';



proc format library=library;
value dxagef
0-50='<50'
50-59='50-59'
60-69='50-69'
70-79='70-79'
80-high='>=80';

value bmicatf
0-<20='<20'
20-<25='20- <25'
25-<30='25- <30'
30-high='>=30';

value fycatf
1='    0- <2'
2='    2- <5'
3='    5- <10'
4='    >=10';

value yesnof
0='    Yes'
1='    No'
.='    Missing';

value racecatf
1='   White'
2='   Black'
3-high='   Other';
run;

  /* IMPORT DATA FROM EXCEL*/

PROC IMPORT OUT=hpcrc1
           DATAFILE= "H:\Epplein\Project2_HpCRC\data\HpCRCfinal_30aug17.xlsx"  
            DBMS=EXCEL REPLACE;
     RANGE="hpcrcfinal$"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


/*remove 'NA' from character vars*/
data hpcrc2;
set hpcrc1;
array vars{*} _character_;
do i= 1 to dim(vars);
	if vars(i)='NA' then vars(i)=' ';
	end;
	drop i;
	run;
	proc sort ;
by id;
run;

/* convert vars to numeric.  Any charvars are removed 
	including study so need to remerge with study later*/

%convert(ds=hpcrc2, outds=hpcrc3);

%include 'h:\epplein\project2_hpcrc\code\plco_recode_fut.sas';
data plco;
set final1.plco_h(keep=id study  draw_to_exit);
follow_year=int(draw_to_exit/365.25) ;
proc sort;
by id;
run;

%include 'h:\epplein\project2_hpcrc\code\mec_recode_crcscreening.sas';
data mec;
set final2.mec_h;
proc sort;
by id;
run;

data study;
set hpcrc2(keep=id study);
proc sort;
by id;
run;

/* merge with recoded MEC/PLCO variables*/
data final;
merge hpcrc3 (in=indata drop=study)  study;
by id;
if indata;
run;

data final1;
set final;
if study='PLCO' then follow_year=.;
else if study='MEC' then crc_screening=.;
run;

data final2;
merge final1(in=indata) plco(drop=study) mec;
by id;
if indata;
run;

proc freq data=final2;
tables crc_screening;
where study='MEC';
run;
proc freq ;
tables follow_year;
where study='PLCO';
run;

data final3;
set final2;

fycat=.;
 if 0<=follow_year<2 then fycat=1;
if  0<=follow_year_cal<2 then fycat=1;
 if 2<=follow_year<5 then fycat=2;
if 2<=follow_year_cal<5 then fycat=2;
if 5<=follow_year<=10 then fycat=3;
 if 5<=follow_year_cal<=10 then fycat=3;
 if follow_year>10 then fycat=4;
 if  follow_year_cal>10 then fycat=4;


/* meira's code for fy - why put controls in 0?*
fy_category=.;
if casecontrol=0 then fy_category=0;
if casecontrol=1 and 0<=follow_year<2 then fy_category=1;
if casecontrol=1 and 0<=follow_year_cal<2 then fy_category=1;
if casecontrol=1 and 2<=follow_year<5 then fy_category=2;
if casecontrol=1 and 2<=follow_year_cal<5 then fy_category=2;
if casecontrol=1 and 5<=follow_year<=10 then fy_category=3;
if casecontrol=1 and 5<=follow_year_cal<=10 then fy_category=3;
if casecontrol=1 and follow_year>10 then fy_category=4;
if casecontrol=1 and follow_year_cal>10 then fy_category=4;
*/
racebin=0;
if race ne 1 then racebin=1;
if race=. then racebin=.;

racecat=0;
if race =2 then racecat=1;
else if race ne 1 then racecat=2;
if race=. then racecat=.;


fycat=.;

 if 0<=follow_year<2 then fycat=1;
if  0<=follow_year_cal<2 then fycat=1;
 if 2<=follow_year<5 then fycat=2;
if 2<=follow_year_cal<5 then fycat=2;
if 5<=follow_year<=10 then fycat=3;
 if 5<=follow_year_cal<=10 then fycat=3;
 if follow_year>10 then fycat=4;
 if  follow_year_cal>10 then fycat=4;


attrib dxagecat label='Dx age';
if 0<age_dx2<50 then dxagecat=0;
else if 50<=age_dx2<60 then dxagecat=1;
else if 60<=age_dx2<70 then dxagecat=2;
else if 70<=age_dx2<80 then dxagecat=3;
else if age_dx2>=80 then dxagecat=4;

if 0<bmi<20 then bmi_cat=0; bmi_cat0=0; if bmi_cat=0 then bmi_cat0=1; 
if 20<=bmi<25 then bmi_cat=1; bmi_cat1=0; if bmi_cat=1 then bmi_cat1=1; 
if 25<=bmi<30 then bmi_cat=2; bmi_cat2=0; if bmi_cat=2 then bmi_cat2=1; 
if 30<=bmi<35 then bmi_cat=3; bmi_cat3=0; if bmi_cat=3 then bmi_cat3=1; 
if 35<=bmi<40 then bmi_cat=4; bmi_cat4=0; if bmi_cat=4 then bmi_cat4=1; 
if bmi>=40 then bmi_cat=5; bmi_cat5=0; if bmi_cat=5 then bmi_cat5=1; 
if bmi=. then bmi_cat=9; bmi_catMiss=0; if bmi_cat=9 then bmi_catMiss=1; 

bmi_gt30=0; if bmi>=30 then bmi_gt30=1;

smoking_cat=9;
if smoking=0 then smoking_cat=0; smoking_cat0=0; if smoking_cat=0 then smoking_cat0=1; 
if smoking=1 then smoking_cat=1; smoking_cat1=0; if smoking_cat=1 then smoking_cat1=1; 
if smoking=2 then smoking_cat=2; smoking_cat2=0; if smoking_cat=2 then smoking_cat2=1; 
smoking_cat9=0; if smoking_cat=9 then smoking_cat9=1; 

diabetes_cat=9; 
if diabetes=0 then diabetes_cat=0; diabetes_cat0=0; if diabetes_cat=0 then diabetes_cat0=1;
if diabetes=1 then diabetes_cat=1; diabetes_cat1=0; if diabetes_cat=1 then diabetes_cat1=1;
diabetes_cat9=0; if diabetes=. then diabetes_cat9=1;

crc_famhist_cat=9; 
if crc_famhist=0 then crc_famhist_cat=0; crc_famhist_cat0=0; if crc_famhist_cat=0 then crc_famhist_cat0=1;
if crc_famhist=1 then crc_famhist_cat=1; crc_famhist_cat1=0; if crc_famhist_cat=1 then crc_famhist_cat1=1;
crc_famhist_cat9=0; if crc_famhist=. then crc_famhist_cat9=1;

crc_screening_cat=9; 
if crc_screening=0 then crc_screening_cat=0; crc_screening_cat0=0; if crc_screening_cat=0 then crc_screening_cat0=1;
if crc_screening=1 then crc_screening_cat=1; crc_screening_cat1=0; if crc_screening_cat=1 then crc_screening_cat1=1;
crc_screening_cat9=0; if crc_screening=. then crc_screening_cat9=1;

count_5ags=sum(of groel_b hcpc_b vaca_b omp_b caga_b );
count_6ags=sum(of groel_b hcpc_b vaca_b omp_b caga_b napa_b);

countcat=0;
if 0<=count_6ags<=3 then countcat=0;
else if count_6ags in (4,5) then countcat=1;
else if count_6ags=6 then countcat=2;

white_latino=0;
if race=1 and latino=1 then white_latino=1;

nonwhite_latino=0;
if race ne 1 and latino=1 then nonwhite_latino=1;


run;


proc freq data=final3;
tables (_numeric_ )*study/missing;
format _numeric_ 1.  study $2.;
run;



proc freq data=final3;
tables racecat*latino/norow nocol nopercent missing;;
run;

proc freq data=final;
tables study/norow nocol nopercent missing;;
run;

/* save permanent dataset*/
data x.hpcrc_final_30aug17;
set final3;
format birthday date_sample date_diag date_diag2 date_death date9.;

  format casecontrol casecontrol_fmt.;
  format follow_year_cal follow_year_cal_fmt.;
  format sex sex_fmt.;
  format race race_fmt.;
  format latino latino_fmt.;
  format education education_fmt.;
  format smoking smoking_fmt.;
  format aspirin aspirin_fmt.;
  format aspirin_current aspirin_current_fmt.;
  format aspirin_ever aspirin_ever_fmt.;
  format aspirin_yrs aspirin_yrs_fmt.;
  format aspirin_pillsperweek aspirin_pillsperweek_fmt.;
  format aspirin_past48hrs aspirin_past48hrs_fmt.;
  format lowaspirin lowaspirin.;
  format lowaspirin_current lowaspirin_current_fmt.;
  format lowaspirin_yrs lowaspirin_yrs_fmt.;
  format lowaspirin_pillsperweek lowaspirin_pillsperweek_fmt.;
  format nsaid nsaid_fmt.;
  format nsaid_current nsaid_current_fmt.;
  format nsaid_yrs nsaid_yrs_fmt.;
  format nsaid_pillsperweek nsaid_pillsperweek_fmt.;
  format nsaid_past48hrs nsaid_past48hrs_fmt.;
  format mets_ME mets_ME_fmt.;
  format hrt hrt_fmt.;
  format hrt_current hrt_current_fmt.;
  format hrt_ever hrt_ever_fmt.;
  format diabetes diabetes_fmt.;
  format diabetes_med diabetes_med_fmt.;
  format crc_screening crc_screening_fmt.;
  format screening_yrs_lt5 screening_yrs_lt5_fmt.;
  format crc_famhist crc_famhist_fmt.;
  format crc_famhist_lt50 crc_famhist_lt50_fmt.;
  format antibiotic_pastyr antibiotic_pastyr_fmt.;
  format antibiotic_pastwk antibiotic_pastwk_fmt.;
  format antibiotic_past48hrs antibiotic_past48hrs_fmt.;
  format antibiotic_recent antibiotic_recent_fmt.;
  format gastritis gastritis_fmt.;
  format ibd ibd_fmt.;
  format polyps polyps_fmt.;
  format fruit_ME fruit_ME_fmt.;
  format vegetables_ME vegetables_ME_fmt.;
  format redmeat_ME redmeat_ME_fmt.;
  format stage stage_fmt.;
  format histology histology_fmt.;
  format histology2 histology2_fmt.;
  format site site_fmt.;
  format site_ME site_ME_fmt.;
  format  fycat fycatf. diabetes crc_famhist crc_screening yesnof. bmi bmicatf. racebin racebinf.;
run;

