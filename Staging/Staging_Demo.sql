USE RideBite;
GO

/*
    End-to-end demo for Bonus Section #2 (Excel Import/Export via Bulk Insert).

    Run order:
      1. Database\CreateDatabase.sql
      2. Database\CreateSchemas.sql
      3. FoodService\FoodService_Tables.sql (+ FKs, etc. as needed)
      4. Staging\Staging_Tables.sql
      5. Staging\Staging_Procedures.sql
      6. Staging\Staging_EnableBulkImport.sql   (sysadmin, once)
      7. This script OR Staging_ImportExport_BulkInsert.sql
         OR Staging_ImportExport_OPENROWSET.sql (after creating .xlsx files)
         OR follow Staging_SSMS_Wizard_Guide.sql
*/

PRINT '=== Staging demo: bulk import categories from CSV ===';
GO

DECLARE @LoadBatchID UNIQUEIDENTIFIER = NEWID();

EXEC Staging.sp_ClearStagingTable @TableName = N'Categories';

IF OBJECT_ID('tempdb..#CategoriesImport') IS NOT NULL
    DROP TABLE #CategoriesImport;

CREATE TABLE #CategoriesImport
(
    CategoryName NVARCHAR(50)  NOT NULL,
    Description  NVARCHAR(200) NULL
);

BULK INSERT #CategoriesImport
FROM 'C:\Users\MINA\Desktop\RideBite\Staging\categories.csv'
WITH
(
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK,
    CODEPAGE        = '65001'
);

INSERT INTO Staging.Categories (CategoryName, Description, LoadBatchID)
SELECT CategoryName, Description, @LoadBatchID
FROM #CategoriesImport;

EXEC Staging.sp_MergeCategoriesFromStaging @LoadBatchID = @LoadBatchID;

SELECT 'Staging.Categories' AS ResultSet;
SELECT StagingID, CategoryName, Description, IsProcessed, ErrorMessage
FROM Staging.Categories
WHERE LoadBatchID = @LoadBatchID;

SELECT 'FoodService.Categories (after merge)' AS ResultSet;
SELECT CategoryID, CategoryName, Description
FROM FoodService.Categories
ORDER BY CategoryID;
GO

PRINT '=== Staging demo: bulk import restaurants from CSV ===';
GO

DECLARE @LoadBatchID UNIQUEIDENTIFIER = NEWID();

EXEC Staging.sp_ClearStagingTable @TableName = N'Restaurants';

IF OBJECT_ID('tempdb..#RestaurantsImport') IS NOT NULL
    DROP TABLE #RestaurantsImport;

CREATE TABLE #RestaurantsImport
(
    Name         NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(500) NULL,
    Address      NVARCHAR(200) NOT NULL,
    Phone        VARCHAR(15)   NOT NULL,
    ImageURL     NVARCHAR(255) NULL,
    OpeningHours NVARCHAR(100) NOT NULL,
    IsActive     BIT           NOT NULL
);

BULK INSERT #RestaurantsImport
FROM 'C:\Users\MINA\Desktop\RideBite\Staging\restaurants.csv'
WITH
(
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK,
    CODEPAGE        = '65001'
);

INSERT INTO Staging.Restaurants
    (Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive, LoadBatchID)
SELECT Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive, @LoadBatchID
FROM #RestaurantsImport;

EXEC Staging.sp_MergeRestaurantsFromStaging @LoadBatchID = @LoadBatchID;

SELECT 'Staging.Restaurants' AS ResultSet;
SELECT StagingID, Name, Address, Phone, IsProcessed, ErrorMessage
FROM Staging.Restaurants
WHERE LoadBatchID = @LoadBatchID;

SELECT 'FoodService.Restaurants (after merge)' AS ResultSet;
SELECT RestaurantID, Name, Address, Phone, IsActive
FROM FoodService.Restaurants
ORDER BY RestaurantID;
GO

PRINT '=== Staging demo completed ===';
GO
