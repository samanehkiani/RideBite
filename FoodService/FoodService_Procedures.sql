USE RideBite;
GO
DROP PROCEDURE IF EXISTS FoodService.sp_CreateOrder;
DROP PROCEDURE IF EXISTS FoodService.sp_UpdateOrderStatus;
DROP PROCEDURE IF EXISTS FoodService.sp_ArchiveOldOrders;
GO


IF TYPE_ID(N'FoodService.OrderItemType') IS NOT NULL
    DROP TYPE FoodService.OrderItemType;
GO

CREATE TYPE FoodService.OrderItemType AS TABLE
(
    FoodID      INT,
    Quantity    INT,
    SpecialNote NVARCHAR(200)
);
GO

DROP PROCEDURE IF EXISTS FoodService.sp_CreateOrder;
DROP PROCEDURE IF EXISTS FoodService.sp_UpdateOrderStatus;
DROP PROCEDURE IF EXISTS FoodService.sp_ArchiveOldOrders;
GO

CREATE PROCEDURE FoodService.sp_CreateOrder
    @UserID         INT,
    @AddressID      INT,
    @DeliveryFee    DECIMAL(10,2),
    @Items          FoodService.OrderItemType READONLY,
    @NewOrderID     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM @Items)
    BEGIN
        RAISERROR('Order must contain at least one item.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO FoodService.Orders
            (UserID, AddressID, OrderDate, Status, Subtotal, DeliveryFee, DiscountAmount, Tax, TotalAmount, PaymentStatus)
        VALUES
            (@UserID, @AddressID, SYSDATETIME(), 'Placed', 0, @DeliveryFee, 0, 0, 0, 'Pending');

        SET @NewOrderID = SCOPE_IDENTITY();

        INSERT INTO FoodService.OrderItems (OrderID, FoodID, Quantity, UnitPrice, TotalPrice, SpecialNote)
        SELECT
            @NewOrderID,
            i.FoodID,
            i.Quantity,
            FoodService.fn_GetFoodDiscountedPrice(i.FoodID),
            i.Quantity * FoodService.fn_GetFoodDiscountedPrice(i.FoodID),
            i.SpecialNote
        FROM @Items i;

        DECLARE @Subtotal DECIMAL(10,2);
        DECLARE @Tax DECIMAL(10,2);

        SELECT @Subtotal = SUM(TotalPrice) FROM FoodService.OrderItems WHERE OrderID = @NewOrderID;
        SET @Tax = @Subtotal * 0.09;  

        UPDATE FoodService.Orders
        SET Subtotal    = @Subtotal,
            Tax          = @Tax,
            TotalAmount   = @Subtotal + @DeliveryFee + @Tax
        WHERE OrderID = @NewOrderID;

        INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
        VALUES ('Order', @NewOrderID, 'Create', 'Order created via sp_CreateOrder', SYSDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


CREATE PROCEDURE FoodService.sp_UpdateOrderStatus
    @OrderID    INT,
    @NewStatus  VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM FoodService.Orders WHERE OrderID = @OrderID)
    BEGIN
        RAISERROR('Order not found.', 16, 1);
        RETURN;
    END

    IF @NewStatus NOT IN ('Placed', 'Accepted', 'Preparing', 'ReadyForDelivery', 'Delivered', 'Cancelled', 'Archived')
    BEGIN
        RAISERROR('Invalid status value.', 16, 1);
        RETURN;
    END

    UPDATE FoodService.Orders
    SET Status = @NewStatus
    WHERE OrderID = @OrderID;

    INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
    VALUES ('Order', @OrderID, 'StatusChange', CONCAT('Status changed to ', @NewStatus), SYSDATETIME());
END;
GO


CREATE PROCEDURE FoodService.sp_ArchiveOldOrders
    @OlderThanDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @OlderThanDate IS NULL
        SET @OlderThanDate = DATEADD(YEAR, -1, SYSDATETIME());

    DECLARE @ArchivedOrders TABLE (OrderID INT);

    UPDATE FoodService.Orders
    SET Status = 'Archived'
    OUTPUT inserted.OrderID INTO @ArchivedOrders
    WHERE OrderDate < @OlderThanDate
        AND Status = 'Delivered';

    INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
    SELECT 'Order', OrderID, 'Archive', 'Order archived automatically (older than cutoff date)', SYSDATETIME()
    FROM @ArchivedOrders;
END;
GO
