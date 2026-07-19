USE RideBite;
GO

/*
    Bonus Section #2 - Method 2: T-SQL import/export using OPENROWSET.

    Prerequisites:
      1. Run Staging_EnableBulkImport.sql once (sysadmin).
      2. Install "Microsoft Access Database Engine 2016 Redistributable" (ACE OLEDB 12.0).
      3. Create Excel workbooks from the sample CSV files in this folder:
           - categories.xlsx  (sheet name: Categories)
           - restaurants.xlsx (sheet name: Restaurants)
         Row 1 must contain column headers exactly as shown below.

    Update @StagingRoot if your project folder is in a different location.

    Note: OPENROWSET requires string literals, so file paths are injected via dynamic SQL.
*/

DECLARE @StagingRoot NVARCHAR(4000) = N'C:\Users\MINA\Desktop\RideBite\Staging\';
DECLARE @CategoriesExcel NVARCHAR(4000) = @StagingRoot + N'categories.xlsx';
DECLARE @LoadBatchID UNIQUEIDENTIFIER = NEWID();
DECLARE @sql NVARCHAR(MAX);

/* -------------------------------------------------------------------------
   IMPORT: Excel -> Staging.Categories (OPENROWSET + ACE OLEDB)
   Expected sheet: [Categories$] with columns CategoryName, Description
   ------------------------------------------------------------------------- */

EXEC Staging.sp_ClearStagingTable @TableName = N'Categories';

SET @sql = N'
INSERT INTO Staging.Categories (CategoryName, Description, LoadBatchID)
SELECT
    LTRIM(RTRIM(CategoryName)),
    NULLIF(LTRIM(RTRIM(Description)), N''''),
    @LoadBatchID
FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.12.0'',
    ''Excel 12.0;Database=' + REPLACE(@CategoriesExcel, '''', '''''') + N';HDR=YES;IMEX=1'',
    ''SELECT CategoryName, Description FROM [Categories$]''
);';

EXEC sys.sp_executesql
    @sql,
    N'@LoadBatchID UNIQUEIDENTIFIER',
    @LoadBatchID = @LoadBatchID;

EXEC Staging.sp_MergeCategoriesFromStaging @LoadBatchID = @LoadBatchID;

SELECT
    StagingID,
    CategoryName,
    Description,
    IsProcessed,
    ErrorMessage
FROM Staging.Categories
WHERE LoadBatchID = @LoadBatchID;
GO

/* -------------------------------------------------------------------------
   IMPORT: Excel -> Staging.Restaurants (OPENROWSET + ACE OLEDB)
   Expected sheet: [Restaurants$]
   ------------------------------------------------------------------------- */

DECLARE @StagingRoot NVARCHAR(4000) = N'C:\Users\MINA\Desktop\RideBite\Staging\';
DECLARE @RestaurantsExcel NVARCHAR(4000) = @StagingRoot + N'restaurants.xlsx';
DECLARE @LoadBatchID UNIQUEIDENTIFIER = NEWID();
DECLARE @sql NVARCHAR(MAX);

EXEC Staging.sp_ClearStagingTable @TableName = N'Restaurants';

SET @sql = N'
INSERT INTO Staging.Restaurants
    (Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive, LoadBatchID)
SELECT
    LTRIM(RTRIM(Name)),
    NULLIF(LTRIM(RTRIM(Description)), N''''),
    LTRIM(RTRIM(Address)),
    LTRIM(RTRIM(Phone)),
    NULLIF(LTRIM(RTRIM(ImageURL)), N''''),
    LTRIM(RTRIM(OpeningHours)),
    CASE
        WHEN TRY_CAST(IsActive AS BIT) = 1 THEN 1
        WHEN UPPER(LTRIM(RTRIM(CAST(IsActive AS NVARCHAR(20))))) IN (N''1'', N''TRUE'', N''YES'') THEN 1
        ELSE 0
    END,
    @LoadBatchID
FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.12.0'',
    ''Excel 12.0;Database=' + REPLACE(@RestaurantsExcel, '''', '''''') + N';HDR=YES;IMEX=1'',
    ''SELECT Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive
      FROM [Restaurants$]''
);';

EXEC sys.sp_executesql
    @sql,
    N'@LoadBatchID UNIQUEIDENTIFIER',
    @LoadBatchID = @LoadBatchID;

EXEC Staging.sp_MergeRestaurantsFromStaging @LoadBatchID = @LoadBatchID;

SELECT
    StagingID,
    Name,
    Address,
    Phone,
    IsProcessed,
    ErrorMessage
FROM Staging.Restaurants
WHERE LoadBatchID = @LoadBatchID;
GO

/*
    EXPORT: FoodService -> Excel (OPENROWSET)

    Before running export:
      1. Create an empty .xlsx file at the target path.
      2. Add a worksheet named Categories (or Restaurants) with header row only.
      3. Run the block below.
*/

DECLARE @StagingRoot NVARCHAR(4000) = N'C:\Users\MINA\Desktop\RideBite\Staging\';
DECLARE @ExportCategoriesExcel NVARCHAR(4000) = @StagingRoot + N'export_categories.xlsx';
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
INSERT INTO OPENROWSET(
    ''Microsoft.ACE.OLEDB.12.0'',
    ''Excel 12.0;Database=' + REPLACE(@ExportCategoriesExcel, '''', '''''') + N';HDR=YES'',
    ''SELECT CategoryName, Description FROM [Categories$]''
)
SELECT
    CategoryName,
    Description
FROM FoodService.Categories
ORDER BY CategoryID;';

EXEC sys.sp_executesql @sql;
GO

DECLARE @StagingRoot NVARCHAR(4000) = N'C:\Users\MINA\Desktop\RideBite\Staging\';
DECLARE @ExportRestaurantsExcel NVARCHAR(4000) = @StagingRoot + N'export_restaurants.xlsx';
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
INSERT INTO OPENROWSET(
    ''Microsoft.ACE.OLEDB.12.0'',
    ''Excel 12.0;Database=' + REPLACE(@ExportRestaurantsExcel, '''', '''''') + N';HDR=YES'',
    ''SELECT Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive
      FROM [Restaurants$]''
)
SELECT
    Name,
    Description,
    Address,
    Phone,
    ImageURL,
    OpeningHours,
    IsActive
FROM FoodService.Restaurants
ORDER BY RestaurantID;';

EXEC sys.sp_executesql @sql;
GO

PRINT '=== OPENROWSET import/export script completed ===';
GO
