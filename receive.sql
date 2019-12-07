SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF

SELECT 'Date: ' || SYSDATE from DUAL;

ACCEPT v_order_num NUMBER FORMAT 9999 PROMPT "Enter Order Number to Receive (format 9999): "

DEFINE v_ord_recdate = null

SET TERMOUT OFF
SPOOL ./qty_ordered.sql

SELECT 
    'DEFINE v_ord_found =  ' || '''' || 'Order Found. Verify the following:'|| '''' || chr(10) || 
    'DEFINE v_part_num = ' || '''' || part.part_num || '''' || chr(10) ||
    'DEFINE v_part_description = ' || '''' || part.part_description || '''' || chr(10) ||
    'DEFINE v_part_qtyonhand  = ' ||'''' || part.part_qtyonhand || '''' || chr(10)||
    'DEFINE v_supplier_code = ' || '''' || supplier.supplier_code || '''' || chr(10) ||
    'DEFINE v_supplier_name = ' || '''' || supplier.supplier_name || '''' || chr(10) ||
    'DEFINE v_ord_date = ' || '''' || ord.ord_date || '''' || chr(10) ||
    'DEFINE v_ord_recdate = ' || '''' || ord.ord_recdate || '''' || chr(10) ||
    'DEFINE v_ord_qty = ' || '''' || ord.ord_qty || ''''
FROM 
    ord INNER JOIN part ON ord.part_num = part.part_num
        INNER JOIN supplier ON ord.supplier_code = supplier.supplier_code
WHERE 
    ord.ord_num = &v_order_num;

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
    'DEFINE v_newqty= ' || '''' || DECODE (ord.ord_recdate, NULL, part.part_qtyonhand + ord.ord_qty
                                           , part.part_qtyonhand) ||  ''''
FROM 
    part INNER JOIN ord ON part.part_num = ord.part_num
WHERE 
    ord_num = &v_order_num;

SPOOL OFF
SET TERMOUT ON

@ ./newqty.sql

UPDATE part
set part_qtyonhand = &v_ord_qty
where part_num = (select part_num from ord where ord_num = &v_order_num)

update ord
set 
    ord_recdate = trunc(sysdate),
    ord_recqty = &v_ord_qty
where ord_num = &v_order_num
and ord_recdate is null

SELECT 
    'New Quantity in Stock: ' || part.part_qtyonhand
FROM 
    part INNER JOIN ord ON part.part_num = ord.part_num
WHERE
    ord.ord_num = &v_order_num;
