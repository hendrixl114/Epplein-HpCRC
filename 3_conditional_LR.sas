


options nocenter  nonumber linesize= 120 pagesize= 85 formchar='|----|+|---' nodate nofmterr fmtsearch=(library.fmts);
ods listing;
ods html close;
Title1 "HPCRC Project";
options dtreset fullstimer;

footnote;
%let saveloc=14SEP17;

/* run before code execution*/
%let SAS_ListingDateTimeStamp   = Conditional_LR_listing_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let ListingOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..txt;
ods listing file="&ListingOutFile";


%let SAS_LogDateTimeStamp   = Conditional_LR_log_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let LogOutFile  = H:\Epplein\Project2_HpCRC\results\&saveloc\&SAS_LogDateTimeStamp..txt;;
filename logfile "&LogOutFile";
proc printto log="&LogOutFile" ;
run;
*******************************************************************
*  PROGRAM NAME:  3_conditional_LR
*  PROJECT:      Epplein HPCRC study
*  PROGRAMMER:   Laura Hendrix
*  DATE: 23AUG17
*  DESCRIPTION:  conditional logistic regression models


*******************************************************************    ;
 
libname x 'H:\epplein\project2_hpcrc\data';
libname library 'H:\Epplein\Project2_HpCRC\data\formats';


data model;
set x.hpcrc_final_30AUG17;
if 0<=count_6ags<=3 then countcat=0;
else if count_6ags in (4,5,6) then countcat=1;
run;

/* check missing by study*
ods pdf file='H:\epplein\project2_hpcrc\results\23aug17\missing_x_study.pdf';
proc freq data=model;
tables (_numeric_ )*study/missing;
format _numeric_ 1.  study $2.;
run;
ods pdf close;

/* 1.  CRC by Ag */
%macro condi(var,con);
proc freq data=model;table &var*casecontrol/norow nopercent;
where &con;
title "Case/control vs &var";
run;
proc logistic data=model;
model casecontrol(ref='control')= &var ;
strata matchedset;where &con;
title "Univariate conditional logistic regression, &var";
title2 'All patients';
run;
%mend;


 %let SAS_ListingDateTimeStamp   = Conditional_LR_AllAgs_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let pdfOutFile  = H:\Epplein\project2_hpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..pdf;
ods pdf file="&pdfOutFile";

%condi(Hp_class,);                  	%condi(Omp_b,);
%condi(CagA_b,);                        %condi(VacA_b,);
%condi(HcpC_b,);                        %condi(HP0305_b,);
%condi(GroEl_b,);                       %condi(NapA_b,);
%condi(HyuA_b,);                        %condi(Cad_b,);
%condi(HpaA_b,);                        %condi(CagM_b,);
%condi(UreA_b,);                        %condi(Catalase_b,);
%condi(Cagd_b,);                        %condi(HP0231_b,);
%condi(count_6ags,);
%condi(count_5ags,);

%condi(hp_class Omp_b CagA_b VacA_b HcpC_b HP0305_b GroEl_b NapA_b HyuA_b Cad_b HpaA_b CagM_b UreA_b Catalase_b Cagd_b HP0231_b,);
ods pdf close;

/* 1.  CRC/HP+ by Ag */

%macro condi(var,con);
proc freq data=model;table &var*casecontrol/norow nopercent;
where hp_class=1  &con;
title "Case/control vs &var";
run;
proc logistic data=model;
model casecontrol(ref='control')= &var ;
strata matchedset;where &con;
title "Univariate conditional logistic regression, &var";
title2 'HP+ patients only';
run;
%mend;


 %let SAS_ListingDateTimeStamp   = Conditional_LR_HPpos_AllAgs_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let pdfOutFile  = H:\Epplein\project2_hpCRC\results\&saveloc\&SAS_ListingDateTimeStamp..pdf;
ods pdf file="&pdfOutFile";

 %condi(Omp_b,);
%condi(CagA_b,);                        %condi(VacA_b,);
%condi(HcpC_b,);                        %condi(HP0305_b,);
%condi(GroEl_b,);                       %condi(NapA_b,);
%condi(HyuA_b,);                        %condi(Cad_b,);
%condi(HpaA_b,);                        %condi(CagM_b,);
%condi(UreA_b,);                        %condi(Catalase_b,);
%condi(Cagd_b,);                        %condi(HP0231_b,);
%condi(count_6ags,);
%condi(count_5ags,);

%condi(Omp_b CagA_b VacA_b HcpC_b HP0305_b GroEl_b NapA_b HyuA_b Cad_b HpaA_b CagM_b UreA_b Catalase_b Cagd_b HP0231_b,);

ods pdf close;
proc printto;run;

/* examine univariate ORs by study*

%macro condi(var,con);
proc sort;
by study;
proc freq data=model;table &var*cc1/norow nopercent;
where &con;run;
proc logistic data=model;
model casecontrol(ref='control')= &var ;
strata matchedset;where &con;
by study;
run;
%mend;
%condi(Hp_class,);                  	%condi(Omp_b,);
%condi(CagA_b,);                        %condi(VacA_b,);
%condi(HcpC_b,);                        %condi(HP0305_b,);
%condi(GroEl_b,);                       %condi(NapA_b,);
%condi(HyuA_b,);                        %condi(Cad_b,);
%condi(HpaA_b,);                        %condi(CagM_b,);
%condi(UreA_b,);                        %condi(Catalase_b,);
%condi(Cagd_b,);                        %condi(HP0231_b,);
%condi(count_6ags,);
%condi(count_5ags,);

%condi(Omp_b CagA_b VacA_b HcpC_b HP0305_b GroEl_b NapA_b HyuA_b Cad_b HpaA_b CagM_b UreA_b Catalase_b Cagd_b HP0231_b,);
