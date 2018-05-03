
%let loan_entdate_begin1 = "2010-01-01"; /*Do not change*/
%let loan_entdate_end1 = "2018-03-31"; /*Change to end of the month*/   

/*Pull loan table*/
data vw_Loantable;
set dw.vw_loan (keep= ssno1_rt7 bracctno id ownbr ssno1 ssno2 lnamt finchg loantype loandate entdate classid 
classtranslation netloanamount orgst aprate
srcd pocd poffdate pldate PrLnNo plamt bnkrptdate conprofile1 conprofile2 datepaidlast PLCD orgbr AmtPaidLast 
OldAcctNo  );
where &loan_entdate_begin1. <=entdate<= &loan_entdate_end1. ;
entdate_sas = input(entdate, yymmdd10.);
format entdate_sas date9.;
if pocd="**" then delete;
if pocd="BT" then delete;
run;

proc export data=vw_Loantable outfile="&MAIN_DIR\vw_Loantable.xlsx" dbms=excel replace;
run;

/*Subset for current month bookings*/
proc sql;
create table 
jan_book as
select * from allapps3 where entyrmonth in (201803) ;quit; /*Change*/

/*Subeset for non 'NB' and 'FB' customer type*/
proc sql;
create table all_app4 as
select entyrmonth,bracctno,netloanamount,ClassTranslation as ClassTranslation1 from jan_book 
where srcd not in ('NB','FB') and entyrmonth in (201803) and booked = 1; 
QUIT;

/*Checks*/
proc sql;
create table abc as 
select entyrmonth, count(*) from all_app4 group by 1;
quit;

/*QC*/
PROC SQL;
SELECT entyrmonth,sum (booked) from jan_book where appyrmonth in (201803) group by 1; /*Change*/
quit;

/*Join with loan table*/
PROC SQL;
CREATE TABLE ALL_APP5 AS 
SELECT A.*,b.ssno1,b.netloanamount as netloanamount_b ,b.OwnBr,b.ClassID,b.ClassTranslation,b.POCD,b.PLCD,b.PlDate,b.POffDate,b.LnAmt,b.FinChg,b.PrLnNo,b.AmtPaidLast,b.OldAcctNo,
b.OrgBr,b.LoanType as loantype_pi,b.orgst from all_app4 a 
left join vw_Loantable b 
on a.bracctno = b.bracctno;
quit;

/*Finding old bracctno*/
PROC SQL;
CREATE TABLE ALL_APP6 AS
SELECT *,
case when length(ownbr) = 1 then '000'||ownbr
           when length(ownbr) = 2 then '00'||ownbr
           when length(ownbr) = 3 then '0'||ownbr
           when length(ownbr) = 4 then ownbr
                when length(ownbr) > 4 then ownbr else ownbr end as new_ownbr from ALL_APP5; quit;

PROC SQL;
CREATE TABLE ALL_APP7 AS
SELECT *, length(PrLnNo) as prln_length,case when orgst in ('OK','SC') and length(PrLnNo) = 9 then '0'||PrLnNo
           when length(PrLnNo) = 1 then new_ownbr||substr(('0000000'||PrLnNo),1,6)
           when length(PrLnNo) = 2 then new_ownbr||substr(('000000'||PrLnNo),1,6)
           when length(PrLnNo) = 3 then new_ownbr||substr(('00000'||PrLnNo),1,6)
           when length(PrLnNo) = 4 then new_ownbr||substr(('0000'||PrLnNo),1,6)
           when length(PrLnNo) = 5 then new_ownbr||substr(('000'||PrLnNo),1,6)
           when length(PrLnNo) = 6 then new_ownbr||substr(('00'||PrLnNo),1,6)
           when length(PrLnNo) = 7 then new_ownbr||substr(('0'||PrLnNo),1,6)
           when length(PrLnNo) = 8 then new_ownbr||substr((''||PrLnNo),1,6)
           when length(PrLnNo) = 9 then PrLnNo||'0'
                when length(PrLnNo) = 10 then PrLnNo 
           when length(PrLnNo) = 11 then PrLnNo  
           when length(PrLnNo) = 12 then PrLnNo 
           when length(PrLnNo) = 22 then substr(PrLnNo,max(1,length(PrLnNo)-10+1),10)

           when length(PrLnNo) = 24 then substr(PrLnNo,max(1,length(PrLnNo)-12+1),12)
           when length(PrLnNo) = 26 then substr(PrLnNo,max(1,length(PrLnNo)-12+1),12)
           when length(PrLnNo) = 28 then substr(PrLnNo,max(1,length(PrLnNo)-12+1),12)
           when length(PrLnNo) >= 34 then substr(PrLnNo,max(1,length(PrLnNo)-10+1),10) else PrLnNo end as old_bracctno FROM ALL_APP6;
           QUIT;

/*Final Dataset with renewed loans*/ 
proc sql;
create table ALL_APP8 as 
select a.entyrmonth, a.bracctno as renew_bracctno, 
a.netloanamount_b as renew_netlonamount,
a.classtranslation,
a.AmtPaidLast,
a.orgst,
a.old_bracctno as old_bracctno1,
b.bracctno as old_bracctno,
b.srcd as old_srcd,
b.ClassID  as old_ClassID,
b.AmtPaidLast as old_AmtPaidLast

from 
ALL_APP7 a 
left join vw_Loantable b
on a.old_bracctno=b.bracctno; 
quit;

/*proc print*/
/*data=ALL_APP9; */
/*run;*/

data ALL_APP9;
set ALL_APP8;
renew_amt = renew_netlonamount-old_AmtPaidLast;
run;

proc export data=ALL_APP9 outfile="&MAIN_DIR\ALL_APP9.xlsx" dbms=excel replace;
run;

proc sql;
create table abc as 
select entyrmonth,count(*), sum(renew_amt) from ALL_APP9 
where old_bracctno is not null and renew_amt > 0
group by 1; 
quit; 

proc sql; select sum(renew_amt) from ALL_APP9 ; quit;

PROC SQL;
CREATE TABLE ALL_APP10 AS 
SELECT A.*, B.old_bracctno1, B.renew_bracctno,B.renew_netlonamount,B.old_AmtPaidLast,B.renew_amt
from allapps3 a left join ALL_APP9 b on a.bracctno = b.renew_bracctno; QUIT;

PROC SQL;
CREATE TABLE CHK1 AS 
SELECT * FROM ALL_APP10 WHERE BOOKED = 1 AND renew_bracctno IS NOT NULL and appyrmonth in (201803); QUIT;