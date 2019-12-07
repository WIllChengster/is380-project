SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF

SELECT 'Date: ' || SYSDATE from DUAL;

DEFINE v_ord_found = 'ORDER NOT FOUND!!! Rerun the program!!!'
DEFINE v_part_num = 'N/A'
DEFINE v_part_description = 'N/A'
DEFINE v_part_qtyonhand = 'N/A'
DEFINE v_supplier_code = 'N/A'
DEFINE v_supplier_name = 'N/A'
DEFINE v_ord_date = 'N/A'
DEFINE v_ord_recdate ='N/A'
DEFINE v_ord_qty = 'N/A'

ACCEPT v_ord_num NUMBER FORMAT 9999 PROMPT "Enter Order Number to Receive (format 9999): "

SET TERMOUT OFF
SPOOL ./qty_ordered.sql

SELECT 
    'DEFINE v_ord_found =  ' || '''' || 'Order Found. Verify the following:'|| '''' || chr(10) || 
    'DEFINE v_part_num = ' ||  part.part_num  || chr(10) ||
    'DEFINE v_part_description = ' || '''' || part.part_description || '''' || chr(10) ||
    'DEFINE v_part_qtyonhand  = ' || part.part_qtyonhand ||  chr(10)||
    'DEFINE v_supplier_code = ' ||  supplier.supplier_code ||  chr(10) ||
    'DEFINE v_supplier_name = ' || '''' || supplier.supplier_name || '''' || chr(10) ||
    'DEFINE v_ord_date = ' || '''' || ord.ord_date || '''' || chr(10) ||
    'DEFINE v_ord_recdate = ' || '''' || ord.ord_recdate || '''' || chr(10) ||
    'DEFINE v_ord_qty = ' || ord.ord_qty 
FROM 
    ord INNER JOIN part ON ord.part_num = part.part_num
        INNER JOIN supplier ON ord.supplier_code = supplier.supplier_code
WHERE 
    ord.ord_num = &v_ord_num;

SPOOL OFF
SET TERMOUT ON


@ ./qty_ordered.sql

PROMPT
PROMPT &v_ord_found
PROMPT
PROMPT Part Number               : &v_part_num
PROMPT Part Description          : &v_part_description
PROMPT Current Inventory Quantity: &v_part_qtyonhand
PROMPT
PROMPT Supplier Code: &v_supplier_code
PROMPT Supplier Name: &v_supplier_name
PROMPT
PROMPT Date Ordered    : &v_ord_date
PROMPT Date Received   : &v_ord_recdate
PROMPT Quantity Ordered: &v_ord_qty
PROMPT
PROMPT ** Again, verify order information: ** 
PROMPT ** In case of discrepancy (Order not found, Wrong quantity, etc.) **
PROMPT ** Press [CTRL] [C] twice to ABORT **

PAUSE "** If correct, press [ENTER] to continue **"


SET TERMOUT off

SPOOL ./newqty.sql

SELECT 
    'DEFINE v_newqty= ' || DECODE (ord.ord_recdate, NULL, part.part_qtyonhand + ord.ord_qty
                                           , part.part_qtyonhand) 
FROM 
    part INNER JOIN ord ON part.part_num = ord.part_num
WHERE 
    ord_num = &v_ord_num;

SPOOL OFF
SET TERMOUT ON

@ ./newqty.sql

UPDATE part
SET part_qtyonhand = &v_newqty
WHERE part_num = (SELECT part_num FROM ord WHERE ord_num = &v_ord_num);


UPDATE ord
SET 
    ord_recdate = TRUNC(SYSDATE),
    ord_recqty = &v_ord_qty
WHERE ord_num = &v_ord_num
AND ord_recdate IS NULL;

SELECT 
    'New Quantity in Stock: ' || part.part_qtyonhand
FROM 
    part INNER JOIN ord ON part.part_num = ord.part_num
WHERE
    ord.ord_num = &v_ord_num;
    
COMMIT;

SET FEEDBACK ON
SET VERIFY ON
SET HEADING ON
