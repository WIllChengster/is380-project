SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF

PROMPT ********  Update Part Information  **********

DEFINE warn = 'PART NUMBER NOT FOUND!!! Rerun the program!!!'
DEFINE v_part_description = 'N/A'
DEFINE v_part_qtyonhand = 'N/A'



ACCEPT v_part_num NUMBER FORMAT 999 PROMPT 'Enter Part Number to Update (format 999): '

SET TERMOUT OFF
SPOOL ./part_details.sql

SELECT 
    'DEFINE warn = ' || '''' || 'Part Number Found. Below is the current information: ' || '''' || chr(10) ||
    'DEFINE v_part_description = ' || '''' || PART_DESCRIPTION || '''' || chr(10) ||
    'DEFINE v_part_qtyonhand = '   ||  PART_QTYONHAND || chr(10) 
FROM PART
WHERE PART_NUM = &v_part_num;

SPOOL OFF
SET TERMOUT ON

@ ./part_details.sql

PROMPT &warn
PROMPT Part Description          : &v_part_description
PROMPT Current Inventory Quantity:  &v_part_qtyonhand

PROMPT ** Verify part information:                            **
PROMPT ** If you DON'T want to update OR Part NOT FOUND,      **
PROMPT **    Press [CTRL] [C] twice to ABORT                  **
PROMPT ** If you wish to continue and update, press [ENTER]   **
PROMPT

PROMPT Type New Description or press [Enter] to accept current description
ACCEPT v_new_desc CHAR PROMPT '(Current Description: &v_part_description): ' DEFAULT '&v_part_description'
PROMPT

PROMPT Type New Quantity or press [ENTER] to accept current inventory quantity
ACCEPT v_new_qty NUMBER PROMPT '(Current Inventory Quantity: &v_part_qtyonhand): ' DEFAULT '&v_part_qtyonhand'
PROMPT

UPDATE part
SET part_description = '&v_new_desc',
    part_qtyonhand = '&v_new_qty'
WHERE part_num = &v_part_num;
PROMPT Updated Part Number Information:
SELECT 'Part Number               : ' || part_num,
       'Part Description          : ' ||  part_description,
       'Current Inventory Quantity: ' || part_qtyonhand
FROM part
WHERE part_num = &v_part_num;
COMMIT;