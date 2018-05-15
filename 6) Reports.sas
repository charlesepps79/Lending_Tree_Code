PROC SQL;
   CREATE TABLE WORK.REPORTS_TABLE AS 
   SELECT *
      FROM WORK.ALL_APPS_3 t1;
QUIT;

DATA REPORTS_TABLE;
	SET REPORTS_TABLE;
	IF SOURCE = "LendingTree" THEN 
		TOTALAPPCOST = TOTALAPPS * COSTPERAPP;
RUN;

PROC SQL;
   CREATE TABLE WORK.OWNER_TYPE AS 
   SELECT t1.'Application Number'n AS APPNUMBER, 
          t1.'Applicant Address Ownership'n, 
          t1.'Loan Request Purpose'n
      FROM WORK.AIP_INPUT t1
      ORDER BY t1.'Application Number'n;
QUIT;

PROC SQL;
	CREATE TABLE WORK.REPORTS_TABLE_2 AS 
	SELECT t1.*, t2.APPNUMBER, t2.'Applicant Address Ownership'n, 
		   t2.'Loan Request Purpose'n
	FROM WORK.REPORTS_TABLE t1 
		LEFT JOIN WORK.OWNER_TYPE t2 ON t1.APPNUMBER=t2.APPNUMBER;
QUIT;

PROC SQL;
	CREATE TABLE WORK.REPORTS_TABLE_3 AS 
	SELECT t1.*, t2.old_bracctno, t2.old_AmtPaidLast, t2.renew_bracctno
	FROM WORK.REPORTS_TABLE_2 t1 
		LEFT JOIN WORK.ALL_APP9 t2 ON t1.BrAcctNo=t2.renew_bracctno;
QUIT;

DATA REPORTS_TABLE;
	SET REPORTS_TABLE_3;
	old_AmtPaidLast = SUM(old_AmtPaidLast, 0);
	renew_amt = 0;
	IF renew_bracctno NE "" THEN RENEW_FLAG = 1;
	ELSE RENEW_FLAG = 0;
	IF RENEW_FLAG = 1 THEN renew_amt = NetLoanAmount - old_AmtPaidLast;
	NEW_AMT = 0;
	IF RENEW_FLAG = 0 THEN NEW_AMT = NetLoanAmount;
	TOTALAPPS_CURRENT = 0;
	PREAPPROV_CURRENT = 0;
	BOOKED_CURRENT = 0;
	NETLOANAMT_CURRENT = 0;
	RENEW_AMT_CURRENT = 0;
	NEW_AMT_CURRENT = 0;
	OLD_AMTPAIDLAST_CURRENT = 0;
	TOTALAPPCOST_CURRENT = 0;
	TOTALLOANCOST_CURRENT = 0;
	RENEW_FLAG_CURRENT = 0;

	IF APPYRMONTH = 201804 THEN DO;
		TOTALAPPS_CURRENT = TOTALAPPS;
		PREAPPROV_CURRENT = PREAPPROVED_FLAG;
		TOTALAPPCOST_CURRENT = TOTALAPPCOST;
	END;

	IF ENTYRMONTH = 201804 THEN DO;
		BOOKED_CURRENT = BOOKED;
		NETLOANAMT_CURRENT = NetLoanAmount;
		TOTALLOANCOST_CURRENT = TOTALLOANCOST;
		RENEW_AMT_CURRENT = renew_amt;
		RENEW_FLAG_CURRENT = RENEW_FLAG;
		NEW_AMT_CURRENT = NEW_AMT;
		OLD_AMTPAIDLAST_CURRENT = OLD_AMTPAIDLAST;
	END;
RUN;

PROC SQL;
   CREATE TABLE LT_BY_BRANCH AS 
   SELECT t1.VP, 
          t1.Supervisor, 
          t1.OWNBR, 
          /* Total Apps */
            (SUM(t1.TOTALAPPS_CURRENT)) AS 'Total Apps'n, 
          /* #PQ */
            (SUM(t1.PREAPPROV_CURRENT)) AS '#PQ'n, 
          /* % PQ */
            ((SUM(t1.PREAPPROV_CURRENT)) / (SUM(t1.TOTALAPPS_CURRENT)))
				FORMAT=PERCENT8.2 AS '% PQ'n, 
          /* Booked */
            (SUM(t1.BOOKED_CURRENT)) AS Booked, 
          /* Book Rate */
            ((SUM(t1.BOOKED_CURRENT)) / (SUM(t1.TOTALAPPS_CURRENT)))
				FORMAT=PERCENT8.2 AS 'Book Rate'n, 
          /* PQ Book Rate */
            ((SUM(t1.BOOKED_CURRENT)) / (SUM(t1.PREAPPROV_CURRENT))) 
				FORMAT=PERCENT8.2 AS 'PQ Book Rate'n, 
          /* $ Total Adv */
            (SUM(t1.NETLOANAMT_CURRENT)) 
				FORMAT=DOLLAR8. AS '$ Total Adv'n, 
          /* Sum_New_Amt_Current */
            (SUM(t1.NEW_AMT_CURRENT)) AS Sum_New_Amt_Current, 
          /* Sum_Renew_Amt_Current */
            (SUM(t1.RENEW_AMT_CURRENT)) AS Sum_Renew_Amt_Current, 
          /* $ Net Adv */
            ( (SUM(t1.NEW_AMT_CURRENT)) + (SUM(t1.RENEW_AMT_CURRENT)))
				FORMAT=DOLLAR8. AS '$ Net Adv'n, 
          /* avg adv */
            (( (SUM(t1.NEW_AMT_CURRENT)) + 
				(SUM(t1.RENEW_AMT_CURRENT))) / 
				(SUM(t1.BOOKED_CURRENT))) 
				FORMAT=DOLLAR8. AS 'avg adv'n,
          /* Sum_Renewal_Flag */
            (SUM(t1.RENEW_FLAG_CURRENT)) AS Sum_Renewal_Flag, 
          /* % Renewal */
            ((SUM(t1.RENEW_FLAG_CURRENT)) / (SUM(t1.BOOKED_CURRENT)))
				FORMAT=PERCENT8.2 AS '% Renewal'n, 
          /* # Renewal */
            (SUM(t1.RENEW_FLAG_CURRENT)) AS '# Renewal'n, 
          /* $ Renew */
            (SUM(t1.RENEW_AMT_CURRENT)) FORMAT=DOLLAR8. AS '$ Renew'n, 
          /* Total App Cost */
            (SUM(t1.TOTALAPPCOST_CURRENT))
				FORMAT=DOLLAR8. AS 'Total App Cost'n, 
          /* Cost Per Loan */
            (AVG(t1.COSTPERLOAN)) FORMAT=DOLLAR8. AS 'Cost Per Loan'n, 
          /* Total Loan Cost */
            (SUM(t1.TOTALLOANCOST_CURRENT)) 
				FORMAT=DOLLAR8. AS 'Total Loan Cost'n, 
          /* Total Cost */
            ((SUM(t1.TOTALLOANCOST_CURRENT)) + 
				(SUM(t1.TOTALAPPCOST_CURRENT))) 
				FORMAT=DOLLAR8. AS 'Total Cost'n, 
          /* CPK */
            (((SUM(t1.TOTALLOANCOST_CURRENT)) + 
				(SUM(t1.TOTALAPPCOST_CURRENT))) / 
				( (SUM(t1.NEW_AMT_CURRENT)) + 
            	(SUM(t1.RENEW_AMT_CURRENT))) * 1000) 
				FORMAT=DOLLAR8. AS CPK
      FROM REPORTS_TABLE t1
      WHERE t1.SOURCE = 'LendingTree'
      GROUP BY t1.VP,
               t1.Supervisor,
               t1.OWNBR;
QUIT;

DATA LENDING_TREE_BY_BRANCH;
	SET LENDING_TREE_BY_BRANCH;
	DROP Sum_New_Amt_Current Sum_Renew_Amt_Current Sum_Renewal_Flag;
RUN;

PROC SQL;
   CREATE TABLE LT_BY_STATE_R_ID_AMT_BUCKET AS 
   SELECT t1.APPSTATE, 
          t1.LTFILTER_ROUTINGID, 
          t1.AMTBUCKET, 
          /* Total Apps */
            (SUM(t1.TOTALAPPS_CURRENT)) AS 'Total Apps'n, 
          /* # PQ */
            (SUM(t1.PREAPPROV_CURRENT)) AS '# PQ'n, 
          /* % PQ */
            ((SUM(t1.PREAPPROV_CURRENT)) / (SUM(t1.TOTALAPPS_CURRENT)))
				FORMAT=PERCENT8.2 AS '% PQ'n, 
          /* Booked */
            (SUM(t1.BOOKED_CURRENT)) AS Booked, 
          /* Book Rate */
            ((SUM(t1.BOOKED_CURRENT)) / (SUM(t1.TOTALAPPS_CURRENT)))
				FORMAT=PERCENT8.2 AS 'Book Rate'n, 
          /* PQ Book Rate */
            ((SUM(t1.BOOKED_CURRENT)) / (SUM(t1.PREAPPROV_CURRENT)))
				FORMAT=PERCENT8.2 AS 'PQ Book Rate'n, 
          /* $ Total Adv */
            (SUM(t1.NETLOANAMT_CURRENT))
				FORMAT=DOLLAR12. AS '$ Total Adv'n, 
          /* $ Net Adv */
            ((SUM(t1.NEW_AMT_CURRENT)) + (SUM(t1.RENEW_AMT_CURRENT)))
				FORMAT=DOLLAR12. AS '$ Net Adv'n, 
          /* Avg Adv. */
            (((SUM(t1.NEW_AMT_CURRENT)) +
				(SUM(t1.RENEW_AMT_CURRENT))) /
				(SUM(t1.BOOKED_CURRENT)))
				FORMAT=DOLLAR12. AS 'Avg Adv.'n, 
          /* % Renewal */
            ((SUM(t1.RENEW_FLAG_CURRENT)) / (SUM(t1.BOOKED_CURRENT))) 
				FORMAT=PERCENT8.2 AS '% Renewal'n, 
          /* # Renewal */
            (SUM(t1.RENEW_FLAG_CURRENT)) AS '# Renewal'n, 
          /* $ Renew */
            (SUM(t1.RENEW_AMT_CURRENT)) FORMAT=DOLLAR12. AS '$ Renew'n,
          /* Total App Cost */
            (SUM(t1.TOTALAPPCOST_CURRENT))
				FORMAT=DOLLAR12. AS 'Total App Cost'n, 
          /* Cost per Loan */
            (AVG(t1.COSTPERLOAN)) FORMAT=DOLLAR12. AS 'Cost per Loan'n,
          /* Total Loan Cost */
            (SUM(t1.TOTALLOANCOST_CURRENT))
				FORMAT=DOLLAR12. AS 'Total Loan Cost'n, 
          /* Total Cost */
            ((SUM(t1.TOTALAPPCOST_CURRENT)) +
				(SUM(t1.TOTALLOANCOST_CURRENT)))
				FORMAT=DOLLAR12. AS 'Total Cost'n, 
          /* CPK */
            (((SUM(t1.TOTALAPPCOST_CURRENT)) +
				(SUM(t1.TOTALLOANCOST_CURRENT))) /
				((SUM(t1.NEW_AMT_CURRENT)) +
				(SUM(t1.RENEW_AMT_CURRENT))) * 1000)
				FORMAT=DOLLAR12. AS CPK
      FROM REPORTS_TABLE t1
      WHERE t1.SOURCE = 'LendingTree'
      GROUP BY t1.APPSTATE,
               t1.LTFILTER_ROUTINGID,
               t1.AMTBUCKET
      ORDER BY t1.APPSTATE,
               t1.LTFILTER_ROUTINGID,
               t1.AMTBUCKET;
QUIT;

PROC SQL;
   CREATE TABLE WEB_BY_BRANCH AS 
   SELECT t1.VP, 
          t1.Supervisor, 
          t1.OWNBR, 
          /* Total Apps */
            (SUM(t1.TOTALAPPS_CURRENT)) AS 'Total Apps'n, 
          /* #PQ */
            (SUM(t1.PREAPPROV_CURRENT)) AS '#PQ'n, 
          /* % PQ */
            ((SUM(t1.PREAPPROV_CURRENT)) / (SUM(t1.TOTALAPPS_CURRENT)))
				FORMAT=PERCENT8.2 AS '% PQ'n, 
          /* Booked */
            (SUM(t1.BOOKED_CURRENT)) AS Booked, 
          /* Book Rate */
            ((SUM(t1.BOOKED_CURRENT)) / (SUM(t1.TOTALAPPS_CURRENT)))
				FORMAT=PERCENT8.2 AS 'Book Rate'n, 
          /* PQ Book Rate */
            ((SUM(t1.BOOKED_CURRENT)) / (SUM(t1.PREAPPROV_CURRENT))) 
				FORMAT=PERCENT8.2 AS 'PQ Book Rate'n, 
          /* $ Total Adv */
            (SUM(t1.NETLOANAMT_CURRENT)) 
				FORMAT=DOLLAR8. AS '$ Total Adv'n, 
          /* Sum_New_Amt_Current */
            (SUM(t1.NEW_AMT_CURRENT)) AS Sum_New_Amt_Current, 
          /* Sum_Renew_Amt_Current */
            (SUM(t1.RENEW_AMT_CURRENT)) AS Sum_Renew_Amt_Current, 
          /* $ Net Adv */
            ( (SUM(t1.NEW_AMT_CURRENT)) + (SUM(t1.RENEW_AMT_CURRENT)))
				FORMAT=DOLLAR8. AS '$ Net Adv'n, 
          /* avg adv */
            (( (SUM(t1.NEW_AMT_CURRENT)) + 
				(SUM(t1.RENEW_AMT_CURRENT))) / 
				(SUM(t1.BOOKED_CURRENT))) 
				FORMAT=DOLLAR8. AS 'avg adv'n,
          /* Sum_Renewal_Flag */
            (SUM(t1.RENEW_FLAG_CURRENT)) AS Sum_Renewal_Flag, 
          /* % Renewal */
            ((SUM(t1.RENEW_FLAG_CURRENT)) / (SUM(t1.BOOKED_CURRENT)))
				FORMAT=PERCENT8.2 AS '% Renewal'n, 
          /* # Renewal */
            (SUM(t1.RENEW_FLAG_CURRENT)) AS '# Renewal'n, 
          /* $ Renew */
            (SUM(t1.RENEW_AMT_CURRENT)) FORMAT=DOLLAR8. AS '$ Renew'n, 
          /* Total App Cost */
            (SUM(t1.TOTALAPPCOST_CURRENT))
				FORMAT=DOLLAR8. AS 'Total App Cost'n, 
          /* Cost Per Loan */
            (AVG(t1.COSTPERLOAN)) FORMAT=DOLLAR8. AS 'Cost Per Loan'n, 
          /* Total Loan Cost */
            (SUM(t1.TOTALLOANCOST_CURRENT)) 
				FORMAT=DOLLAR8. AS 'Total Loan Cost'n, 
          /* Total Cost */
            ((SUM(t1.TOTALLOANCOST_CURRENT)) + 
				(SUM(t1.TOTALAPPCOST_CURRENT))) 
				FORMAT=DOLLAR8. AS 'Total Cost'n, 
          /* CPK */
            (((SUM(t1.TOTALLOANCOST_CURRENT)) + 
				(SUM(t1.TOTALAPPCOST_CURRENT))) / 
				( (SUM(t1.NEW_AMT_CURRENT)) + 
            	(SUM(t1.RENEW_AMT_CURRENT))) * 1000) 
				FORMAT=DOLLAR8. AS CPK
      FROM REPORTS_TABLE t1
      WHERE t1.SOURCE = 'Web Apps'
      GROUP BY t1.VP,
               t1.Supervisor,
               t1.OWNBR;
QUIT;