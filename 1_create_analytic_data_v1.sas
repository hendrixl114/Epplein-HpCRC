

options nocenter  options linesize= 120 pagesize= 85 formchar='|----|+|---' date nofmterr fmtsearch=(library.fmts);
 options nodate;
   %let timenow=%sysfunc(time(), time.);
  %let datenow=%sysfunc(date(), date9.);

footnote  "Project 1: HpBCC run on &datenow at &timenow"  ;


filename logf  'H:\epplein\project1_hpbcc\create_analytic_dataset.log' ;
filename lstf  'H:\epplein\project1_hpbcc\create_analytic_dataset.lst' ;


/*proc printto log    = logf new;
proc printto print  = lstf new;
   run;
*/
*******************************************************************
*  PROGRAM NAME:  Create_analytic_dataset
*  PROJECT:      Epplein HP-China study
*  PROGRAMMER:   Laura Hendrix
*  DATE: 17MAY17
*  DESCRIPTION:  import raw Excel data and create analytic dataset

/* NOTES:
	-ID1 1001-1076 appear to only have serology results, QC=1, no 
	other data except tube_no

Update 05JUN17 Meira is contacting investigators to clarify questions 
	regarding variable names and missing data

*******************************************************************    ;
 

libname x 'H:\epplein\project2_hpcrc\data';
libname library 'H:\epplein\project2_hpcrc\data\formats';


proc format library=library;

  /* IMPORT DATA FROM EXCEL*/
 
PROC IMPORT OUT=hpcrc1
           DATAFILE= "H:\Epplein\MeiraEpplein\finaldatasets\HpCRCfinal.xlsx"  
            DBMS=EXCEL REPLACE;
     RANGE="hpcrcfinal$"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
ods pdf file='H:\epplein\project2_hpcrc\data\proccontents_hpcrc.pdf';
proc contents data=hpcrc1 order=varnum;
run;
ods pdf close;


/*remove 'NA' from character vars*/
data hpcrc2;
set hpcrc1;
array vars{*} _character_;
do i= 1 to dim(vars);
	if vars(i)='NA' then vars(i)=' ';
	end;
	drop i;
	run;
/* format dates*
	data hpcrc2;
set hpcrc1;
*bd=put(birthday, date9.);
*format birthday date_sample date_diag date_diag2 date_death date9.;
run;
*/

/* save permanent dataset*/
data x.hpcrc_final;
set hpcrc2;
run;
