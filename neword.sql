SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF

PROMPT **********  Order Entry Screen  **********
PROMPT

SELECT 'DATE: ', SYSDATE FROM DUAL;


DEFINE v_part_desc = 'Part Does Not Exist'
DEFINE v_part_qty = 'N/A'
DEFINE v_sup_address = 'Supplier Not Found'
DEFINE v_sup_city = 'N/A'
DEFINE v_sup_state = ''
DEFINE v_sup_zip = ''
DEFINE v_sup_phone = 'N/A'


ACCEPT v_part_num NUMBER FORMAT 999 PROMPT 'Enter Part Number (format 999): '




SELECT 
    'Part Description:  ' || part_description || chr(10) ||
    'Quantity on Hand: ' || part_qtyonhand
FROM part
WHERE part_num = &v_part_num;


ACCEPT v_supplier_code NUMBER FORMAT 999 PROMPT 'Enter Supplier Code (format 999): '


SELECT 
    'Address:  ' || supplier_address || chr(10) ||
    'City, State  Zip: ' || supplier_city || ', ' || supplier_state ||'  '|| supplier_zip || chr(10) ||
    'Phone: ' || supplier_phone
from supplier
where supplier_code = &v_supplier_code;


ACCEPT v_order_quant NUMBER PROMPT 'Enter Quantity to Order: '

DEFINE v_new_ord_num = (SELECT MAX(ord_num) +1 FROM ord);

INSERT INTO ord (ord_num, part_num, supplier_code, ord_qty, ord_date)
  VALUES ((SELECT MAX(ord_num) +1 FROM ord), &v_part_num, &v_supplier_code, &v_order_quant, TRUNC(SYSDATE));


--select
--    'Your order has been processed. Order number is: ' || &v_new_ord_num
--from ord
--where ord_num = &v_new_ord_num;