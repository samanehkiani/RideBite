USE RideBite;
GO

DROP TRIGGER IF EXISTS FoodService.trg_Users_InsertPassenger;
DROP TRIGGER IF EXISTS FoodService.trg_Orders_ReadyForDelivery;
DROP TRIGGER IF EXISTS FoodService.trg_Payments_SyncOrderStatus;
DROP TRIGGER IF EXISTS FoodService.trg_Orders_LogChange;
GO

CREATE TRIGGER FoodService.trg_Users_InsertPassenger
ON FoodService.Users
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO RideService.Passengers (UserRef, FullName, Phone, DefaultPaymentMethod)
    SELECT i.UserID, i.FullName, i.Phone, 'Cash'
    FROM inserted i;

    INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
    SELECT 'User', i.UserID, 'InsertPassenger', CONCAT('Passenger created for UserID=', i.UserID), SYSDATETIME()
    FROM inserted i;
END;
GO

CREATE TRIGGER FoodService.trg_Orders_ReadyForDelivery
ON FoodService.Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(Status)
        RETURN;

    DECLARE @OrderID INT;
    DECLARE @RestaurantAddress NVARCHAR(200);
    DECLARE @CustomerAddress NVARCHAR(200);
    DECLARE @PickupLocationID INT;
    DECLARE @DropoffLocationID INT;

    DECLARE ReadyOrders CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            i.OrderID,
            (SELECT TOP 1 res.Address
             FROM FoodService.OrderItems oi
             INNER JOIN FoodService.Foods f ON f.FoodID = oi.FoodID
             INNER JOIN FoodService.Restaurants res ON res.RestaurantID = f.RestaurantID
             WHERE oi.OrderID = i.OrderID),
            CONCAT(a.Street, ', ', a.City, ', ', a.State)
        FROM inserted i
        INNER JOIN deleted d ON d.OrderID = i.OrderID
        INNER JOIN FoodService.Addresses a ON a.AddressID = i.AddressID
        WHERE i.Status = 'ReadyForDelivery'
            AND d.Status <> 'ReadyForDelivery';

    OPEN ReadyOrders;
    FETCH NEXT FROM ReadyOrders INTO @OrderID, @RestaurantAddress, @CustomerAddress;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO RideService.Locations (Address, Latitude, Longitude, LocationType)
        VALUES (@RestaurantAddress, 0, 0, 'Restaurant');
        SET @PickupLocationID = SCOPE_IDENTITY();

        INSERT INTO RideService.Locations (Address, Latitude, Longitude, LocationType)
        VALUES (@CustomerAddress, 0, 0, 'Customer');
        SET @DropoffLocationID = SCOPE_IDENTITY();

        INSERT INTO RideService.DeliveryRequests (DriverID, OrderRef, PickupLocationID, DropoffLocationID, RequestTime, Status)
        VALUES (NULL, @OrderID, @PickupLocationID, @DropoffLocationID, SYSDATETIME(), 'Pending');

        INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
        VALUES ('Order', @OrderID, 'ReadyForDelivery', 'DeliveryRequest created in RideService', SYSDATETIME());

        FETCH NEXT FROM ReadyOrders INTO @OrderID, @RestaurantAddress, @CustomerAddress;
    END;

    CLOSE ReadyOrders;
    DEALLOCATE ReadyOrders;
END;
GO

CREATE TRIGGER FoodService.trg_Payments_SyncOrderStatus
ON FoodService.Payments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(PaymentStatus)
    BEGIN
        UPDATE o
        SET o.PaymentStatus = 'Paid'
        FROM FoodService.Orders o
        INNER JOIN inserted i ON o.OrderID = i.OrderID
        WHERE i.PaymentStatus = 'Success';

        INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
        SELECT
            'Payment',
            i.PaymentID,
            'SyncOrderStatus',
            CONCAT('Order ', i.OrderID, ' PaymentStatus synced to Paid'),
            SYSDATETIME()
        FROM inserted i
        WHERE i.PaymentStatus = 'Success';
    END
END;
GO

CREATE TRIGGER FoodService.trg_Orders_LogChange
ON FoodService.Orders
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
    SELECT
        'Order',
        i.OrderID,
        CASE
            WHEN NOT EXISTS (SELECT 1 FROM deleted d WHERE d.OrderID = i.OrderID)
            THEN 'Insert'
            ELSE 'Update'
        END,
        CONCAT('Status=', i.Status, ', TotalAmount=', i.TotalAmount, ', PaymentStatus=', i.PaymentStatus),
        SYSDATETIME()
    FROM inserted i;
END;
GO