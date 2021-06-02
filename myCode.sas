%let wrds=wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;

signoff;


/*in command prompt:*/
C:\Program Files\SASHome\SASFoundation\9.4>sas -encoding latin1

PROC PWENCODE in='AAAAAAA';run;

-dbcs -dbcslang japanese -dbcstype pcms

proc setinit;
run;

proc options option=encoding;
run;

/*****************START*******************************/
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=AAAAA password="{SAS002}2304BA511C34E7491140D67705F938E64E61432109C92D1E";

libname ali3 "C:\Users\ataatian\Desktop\myfolders\NBBO";
rsubmit;

%WCTdownload(yyyymmdd=20090728, myticker=EXC);

endrsubmit;
/*Log out of WRDS.*/
signoff;

/* ********************************************************************************* */
   
%MACRO WCTdownload (YYYYMMDD=, MYTICKER=);
options nonotes;
%put the date is &YYYYMMDD for &MYTICKER;

data _null_;
	
	A=input(&YYYYMMDD ,12.);
	B= divide(A-mod(A,100),100);   /*200907*/
	C= divide(B-mod(B,100),100);   /*2009*/
	BB = put(B, 6. -L);
	call symput('a1',BB);
	CC = put(C, 4. -L);
	call symput('a2',CC);
	
run;

                 
libname mydata "/wrds/nyse/taq_msec&a2./m&a1" server=wrds;
run;
 
%if not(%sysfunc(exist(mydata.wct_&yyyymmdd))) %then %return;

data _quotes / view=_quotes ;
	 set mydata.wct_&yyyymmdd;
	 where SYM_ROOT="&myticker";
run;
   
data mywct ;
	 set _quotes;
run;

   
/* House Cleaning */
proc sql; drop view _quotes; quit;
options notes;
%put ### DONE. NBBO Data Saved as  outset ; %put ;

proc export data=mywct
	 	outfile="C:\Users\ataatian\Desktop\myfolders\out2\wct_&yyyymmdd._&myticker..csv"
     	dbms=csv 
     	replace;
run;

%mend;

%MACRO myMain_4;
/*options nonotes;*/

	%do i = 1 %to 3;
		data _null_;
		set ali3.list (firstobs=&i obs=&i);;
    	/*if _n_=i then do;*/
			theTicker=TICKER;
			myDate=SWITCHDATE;
			call symput('mytick',theTicker);
			call symput('myDateMac',put(myDate,yymmddn8.));
			/*%WCTdownload(yyyymmdd=&myDateMac, myticker=&mytick);*/
			%put Here we go: &myDateMac &mytick
		/*end;*/
		run;
	%end; 
/*options notes;*/
%mend myMain_4;

%myMain_4; /***** WORKS! *********/

/**************** clearing log window ****************/
DM 'Clear Log'; 
DM "log; clear; ";

%MACRO FetchLoop;
options nosource nonotes;

	%do i = 1 %to 20020; /*20020*/
		data _null_;
		set ali3.list (firstobs=&i obs=&i);
    	
			theTicker=TICKER;
			myDate=SWITCHDATE;
			call symput('mytick',theTicker);
			call symput('myDateMac',put(myDate,yymmddn8.));

			/*x= mod(&i,10);
			D = put(x, 1. -L);
			call symput('d1',D);
			%put A&d1 &i;
			%if x=0 %then*/ 

			
		run;
		%WCTdownload(yyyymmdd=&myDateMac, myticker=&mytick);
		%put Here we go: &myDateMac &mytick;

		dm 'clear log';
	%end; 
options source notes;
%mend FetchLoop;

%FetchLoop;   /***** WORKS! *********/

   


