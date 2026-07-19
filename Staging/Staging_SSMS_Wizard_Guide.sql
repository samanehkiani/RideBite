USE RideBite;
GO

/*
================================================================================
 Bonus Section #2 - Method 1: SSMS Import/Export Wizard (Graphical Interface)
================================================================================

Prerequisites:
  - SQL Server Management Studio (SSMS)
  - RideBite database deployed (CreateDatabase + schemas + FoodService tables)
  - Staging objects deployed (Staging_Tables.sql + Staging_Procedures.sql)
  - Sample files in: C:\Users\MINA\Desktop\RideBite\Staging\

--------------------------------------------------------------------------------
A) IMPORT Excel -> Staging.Categories
--------------------------------------------------------------------------------
1. Open SSMS and connect to your SQL Server instance.
2. Expand Databases -> RideBite.
3. Right-click RideBite -> Tasks -> Import Data...
4. Source:
     - Data source: Microsoft Excel
     - Excel file path: C:\Users\MINA\Desktop\RideBite\Staging\categories.xlsx
     - Excel version: Microsoft Excel 2007 or later
     - Check "First row has column names"
5. Destination:
     - Server: (local instance)
     - Database: RideBite
6. Select "Copy data from one or more tables or views".
7. Source sheet: Categories$  -> Destination: [Staging].[Categories]
8. Click "Edit Mappings":
     - Map Excel CategoryName -> Staging.CategoryName
     - Map Excel Description  -> Staging.Description
     - Ignore StagingID (identity), LoadBatchID/LoadedAt/IsProcessed/ErrorMessage use defaults
9. Run the package immediately -> Finish.

10. Merge into production:
      EXEC Staging.sp_MergeCategoriesFromStaging;

11. Verify:
      SELECT * FROM Staging.Categories;
      SELECT * FROM FoodService.Categories;

--------------------------------------------------------------------------------
B) IMPORT Excel -> Staging.Restaurants
--------------------------------------------------------------------------------
Repeat steps 3-9 with:
  - Source file: restaurants.xlsx
  - Sheet: Restaurants$
  - Destination: [Staging].[Restaurants]
  - Map: Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive

Then run:
  EXEC Staging.sp_MergeRestaurantsFromStaging;

--------------------------------------------------------------------------------
C) EXPORT FoodService.Categories -> Excel
--------------------------------------------------------------------------------
1. Right-click RideBite -> Tasks -> Export Data...
2. Source:
     - Data source: SQL Server Native Client
     - Server + authentication for your instance
     - Database: RideBite
3. Destination:
     - Data source: Microsoft Excel
     - File: C:\Users\MINA\Desktop\RideBite\Staging\export_categories.xlsx
     - Excel version: 2007 or later
4. Select "Write a query to specify the data to transfer".
5. Query:
     SELECT CategoryName, Description
     FROM FoodService.Categories
     ORDER BY CategoryID;
6. Destination sheet: Categories$
7. Run immediately -> Finish.

--------------------------------------------------------------------------------
D) EXPORT FoodService.Restaurants -> Excel
--------------------------------------------------------------------------------
Same as (C), with query:
  SELECT Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive
  FROM FoodService.Restaurants
  ORDER BY RestaurantID;

Destination file: export_restaurants.xlsx, sheet Restaurants$.

--------------------------------------------------------------------------------
Notes
--------------------------------------------------------------------------------
- To create .xlsx sample inputs, open categories.csv / restaurants.csv in Excel
  and Save As -> Excel Workbook (*.xlsx). Rename sheets to Categories / Restaurants.
- The wizard uses SQL Server bulk copy (BCP) under the hood.
- For automated T-SQL, use Staging_ImportExport_OPENROWSET.sql (Method 2).
*/

PRINT '=== SSMS Import/Export Wizard guide loaded (see script comments) ===';
GO
