SET LINESIZE 100
SET PAGESIZE 60


TTITLE LEFT COL 10 "-------- Supplier's Order Status Report -------- Page:" SQL.PNO SKIP 2
BREAK ON supplier_code SKIP 1 ON supplier_name
COMP AVG LABEL 'Avg Days' OF "Number of Days" ON supplier_code 

COLUMN supplier_code HEADING "Supplier|Code"
COLUMN supplier_name HEADING "Supplier|Name"
COLUMN "Number of Days" FORMAT 999.99 HEADING "Number|of Days"
COLUMN ord_num HEADING "Order|No."
COLUMN "Order Date" HEADING "Order|Date"
COLUMN "Receive Date" HEADING "Receive|Date"

SELECT s.supplier_code, supplier_name, ord_num, TO_CHAR(ord_date, 'MM/DD/YY') "Order Date", TO_CHAR(ord_recdate, 'MM/DD/YY') "Receive Date", ord_recdate - ord_date AS "Number of Days",
       DECODE(ord_recdate, NULL, 'Open', 'Complete') "STATUS"
FROM supplier s INNER JOIN ord o ON s.supplier_code = o.supplier_code
ORDER BY s.supplier_code, ord_num;