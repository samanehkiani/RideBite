/*
    Staging deployment order for Bonus Section #2 (Excel Import/Export).
    Execute these scripts in SSMS after the main RideBite database scripts.
*/

:r Staging_Tables.sql
:r Staging_Procedures.sql
:r Staging_EnableBulkImport.sql

PRINT '=== Staging layer deployed. Run Staging_Demo.sql or import/export scripts next. ===';
