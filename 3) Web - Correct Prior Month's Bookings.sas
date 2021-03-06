﻿%LET NEW_MONTH_FILE = MAY_APPS;
%LET NEW_MONTH_FILE_2 = MAY_APPS_2;
/*
%LET APP_IMPORT_FILE = &ALL_APPS_2.; 
*/
%LET RECENT_MONTH_NO = 201805;
%LET ONE_MO_AGO = 201804;
%LET TWO_MO_AGO = 201803;
%LET TWO_MO_AGO_APPS = MARCH_APPS;
%LET TWO_MO_AGO_APPS_NEW = MARCH_APPS_NEW;
%LET TWO_MO_BOOKED_2 = BOOKED_MARCH;
%LET TWO_MO_UNBOOKED_2 = UNBOOKED_MARCH;
%LET ONE_MO_BOOKED_2 = APRIL_APPS_B_2;
%LET ONE_MO_UNBOOKED_2 = APRIL_APPS_UNB_2;
%LET ALL_APPS_FILE_2 = ALL_APPS_APRIL_FINAL;
%LET ONE_MO_AGO_APPS = APRIL_APPS;
%LET ONE_MO_AGO_APPS_NEW = APRIL_APPS_NEW;
%LET ONE_MO_AGO_APPS_2 = APRIL_APPS_2;

*** CORRECT BOOKINGS FROM TWO MONTHS AGO ------------------------- ***;
DATA &ALL_APPS_FILE_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &ALL_APPS_FILE_2;
	IF APPYRMONTH NE &RECENT_MONTH_NO;
RUN;

DATA PRIOR_PLUS_NEW;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &NEW_MONTH_FILE &ALL_APPS_FILE_2 ;
RUN;

DATA &TWO_MO_AGO_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET PRIOR_PLUS_NEW;
	IF APPYRMONTH = &TWO_MO_AGO;
RUN;

DATA &ONE_MO_AGO_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET PRIOR_PLUS_NEW;
	IF APPYRMONTH = &ONE_MO_AGO;
RUN;

DATA &TWO_MO_UNBOOKED_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &TWO_MO_AGO_APPS;
	IF BOOKED = 0 & BRACCTNO = "";
RUN;

DATA &TWO_MO_BOOKED_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &TWO_MO_AGO_APPS;
	IF BRACCTNO NE "" & BOOKED = 1;
RUN;

DATA &ONE_MO_AGO_APPS_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &ONE_MO_AGO_APPS;
	NEW = "X";
	KEEP NEW BRACCTNO;
	IF BRACCTNO NE "";
RUN;

PROC SORT 
	DATA = &ONE_MO_AGO_APPS_2 NODUPKEY;
	BY BRACCTNO;
RUN;

DATA &NEW_MONTH_FILE_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &NEW_MONTH_FILE;
	NEWEST = "X";
	KEEP NEWEST BRACCTNO;
	IF BRACCTNO NE "";
RUN;

PROC SORT 
	DATA = &TWO_MO_BOOKED_2;
	BY BRACCTNO;
RUN;

PROC SORT 
	DATA = &ONE_MO_AGO_APPS_2;
	BY BRACCTNO;
RUN;

PROC SORT 
	DATA = &NEW_MONTH_FILE_2;
	BY BRACCTNO;
RUN;

DATA X;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	MERGE &TWO_MO_BOOKED_2(IN = X) 
		  &ONE_MO_AGO_APPS_2 
		  &NEW_MONTH_FILE_2;
	BY BRACCTNO;
	IF X;
RUN;

DATA X2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET X;
	IF NEW = "X" | NEWEST = "X" THEN BRACCTNO = "";
	IF NEW = "X" | NEWEST = "X" THEN BOOKED = 0;

	IF BOOKED = 0 THEN DO;
		NEWLOANAMOUNT = .;
		ENTDATE_SAS = .;
		BRACCTNO = "";
		BOOKED_MONTH = .;
	END;

RUN;

DATA &TWO_MO_AGO_APPS_NEW;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &TWO_MO_UNBOOKED_2 X2;
RUN;

DATA ALL_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET PRIOR_PLUS_NEW;
	IF APPYRMONTH = &TWO_MO_AGO THEN DELETE;
RUN;

DATA ALL_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS &TWO_MO_AGO_APPS_NEW;
RUN;

DATA BOOKED;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS;
	IF BOOKED = 1;
RUN;

DATA UNBOOKED;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS;
	IF BOOKED = 0;
RUN;

PROC SORT 
	DATA = BOOKED;
	BY BRACCTNO;
RUN;

DATA ALL_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET UNBOOKED BOOKED;
	IF BOOKED = 0 THEN BOOKED_MONTH = .;
	DROP NEW NEWEST;
RUN;

*** CORRECT LAST MONTH'S BOOKINGS -------------------------------- ***;
DATA &ONE_MO_AGO_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS;
	IF APPYRMONTH = &ONE_MO_AGO;
RUN;

DATA &ONE_MO_UNBOOKED_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &ONE_MO_AGO_APPS;
	IF BOOKED = 0 & BRACCTNO = "";
RUN;

DATA &ONE_MO_BOOKED_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &ONE_MO_AGO_APPS;
	IF BRACCTNO NE "" & BOOKED = 1;
RUN;

DATA &NEW_MONTH_FILE_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &NEW_MONTH_FILE;
	NEW = "X";
	KEEP NEW BRACCTNO;
	IF BRACCTNO NE "";
RUN;

PROC SORT 
	DATA = &ONE_MO_BOOKED_2;
	BY BRACCTNO;
RUN;

PROC SORT 
	DATA = &NEW_MONTH_FILE_2;
	BY BRACCTNO;
RUN;

DATA X;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	MERGE &ONE_MO_BOOKED_2(IN = X) &NEW_MONTH_FILE_2;
	BY BRACCTNO;
	IF X;
RUN;

DATA X2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET X;
	IF NEW = "X" THEN BRACCTNO = "";
	IF NEW = "X" THEN BOOKED = 0;
	IF BOOKED = 0 THEN do;
		NETLOANAMOUNT = .;
		ENTDATE_SAS = .;
		BRACCTNO = "";
		BOOKED_MONTH = .;
	END;
RUN;

DATA &ONE_MO_AGO_APPS_NEW;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET &ONE_MO_UNBOOKED_2 X2;
RUN;

DATA ALL_APPS;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS;
	IF APPYRMONTH = &ONE_MO_AGO THEN DELETE;
RUN;

DATA ALL_APPS_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS &ONE_MO_AGO_APPS_NEW;
RUN;

DATA BOOKED;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS_2;
	IF BOOKED = 1;
RUN;

DATA UNBOOKED;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET ALL_APPS_2;
	IF BOOKED = 0;
RUN;

PROC SORT 
	DATA = BOOKED NODUPKEY OUT = DUPECHECK; /* EXPECTED: 0 DELETED */
	BY BRACCTNO;
RUN;

DATA ALL_APPS_2;
	LENGTH PORTALAPPID $15 LTFILTER_ROUTINGID $15;
	SET UNBOOKED BOOKED;
	KEEP BRACCTNO CLASSID CLASSCODE	CLASSTRANSLATION OWNST SRCD	POCD
		 DWLOANTYPE	ENTDATE	LOANDATE APRATE	EFFRATE	ORGTERM	CRSCORE
		 NETLOANAMOUNT FICO_25PT_APP CELLPHONE APPNUMBER PORTALAPPID
		 LTFILTER_ROUTINGID FIRSTNAME MIDDLENAME LASTNAME FULLADDRESS
		 ADR1 CITY EMAIL BRANCHNAME	APPDATE_SAS	SSNO1 APPSTATE PHONE
		 SSNO1_RT7 OWNBR ENTDATE_SAS BOOKED SOURCE PREAPPROVED_FLAG
		 BOOKED_MONTH ENTYRMONTH TOTALAPPS COSTPERAPP COSTPERLOAN
		 TOTALLOANCOST SUPERVISOR VP FICO_25PT_BOOKED AMTREQUESTED
		 APPFICO AMTBUCKET LOANTYPE APPDATE ZIP DECISIONSTATUS
		 HOMEPHONE WORKPHONE APPMONTH APPYRMONTH DWOWNBR
		 ENTDATEMINUSAPPDATE;

	IF BOOKED = 0 THEN do;
		TOTALLOANCOST = .;
		CLASSID = .;
		DWOWNBR = "";
		CLASSCODE = "";
		CLASSTRANSLATION = "";
		OWNST = "";
		POCD = "";
		SRCD = "";
		DWLOANTYPE = "";
		ENTDATE = "";
		LOANDATE = "";
		APRATE = .;
		EFFRATE = .;
		ORGTERM = .;
		CRSCORE = .;
		NETLOANAMOUNT = .;
		ENTDATE_SAS =.;
		ENTDATEMINUSAPPDATE = .;
		BOOKED_MONTH=.;
		ENTYRMONTH=.;
	END;
RUN;

DATA ALL_APPS_3;
	SET ALL_APPS_2;
	IF AMTREQUESTED < 5000 THEN COSTPERAPP = 2;
	ELSE COSTPERAPP = 3;
	IF 1000 <= AMTREQUESTED <= 2999 THEN AMTBUCKET = "1000-2999";
	IF 3000 <= AMTREQUESTED <= 4999 THEN AMTBUCKET = "3000-4999";
	IF AMTREQUESTED < 1000 THEN AMTBUCKET = "0-999";
	IF 5000 <= AMTREQUESTED <= 7000 THEN AMTBUCKET = "5000-7000";
	IF AMTREQUESTED > 7000 THEN AMTBUCKET = "7001 +";
RUN;

*** CHECKS ------------------------------------------------------- ***;
PROC SQL;
	SELECT ENTYRMONTH, SUM(BOOKED) 
	FROM ALL_APPS_3 
	GROUP BY 1;

	SELECT APPYRMONTH, COUNT(APPNUMBER) 
	FROM ALL_APPS_3 
	GROUP BY 1;
QUIT;

DATA &NEW_MONTH_FILE._FINAL_EXPORT;
	SET ALL_APPS_3;
	WHERE APPYRMONTH = &RECENT_MONTH_NO.;
RUN;

PROC EXPORT 
	DATA = &NEW_MONTH_FILE._FINAL_EXPORT 
	OUTFILE = "&MAIN_DIR\&NEW_MONTH_FILE._FINAL.csv" 
	DBMS = csv 
	REPLACE;
RUN;

PROC EXPORT 
	DATA = ALL_APPS_3 
	OUTFILE = "&MAIN_DIR\ALL_APPS_APR2018.xlsx" 
	DBMS = EXCEL 
	REPLACE;
RUN;

*** CANOPY BILLINGS ---------------------------------------------- ***;
DATA CANOPYFINAL;
	SET ALL_APPS_3;
	IF SOURCE = "LendingTree" & ENTYRMONTH = &RECENT_MONTH_NO;
RUN;

DATA CANOPYLOAD;
	SET CANOPYFINAL;
	KEEP PORTALAPPID NETLOANAMOUNT EFFRATE APRATE ORGTERM ENTDATE
		 APPDATE_SAS BRACCTNO;
RUN;

PROC EXPORT 
	DATA = CANOPYFINAL 
	OUTFILE = "&MAIN_DIR\CANOPY_FINAL_MAY2018.xlsx" 
	DBMS = EXCEL 
	REPLACE;
RUN;

PROC EXPORT 
	DATA = CANOPYLOAD 
	OUTFILE="&MAIN_DIR\CANOPY_LOAD_MAY2018.xlsx" 
	DBMS = EXCEL 
	REPLACE;
RUN;