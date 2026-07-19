USE RideBite;
GO

DROP PROCEDURE IF EXISTS Staging.sp_ClearStagingTable;
DROP PROCEDURE IF EXISTS Staging.sp_MergeCategoriesFromStaging;
DROP PROCEDURE IF EXISTS Staging.sp_MergeRestaurantsFromStaging;
GO

CREATE PROCEDURE Staging.sp_ClearStagingTable
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    IF @TableName NOT IN (N'Categories', N'Restaurants')
    BEGIN
        RAISERROR('Only Staging.Categories and Staging.Restaurants are supported.', 16, 1);
        RETURN;
    END

    DECLARE @sql NVARCHAR(MAX) =
        N'TRUNCATE TABLE Staging.' + QUOTENAME(@TableName) + N';';

    EXEC sys.sp_executesql @sql;
END;
GO

CREATE PROCEDURE Staging.sp_MergeCategoriesFromStaging
    @LoadBatchID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE s
        SET
            IsProcessed  = 0,
            ErrorMessage = N'CategoryName is required.'
        FROM Staging.Categories AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND LTRIM(RTRIM(s.CategoryName)) = N'';

        UPDATE s
        SET
            IsProcessed  = 0,
            ErrorMessage = N'Duplicate CategoryName already exists in FoodService.Categories.'
        FROM Staging.Categories AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND s.ErrorMessage IS NULL
          AND EXISTS (
              SELECT 1
              FROM FoodService.Categories AS c
              WHERE c.CategoryName = s.CategoryName
          );

        INSERT INTO FoodService.Categories (CategoryName, Description)
        SELECT
            LTRIM(RTRIM(s.CategoryName)),
            NULLIF(LTRIM(RTRIM(s.Description)), N'')
        FROM Staging.Categories AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND s.ErrorMessage IS NULL
          AND LTRIM(RTRIM(s.CategoryName)) <> N''
          AND NOT EXISTS (
              SELECT 1
              FROM FoodService.Categories AS c
              WHERE c.CategoryName = s.CategoryName
          );

        UPDATE s
        SET
            IsProcessed  = 1,
            ErrorMessage = NULL
        FROM Staging.Categories AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND s.ErrorMessage IS NULL
          AND LTRIM(RTRIM(s.CategoryName)) <> N''
          AND EXISTS (
              SELECT 1
              FROM FoodService.Categories AS c
              WHERE c.CategoryName = s.CategoryName
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE Staging.sp_MergeRestaurantsFromStaging
    @LoadBatchID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE s
        SET
            IsProcessed  = 0,
            ErrorMessage = N'Name, Address, Phone, and OpeningHours are required.'
        FROM Staging.Restaurants AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND (
              LTRIM(RTRIM(s.Name)) = N''
              OR LTRIM(RTRIM(s.Address)) = N''
              OR LTRIM(RTRIM(s.Phone)) = N''
              OR LTRIM(RTRIM(s.OpeningHours)) = N''
          );

        INSERT INTO FoodService.Restaurants
            (Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive)
        SELECT
            LTRIM(RTRIM(s.Name)),
            NULLIF(LTRIM(RTRIM(s.Description)), N''),
            LTRIM(RTRIM(s.Address)),
            LTRIM(RTRIM(s.Phone)),
            NULLIF(LTRIM(RTRIM(s.ImageURL)), N''),
            LTRIM(RTRIM(s.OpeningHours)),
            ISNULL(s.IsActive, 1)
        FROM Staging.Restaurants AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND s.ErrorMessage IS NULL
          AND LTRIM(RTRIM(s.Name)) <> N''
          AND LTRIM(RTRIM(s.Address)) <> N''
          AND LTRIM(RTRIM(s.Phone)) <> N''
          AND LTRIM(RTRIM(s.OpeningHours)) <> N'';

        UPDATE s
        SET
            IsProcessed  = 1,
            ErrorMessage = NULL
        FROM Staging.Restaurants AS s
        WHERE (@LoadBatchID IS NULL OR s.LoadBatchID = @LoadBatchID)
          AND s.ErrorMessage IS NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

PRINT '=== Staging procedures created ===';
GO
