--  TUT 4 HANDS ON LAB
--  A. Asher
--  IS380 
--  Fall 2019

--  Prerequisite - folder c:\db exists
--  If you spool scripts without specifying a path, they are created in the same 
--    location as the executable file (sql.exe, sqlplus.exe, or sqldeveloper.exe).  See class notes.

--  Note:  Run the script from SQL Plus, SQLcl, or a new SQL Developer Worksheet as follows:
--  @ c:\db\tut4lab.sql  

--  This program creates an invoice for a customer
--  It prompts the user for a customer code and then 
--  creates an invoice.

--  SEQUENCE
--  You must create the following sequence.  It only needs to be created once.
--  So, it is commented out below.
--  CREATE SEQUENCE INVOICENUMBER
--  START WITH 1010;

-- Set environment variables
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF

-- This script uses CHR(13) || CHR(10) for a carriage return in our select statement output
-- Note: for SQL Plus can DEFINE NEWLINE as below (Called it "FOLDIT"). 
-- COLUMN FOLDIT NEWLINE
-- However, both SQL Plus and SQL Develper accept CHR(13) || CHR(10). 

PROMPT **********  Create New Order  **********
PROMPT
SELECT 'Date: ', TO_CHAR(SYSDATE,'MM/DD/YYYY') FROM DUAL;
PROMPT

-- CUSTOMER DATA ENTRY

-- Initialize variables (in case user enters non-existent customer)
DEFINE v_cus_lname = 'Customer Not Found'
DEFINE v_cus_fname = 'Customer Not Found'
DEFINE v_cus_phone = 'N/A'

-- Prompt user for customer code
ACCEPT v_cus_code NUMBER FORMAT 99999 PROMPT 'Enter Customer Code (format 99999): '

-- Create custinfo.sql file to define the following variables:
-- CUS_LNAME, CUS_FNAME, and CUS_PHONE (don't worry about area code for now)

-- Stop displaying info on screen
SET TERMOUT OFF  
SPOOL c:\db\custinfo.sql

SELECT 	'DEFINE v_cus_lname = ' || '''' || CUS_LNAME || '''' || CHR(13) || CHR(10) ||
	'DEFINE v_cus_fname = ' || '''' || CUS_FNAME || '''' || CHR(13) || CHR(10) ||
	'Define v_cus_phone = ' || '''' || CUS_PHONE || ''''
FROM	CUSTOMER
WHERE 	CUS_CODE = &v_cus_code;

SPOOL OFF

-- Start file created above
-- If you have timing issues in SQL Developer, wait for file to complete by adding a pause
--  as discussed in class (another option may be sleep)
--PAUSE "Retrieving Customer Information.  Please press the enter key"
START c:\db\custinfo

-- Display info to the screen again
SET TERMOUT ON  

-- Display data found to the user
-- Note: If the query returned ZERO records, variables have not changed,
--   That is, they stay as initialized above
PROMPT Customer Last Name   :  &v_cus_lname
PROMPT Customer First Name  :  &v_cus_fname
PROMPT Customer Phone Number:  &v_cus_phone

-- Create an invoice for the customer.  
-- Invoice number will be assigned by a sequence (next unique number in sequence)
-- As discussed above, must create a sequence to generate the next order number (ONLY DO ONCE)
-- CREATE SEQUENCE INVOICENUMBER
-- START WITH 1010;

INSERT INTO INVOICE (INV_NUMBER, CUS_CODE, INV_DATE)
   VALUES (INVOICENUMBER.NEXTVAL, &v_cus_code, TRUNC(SYSDATE));

-- FEEDBACK
-- Define a variable (v_inv_number) for the current invoice number in the sequence
-- that is, INVOICENUMBER.CURRVAL.  

SET TERMOUT OFF
SET ECHO OFF
SPOOL c:\db\invnum.sql

SELECT 	'DEFINE v_inv_number =' || INVOICENUMBER.CURRVAL
FROM	DUAL;

SPOOL OFF

-- If there is a timing issue in SQL Developer, wait for file to complete.
--PAUSE "Working on invoice.  Please press the enter key"
START c:\db\invnum
SET TERMOUT ON

-- Show feedback.  
--  Note: This will only work if the invoice number entry was successful!!!
--     If the insert fails, the program will crash and not get to this point.
--     If the insert failed and the program still got to this point, there would
--     be no user feedback since ZERO records will be returned from the query.
--     
SELECT 'Your invoice has been entered.  Invoice number is: ' || &v_inv_number
FROM  INVOICE
WHERE INV_NUMBER = &v_inv_number;

-- Reset environment variables
SET FEEDBACK ON
SET HEADING ON
SET VERIFY ON
