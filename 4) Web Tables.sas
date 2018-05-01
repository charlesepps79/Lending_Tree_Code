%LET APPMONTH = 4;
%LET BOOK_MONTH = 4;

TITLE;

PROC FORMAT;
	PICTURE PCTPIC(ROUND) LOW - HIGH = '09.00%';
RUN; 

PROC SORT 
	DATA = ALL_APPS_3;
	BY SOURCE;
RUN;

ODS EXCEL OPTIONS(SHEET_INTERVAL = "None");
TITLE "Month Summary";

PROC TABULATE 
	DATA = ALL_APPS_3;
	CLASS APPMONTH APPSTATE;
	VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
	TABLES APPSTATE ALL, 
		   TOTALAPPS * F = comma18.0
		   PREAPPROVED_FLAG = "# Auto Apprv" * F = comma18.0 
		   PREAPPROVED_FLAG = "% approve" * ROWPCTSUM < TOTALAPPS > * F
			= PCTPIC. / NOCELLMERGE;
	WHERE APPMONTH = &APPMONTH;
RUN;

PROC TABULATE 
	DATA = ALL_APPS_3;
	CLASS BOOKED_MONTH APPSTATE;
	VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
	TABLES APPSTATE ALL, 
		   BOOKED = "Booked" * F = comma18.0 
		   NETLOANAMOUNT = "$ Booked" * F = dollar18.0 
		   NETLOANAMOUNT * MEAN = "avg adv" * F = dollar18.0
			/ NOCELLMERGE;
WHERE BOOKED_MONTH = &BOOK_MONTH;
RUN;

TITLE "Web Apps";

PROC TABULATE 
	DATA = ALL_APPS_3;
	CLASS APPMONTH APPSTATE;
	VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
	TABLES APPSTATE ALL, 
		   TOTALAPPS * F = comma18.0 
		   PREAPPROVED_FLAG = "# Auto Apprv" * F = comma18.0 
		   PREAPPROVED_FLAG = "% approve" * ROWPCTSUM < TOTALAPPS > * F
			= PCTPIC. / NOCELLMERGE;
	BY SOURCE APPMONTH;
	WHERE SOURCE = 'Web Apps' & APPMONTH = &APPMONTH;
RUN;

PROC TABULATE 
	DATA = ALL_APPS_3;
	CLASS BOOKED_MONTH APPSTATE;
	VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
	TABLES APPSTATE ALL, 
		   BOOKED = "BOOKED" * F = comma18.0 
		   NETLOANAMOUNT = "$ BOOKED" * F = dollar18.0 
		   NETLOANAMOUNT * MEAN = "avg adv" * F = dollar18.0
			/ NOCELLMERGE;
	WHERE SOURCE = 'Web Apps' & BOOKED_MONTH = &BOOK_MONTH;
RUN;

TITLE "Lending Tree";

PROC TABULATE 
	DATA = ALL_APPS_3;
	CLASS APPMONTH APPSTATE;
	VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
	TABLES APPSTATE ALL, 
		   TOTALAPPS * F = comma18.0 
		   PREAPPROVED_FLAG = "# Auto Apprv" * F = comma18.0 
		   PREAPPROVED_FLAG = "% approve" * ROWPCTSUM < TOTALAPPS > * F
			= PCTPIC. / NOCELLMERGE;
	BY SOURCE;
	WHERE SOURCE = 'LendingTree' & APPMONTH = &APPMONTH;
RUN;

PROC TABULATE 
	DATA = ALL_APPS_3;
	CLASS BOOKED_MONTH APPSTATE;
	VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
	TABLES APPSTATE ALL, 
		   BOOKED = "BOOKED" * F = comma18.0 
		   NETLOANAMOUNT = "$ BOOKED" * F = dollar18.0 
		   NETLOANAMOUNT * MEAN = "avg adv" * F = dollar18.0
			/ NOCELLMERGE;
	WHERE SOURCE = 'LendingTree' & BOOKED_MONTH = &BOOK_MONTH;
RUN;

ODS EXCEL close;

*** BY VP AND SUPERVISOR ----------------------------------------- ***;
%LET APPMONTH = 4;
%LET BOOK_MONTH = 4;

PROC SORT 
	DATA = ALL_APPS_3;
	BY VP;
RUN;

ODS EXCEL OPTIONS(SHEET_INTERVAL="NONE");

PROC TABULATE 
	DATA = ALL_APPS_3 MISSING;
CLASS Supervisor vp APPMONTH APPSTATE;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPMONTH, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
WHERE SOURCE='Web Apps' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3 MISSING;
CLASS Supervisor vp APPMONTH APPSTATE;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPMONTH*Supervisor ALL, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
BY vp;
WHERE SOURCE='Web Apps' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3 MISSING;
CLASS Supervisor vp BOOKED_MONTH APPSTATE;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES BOOKED_MONTH*Supervisor ALL, BOOKED="BOOKED"*F=comma18.0 NETLOANAMOUNT="$ BOOKED"*F=dollar18.0 NETLOANAMOUNT*MEAN="avg adv"*F=dollar18.0/NOCELLMERGE;
BY vp;
WHERE SOURCE='Web Apps' & BOOKED_MONTH=&BOOK_MONTH;
RUN;
ODS EXCEL close;



ODS EXCEL OPTIONS(SHEET_INTERVAL="NONE");
PROC TABULATE DATA=ALL_APPS_3 MISSING;
CLASS Supervisor vp APPMONTH APPSTATE;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPMONTH, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
WHERE SOURCE='LendingTree' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3 MISSING;
CLASS Supervisor vp APPMONTH APPSTATE;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPMONTH*Supervisor ALL, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
BY vp;
WHERE SOURCE='LendingTree' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3 MISSING;
CLASS Supervisor vp BOOKED_MONTH APPSTATE;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES BOOKED_MONTH*Supervisor ALL, BOOKED="BOOKED"*F=comma18.0 NETLOANAMOUNT="$ BOOKED"*F=dollar18.0 NETLOANAMOUNT*MEAN="avg adv"*F=dollar18.0/NOCELLMERGE;
BY vp;
WHERE SOURCE='LendingTree' & BOOKED_MONTH=&BOOK_MONTH;
RUN;
ODS EXCEL close;




*BY amtbucket;
%LET APPMONTH=4;
%LET BOOK_MONTH=4;

ODS EXCEL;
TITLE "Lending Tree";
PROC TABULATE DATA=ALL_APPS_3;
CLASS APPMONTH APPSTATE AmtBucket;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES AmtBucket ALL, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
WHERE SOURCE='LendingTree' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3;
CLASS BOOKED_MONTH APPSTATE AmtBucket;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES AmtBucket ALL, BOOKED="BOOKED"*F=comma18.0 NETLOANAMOUNT="$ BOOKED"*F=dollar18.0 NETLOANAMOUNT*MEAN="avg adv"*F=dollar18.0 NETLOANAMOUNT*min="Bk Min $"*F=dollar18.0 NETLOANAMOUNT*max="Bk Max $"*F=dollar18.0/NOCELLMERGE;
WHERE SOURCE='LendingTree' & BOOKED_MONTH=&BOOK_MONTH;
PROC TABULATE DATA=ALL_APPS_3;
CLASS APPMONTH APPSTATE AmtBucket;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPSTATE*AmtBucket ALL, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
WHERE SOURCE='LendingTree' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3;
CLASS BOOKED_MONTH APPSTATE AmtBucket;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPSTATE*AmtBucket ALL, BOOKED="BOOKED"*F=comma18.0 NETLOANAMOUNT="$ BOOKED"*F=dollar18.0 NETLOANAMOUNT*MEAN="avg adv"*F=dollar18.0 NETLOANAMOUNT*min="Bk Min $"*F=dollar18.0 NETLOANAMOUNT*max="Bk Max $"*F=dollar18.0/NOCELLMERGE;
WHERE SOURCE='LendingTree' & BOOKED_MONTH=&BOOK_MONTH;
RUN;
ODS EXCEL close;


*Lt Filter Routing ID;
TITLE;
 PROC FORMAT;
PICTURE PCTPIC (ROUND) LOW-HIGH='09.00%';
RUN; 
PROC SORT DATA=ALL_APPS_3;
BY SOURCE;
RUN;
ODS EXCEL OPTIONS(SHEET_INTERVAL="NONE");
TITLE "Lending Tree";
PROC TABULATE DATA=ALL_APPS_3;
CLASS APPMONTH APPSTATE ltFilter_routingid;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPSTATE*ltFilter_routingid ALL, TOTALAPPS*F=comma18.0 PREAPPROVED_FLAG="# Auto Apprv"*F=comma18.0 PREAPPROVED_FLAG="% approve"*ROWPCTSUM<TOTALAPPS>*F=PCTPIC./NOCELLMERGE;
BY SOURCE;
WHERE SOURCE='LendingTree' & APPMONTH=&APPMONTH;
RUN;
PROC TABULATE DATA=ALL_APPS_3;
CLASS BOOKED_MONTH APPSTATE ltFilter_routingid;
VAR TOTALAPPS PREAPPROVED_FLAG BOOKED NETLOANAMOUNT;
TABLES APPSTATE*ltFilter_routingid ALL, BOOKED="BOOKED"*F=comma18.0 NETLOANAMOUNT="$ BOOKED"*F=dollar18.0 NETLOANAMOUNT*MEAN="avg adv"*F=dollar18.0/NOCELLMERGE;
WHERE SOURCE='LendingTree' & BOOKED_MONTH=&BOOK_MONTH;
RUN;
ODS EXCEL close;