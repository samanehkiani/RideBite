USE RideBite;
GO

/*
    Bonus Section #2 - Bulk Insert (BULK INSERT statement).

    Use this when the source file is CSV. Excel workbooks can be saved as CSV
    (File -> Save As -> CSV UTF-8) and loaded with BULK INSERT.

    Sample files in this folder:
      - categories.csv
      - restaurants.csv

    Update the file paths below if your project folder is in a different location.
*/

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

SELECT
    StagingID,
    CategoryName,
    Description,
    IsProcessed,
    ErrorMessage
FROM Staging.Categories
WHERE LoadBatchID = @LoadBatchID;
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
SELECT
    Name,
    Description,
    Address,
    Phone,
    ImageURL,
    OpeningHours,
    IsActive,
    @LoadBatchID
FROM #RestaurantsImport;

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
    EXPORT via BCP (bulk copy out) - run in cmd as an optional bulk export demo.

    bcp "SELECT CategoryName, Description FROM RideBite.FoodService.Categories ORDER BY CategoryID"
        queryout "C:\Users\MINA\Desktop\RideBite\Staging\export_categories.csv"
        -c -t, -T -S localhost

    Open the exported CSV in Excel and save as .xlsx if an Excel file is required.
*/

PRINT '=== BULK INSERT import script completed ===';
GO
