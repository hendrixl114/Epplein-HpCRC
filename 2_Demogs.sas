options nocenter  nonumber linesize= 120 pagesize= 85 formchar='|----|+|---' nodate nofmterr fmtsearch=(library.fmts);
ods listing;
ods html close;
Title1 "HPCRC Project";
options dtreset fullstimer;

footnote;
%let saveloc=23AUG17;

/* run before code execution*/
%let SAS_ListingDateTimeStamp   = Demogs_listing_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let ListingOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..txt;
ods listing file="&ListingOutFile";


%let SAS_LogDateTimeStamp   = Demogs_log_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let LogOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_LogDateTimeStamp..txt;;
filename logfile "&LogOutFile";
proc printto log="&LogOutFile" ;
run;
*******************************************************************
*  PROGRAM NAME:  2_Demogs
*  PROJECT:      Epplein HPCRC study
*  PROGRAMMER:   Laura Hendrix
*  DATE: 23AUG17
*  DESCRIPTION:  demographics

*******************************************************************    ;
 
libname x 'H:\epplein\project2_hpcrc\data';
libname library 'H:\epplein\project2_hpcrc\data\formats';

proc format library=library;

data demog;
set x.hpcrc_final_30aug17;
total=1;

run;
options orientation=landscape;

ods pdf file='H:\epplein\project2_hpcrc\results\23aug17\demogs_07SEP17.pdf';



/*Table1*/
proc means data=demog median mean nmiss maxdec=1;var follow_year age bmi;run;
/*proc means data=demog median mean nmiss maxdec=1; class cohort;var follow_year age;run;
proc freq data=demog;table sex race bmi casecontrol/missing;run;
proc freq data=demog;table cohort*(sex race casecontrol)/nocol nopercent missing;run;
proc freq data=demog;table study*race;run;
*/
proc tabulate data=demog missing order=internal;
class hp_class groel_b hcpc_b vaca_b omp_b hp0231_b caga_b cagm_b cad_b hp0305_b catalase_b hyua_b hpaa_b 
urea_b napa_b racebin bmi smoking diabetes site_me crc_famhist crc_screening racebin education fycat total;
classlev hp_class groel_b hcpc_b vaca_b omp_b hp0231_b caga_b cagm_b cad_b hp0305_b catalase_b hyua_b hpaa_b 
urea_b napa_b racebin bmi smoking diabetes site_me crc_famhist crc_screening racebin education fycat  total/style=[cellwidth=2in asis=on];
tables hp_class groel_b hcpc_b vaca_b omp_b hp0231_b caga_b cagm_b cad_b hp0305_b catalase_b hyua_b hpaa_b 
urea_b napa_b  bmi smoking diabetes site_me crc_famhist crc_screening racebin fycat education,racebin='racebin'*(n*f=8.0 colpctn='(%)'*f=pctfmt.)total=''*(n*f=8.0 colpctn='(%)'*f=pctfmt.)/misstext='0' rts=20;

label total='Total';
run;	

ods pdf close;

proc means data=demog n min max nmiss;
var follow_year;
where study='PLCO';
run;
