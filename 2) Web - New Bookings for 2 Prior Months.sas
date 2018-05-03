*** %LET NEW_MONTH_FILE = NOVEMBER_APPS                            ***;
*** %LET APP_IMPORT_FILE = APP_IMPORT_FILE_2                       ***;
*** %LET RECENT_MONTH_NO = 11                                      ***;
*** %LET ONE_MO_AGO = 10                                           ***;
*** %LET TWO_MO_AGO = 9                                            ***;
*** %LET TWO_MO_BOOKED= SEPTEMBER_APPS_B                           ***;
*** %LET TWO_MO_UNBOOKED = SEPTEMBER_APPS_UNB                      ***;
*** %LET APPS_MINUS_2_MO_AGO = APPS_EXCEPT_SEPTEMBER               ***;
*** %LET ALL_APPS_FILE = ALL_APPS_OCTOBER_FINAL                    ***;
*** %LET ONE_MO_BOOKED = OCTOBER_APPS_B                            ***;
*** %LET ONE_MO_UNBOOKED = OCTOBER_APPS_UNB                        ***;
*** %LET APPS_MINUS_1_MO_AGO = APPS_EXCEPT_OCTOBER                 ***;
*** %LET ALL_APPS_FILE_2 = ALL_APPS_OCTOBER_FINAL                  ***;
***                                                                ***;
*** %LET ALL_APPS_HIST_LOC =                                       ***;
*** "\\mktg-app01\E\Vishwa\webreport\Production\Web\AllApps_History_2.xlsx"***;

PROC IMPORT 
	DATAFILE = &ALL_APPS_HIST_LOC. DBMS = EXCEL OUT = APP_IMPORT_FILE 
	REPLACE;
RUN;

*** CHECKS ------------------------------------------------------- ***;
PROC SQL;
	SELECT MIN(ENTDATE) AS MIN_ENTDATE,
		   MAX(ENTDATE) AS MAX_ENTDATE,
		   MIN(APPDATE) AS MIN_APPDATE FORMAT date9.,
		   MAX(APPDATE) AS MAX_APPDATE FORMAT date9.,
		   MIN(NETLOANAMOUNT) AS MIN_NETLOANAMOUNT,
		   MAX(NETLOANAMOUNT) AS MAX_NETLOANAMOUNT
		  /* MIN(NETLOANAMT_201802) AS MIN_NETLOANAMOUNT_201802, */
		  /* MAX(NETLOANAMT_201802) AS MAX_NETLOANAMOUNT_201802 */
	FROM APP_IMPORT_FILE 
 /* WHERE NETLOANAMOUNT > 0 */;
QUIT;

*** DATA APP_IMPORT_FILE(DROP = APPDATE_SAS AMTREQUESTED DWOWNBR   ***;
***				         RENAME =(APPDATE_SAS1 = APPDATE_SAS       ***;
***							      AMTREQUESTED_NUM = AMTREQUESTED  ***;
***							      DWOWNBR_NUM = DWOWNBR));         ***;
*** 	SET APP_IMPORT_FILE;                                       ***;
*** 	APPDATE_SAS1 = APPDATE * 1;                                ***;
*** 	FORMAT APPDATE_SAS1 date9.;                                ***;
*** 	AMTREQUESTED_NUM = INPUT(AMTREQUESTED, 10.);               ***;
***  /* APPMONTH_NUM = INPUT(APPMONTH, 8.); */                     ***;
*** 	DWOWNBR_NUM = PUT(DWOWNBR, $8.);                           ***;
*** RUN;                                                           ***;
*** -------------------------------------------------------------- ***;
DATA APP_IMPORT_FILE;
	SET APP_IMPORT_FILE;
	costperloan2 = input(costperloan, 12.);
	DROP costperloan;
RUN;

DATA APP_IMPORT_FILE_2;
	SET APP_IMPORT_FILE;
	LENGTH APPNUMBER $10 PORTALAPPID $10 LTFILTER_ROUTINGID $10
		   WORKPHONE $12 CELLPHONE $12 FIRSTNAME $50 MIDDLENAME $50
		   LASTNAME $50 EMAIL $100 FULLADDRESS $120 ADR1 $80 ADR2 $25
		   CITY $50 LOANTYPE $25;
	costperloan = input(costperloan2, 12.);
	CLASSID2 = CLASSID * 1;
	APRATE2 = APRATE * 1;
	EFFRATE2 = EFFRATE * 1;
	ORGTERM2 = ORGTERM * 1;
	CRSCORE2 = CRSCORE * 1;
	NETLOANAMOUNT2 = NETLOANAMOUNT * 1;
	ENTRYMONTH2 = ENTRYMONTH * 1;
	ENTDATE_SAS2 = INPUT(STRIP(TRIM(ENTDATE)), yymmdd10.);
	APPDATEMINUSENTDATE2 = (APPDATE - INPUT(STRIP(TRIM(ENTDATE)),
											yymmdd10.)) * 1;
	ENTDATEMINUSAPPDATE2 = (INPUT(STRIP(TRIM(ENTDATE)), 
								  yymmdd10.) - APPDATE) * 1;
	APPFICO2 = SUBSTR(STRIP(TRIM(APPFICO)), 1, 3) * 1;
	BOOKED_MONTH2 = MONTH(INPUT(ENTDATE, yymmdd10.));
	TOTALLOANCOST2 = INPUT(TOTALLOANCOST, 5.);
	DROP TOTALLOANCOST BOOKED_MONTH APPFICO CLASSID APRATE EFFRATE
		 ORGTERM CRSCORE NETLOANAMOUNT ENTDATE_SAS APPDATEMINUSENTDATE
		 ENTDATEMINUSAPPDATE ENTYRMONTH costperloan2;
	RENAME TOTALLOANCOST2 = TOTALLOANCOST 
		   BOOKED_MONTH2 = BOOKED_MONTH 
		   APPFICO2 = APPFICO 
		   CLASSID2 = CLASSID 
		   APRATE2 = APRATE 
		   EFFRATE2 = EFFRATE 
		   ORGTERM2 = ORGTERM 
		   CRSCORE2 = CRSCORE 
		   NETLOANAMOUNT2 = NETLOANAMOUNT 
		   ENTDATE_SAS2 = ENTDATE_SAS 
		   APPDATEMINUSENTDATE2 = APPDATEMINUSENTDATE
		   ENTDATEMINUSAPPDATE2 = ENTDATEMINUSAPPDATE
		   ENTYRMONTH2 = ENTYRMONTH;
RUN;

DATA APP_IMPORT_FILE_2;
	LENGTH APPNUMBER $10 PORTALAPPID $10 LTFILTER_ROUTINGID $10
		   WORKPHONE $12 CELLPHONE $12 FIRSTNAME $50 MIDDLENAME $50
		   LASTNAME $50 EMAIL $100 FULLADDRESS $120 ADR1 $80 ADR2 $25
		   CITY $50 LOANTYPE $25;
	SET APP_IMPORT_FILE_2 &NEW_MONTH_FILE;
RUN;

***CHECKS -------------------------------------------------------- ***;
PROC SQL;
	SELECT ENTYRMONTH, SUM(BOOKED) 
	FROM APP_IMPORT_FILE_2 
	GROUP BY 1;

	SELECT APPYRMONTH, COUNT(APPNUMBER) 
	FROM APP_IMPORT_FILE_2 
	GROUP BY 1;
QUIT;

DATA APP_IMPORT_FILE_2;
	SET APP_IMPORT_FILE_2;
	FORMAT ENTDATE_SAS date9.;
RUN;

DATA MERGED_XX;
	SET &APP_IMPORT_FILE;
	IF APPYRMONTH NE &RECENT_MONTH_NO;
RUN;

DATA &TWO_MO_BOOKED &TWO_MO_UNBOOKED;
	SET MERGED_XX; /* LAST ITERATION OF FINAL FILE */
	IF APPYRMONTH = &TWO_MO_AGO;
	IF BOOKED = 1 THEN OUTPUT &TWO_MO_BOOKED;
	ELSE OUTPUT &TWO_MO_UNBOOKED;
RUN;

PROC SORT 
	DATA = VW_L; 
	BY SSNO1; 
RUN;

PROC SORT 
	DATA = &TWO_MO_UNBOOKED; 
	BY SSNO1; 
RUN;

DATA MADES_A;
	MERGE &TWO_MO_UNBOOKED(IN = x) VW_L(IN = y);
	BY SSNO1;
	IF x = 1;
RUN;

DATA MADES_A;
	SET MADES_A;
	IF ENTDATE_SAS >= APPDATE_SAS - 1 AND 
					  ENTDATE_SAS <= APPDATE_SAS + 60 
		THEN BOOKED = 1;
	ELSE BOOKED = 0;
	IF BOOKED = 0 THEN BRACCTNO = "";
	IF OWNBR = "" THEN OWNBR = DWOWNBR;
RUN;

DATA MADES_A;
	SET MADES_A &TWO_MO_BOOKED;
RUN;

PROC SORT 
	DATA = MADES_A; 
	BY BRACCTNO LOANTYPE; 
RUN;

DATA UNBOOKED BOOKED;
	SET MADES_A;
	IF BRACCTNO = "" THEN OUTPUT UNBOOKED;
	ELSE OUTPUT BOOKED;
RUN;

DATA x y;
	SET BOOKED;
	BY BRACCTNO;
	IF FIRST.BRACCTNO & LAST.BRACCTNO THEN OUTPUT x;
	ELSE OUTPUT y;
RUN;

DATA y2;
	SET y;
	IF LOANTYPE = "Prequalify" THEN BRACCTNO = "";
	IF LOANTYPE = "Prequalify" THEN BOOKED = 0;
RUN;

DATA MADES_D;
	SET UNBOOKED x y2;
RUN;

DATA FINAL;
	SET MADES_D;

	IF BOOKED = 0 THEN DO;
		NETLOANAMOUNT = .;
		ENTDATE_SAS = .;
		TOTALLOANCOST = .;
		BRACCTNO = "";
		ENTYRMONTH = .;
	END;

	IF BOOKED = 1 THEN DO;
		TOTALLOANCOST = 80;
		BOOKED_MONTH = MONTH(ENTDATE_SAS);
	END;

	APPMONTH = MONTH(APPDATE_SAS);
	TOTALAPPS = 1;
	IF AMTREQUESTED < 5000 THEN COSTPERAPP = 2;
	ELSE COSTPERAPP = 3;
	COSTPERLOAN = 80;
RUN;

***CHECKS -------------------------------------------------------- ***;
PROC SQL;
	SELECT ENTYRMONTH, SUM(BOOKED) 
	FROM FINAL 
	GROUP BY 1;
QUIT;

DATA &APPS_MINUS_2_MO_AGO;
	SET MERGED_XX;
	IF APPYRMONTH NE &TWO_MO_AGO;
RUN;

DATA &ALL_APPS_FILE;
	SET &APPS_MINUS_2_MO_AGO FINAL;
RUN;

*** HERE WE ARE IDENTIFYING LOANS BOOKED THIS MONTH FROM LAST      ***;
*** MONTH'S APPLICATIONS ----------------------------------------- ***;
DATA &ONE_MO_BOOKED &ONE_MO_UNBOOKED;
	SET &ALL_APPS_FILE;
	IF APPYRMONTH = &ONE_MO_AGO;
	IF BOOKED = 1 THEN OUTPUT &ONE_MO_BOOKED;
	ELSE OUTPUT &ONE_MO_UNBOOKED;
RUN;

PROC SORT 
	DATA = VW_L; 
	BY SSNO1; 
RUN;

PROC SORT 
	DATA = &ONE_MO_UNBOOKED; 
	BY SSNO1;
RUN;

DATA MADES_A;
	MERGE &ONE_MO_UNBOOKED(IN = x) VW_L(IN = y);
	BY SSNO1;
	IF x = 1;
RUN;

DATA MADES_A;
	SET MADES_A;
	IF ENTDATE_SAS >= APPDATE_SAS - 1 AND 
	   ENTDATE_SAS <= APPDATE_SAS + 60 THEN BOOKED = 1;
	ELSE BOOKED = 0;
	IF BOOKED = 0 THEN BRACCTNO = "";
	IF OWNBR = "" THEN OWNBR = DWOWNBR;
RUN;

DATA MADES_A;
	SET MADES_A &ONE_MO_BOOKED;
RUN;

PROC SORT
	DATA = MADES_A;
	BY BRACCTNO LOANTYPE;
RUN;

DATA UNBOOKED BOOKED;
	SET MADES_A;
	IF BRACCTNO = "" THEN OUTPUT UNBOOKED;
	ELSE OUTPUT BOOKED;
RUN;

DATA x y;
	SET BOOKED;
	BY BRACCTNO;
	IF FIRST.BRACCTNO & LAST.BRACCTNO THEN OUTPUT x;
	ELSE OUTPUT y;
RUN;

DATA y2;
	SET y;
	IF LOANTYPE = "Prequalify" THEN BRACCTNO = "";
	IF LOANTYPE = "Prequalify" THEN BOOKED = 0;
RUN;

DATA MADES_D;
	SET UNBOOKED x y2;
RUN;

DATA FINAL;
	SET MADES_D;

	IF BOOKED = 0 THEN DO;
		NETLOANAMOUNT = .;
		ENTDATE_SAS = .;
		TOTALLOANCOST = .;
		BRACCTNO = "";
	END;

	IF BOOKED = 1 THEN DO;
		TOTALLOANCOST = 80;
		BOOKED_MONTH = MONTH(ENTDATE_SAS);
	END;

	APPMONTH = MONTH(APPDATE_SAS);
	TOTALAPPS = 1;
	IF AMTREQUESTED < 5000 THEN COSTPERAPP = 2;
	ELSE COSTPERAPP = 3;
	COSTPERLOAN = 80;
RUN;

DATA &APPS_MINUS_1_MO_AGO;
	SET &ALL_APPS_FILE;
	IF APPYRMONTH NE &ONE_MO_AGO;
RUN;

DATA &ALL_APPS_FILE_2;
	SET &APPS_MINUS_1_MO_AGO FINAL;
RUN;