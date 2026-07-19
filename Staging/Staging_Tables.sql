USE RideBite;
GO

/*
    Staging schema tables for Excel / Bulk Insert import-export (Bonus Section #2).
    Raw files land here first; Staging.sp_Merge* moves validated rows into FoodService.
*/

IF OBJECT_ID(N'Staging.Restaurants', N'U') IS NOT NULL
    DROP TABLE Staging.Restaurants;
GO

IF OBJECT_ID(N'Staging.Categories', N'U') IS NOT NULL
    DROP TABLE Staging.Categories;
GO

CREATE TABLE Staging.Categories
(
    StagingID    INT IDENTITY(1,1) PRIMARY KEY,

    CategoryName NVARCHAR(50)  NOT NULL,

    Description  NVARCHAR(200) NULL,

    LoadBatchID  UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_StagingCategories_LoadBatchID DEFAULT NEWID(),

    LoadedAt     DATETIME2 NOT NULL
        CONSTRAINT DF_StagingCategories_LoadedAt DEFAULT SYSDATETIME(),

    IsProcessed  BIT NOT NULL
        CONSTRAINT DF_StagingCategories_IsProcessed DEFAULT 0,

    ErrorMessage NVARCHAR(500) NULL
);
GO

CREATE TABLE Staging.Restaurants
(
    StagingID    INT IDENTITY(1,1) PRIMARY KEY,

    Name         NVARCHAR(100) NOT NULL,

    Description  NVARCHAR(500) NULL,

    Address      NVARCHAR(200) NOT NULL,

    Phone        VARCHAR(15) NOT NULL,

    ImageURL     NVARCHAR(255) NULL,

    OpeningHours NVARCHAR(100) NOT NULL,

    IsActive     BIT NOT NULL
        CONSTRAINT DF_StagingRestaurants_IsActive DEFAULT 1,

    LoadBatchID  UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_StagingRestaurants_LoadBatchID DEFAULT NEWID(),

    LoadedAt     DATETIME2 NOT NULL
        CONSTRAINT DF_StagingRestaurants_LoadedAt DEFAULT SYSDATETIME(),

    IsProcessed  BIT NOT NULL
        CONSTRAINT DF_StagingRestaurants_IsProcessed DEFAULT 0,

    ErrorMessage NVARCHAR(500) NULL
);
GO

PRINT '=== Staging tables created ===';
GO
