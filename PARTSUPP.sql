TTITLE CENTER "-------- Parts Inventory Level and Supplier Report -------- Page:" SQL.PNO SKIP 2
BREAK ON part_num ON part_description ON part_qtyonhand SKIP 1

SET LINESIZE 100
SET PAGESIZE 60

COLUMN part_num HEADING "Part|No."
COLUMN part_description HEADING "Description"
COLUMN part_qtyonhand HEADING "Qty In|Stock"
COLUMN supplier_code HEADING "Supplier|Code"
COLUMN supplier_name HEADING "Supplier|Name"
COLUMN "Supplier Phone" HEADING "Supplier|Phone"

SELECT p.part_num, part_description, part_qtyonhand, s.supplier_code, supplier_name, 
       '(' || supplier_areacode ||') ' || supplier_phone AS "Supplier Phone"
FROM part p
  INNER JOIN supppart t  ON p.part_num = t.part_num
  INNER JOIN supplier s  ON s.supplier_code = t.supplier_code
ORDER BY p.part_num, s.supplier_code;

 