USE RideBite;
GO

-- Cross-Schema Triggers (FoodService <-> RideService)


DROP TRIGGER IF EXISTS FoodService.trg_Users_InsertPassenger;
DROP TRIGGER IF EXISTS FoodService.trg_Orders_ReadyForDelivery;
DROP TRIGGER IF EXISTS RideService.trg_DeliveryRequests_Delivered;
GO

CREATE TRIGGER FoodService.trg_Users_InsertPassenger
ON FoodService.Users
AFTER INSERT
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    SET NOCOUNT ON;

    INSERT INTO RideService.Passengers (UserRef, FullName, Phone, DefaultPaymentMethod)
    SELECT UserID, FullName, Phone, 'Cash'
    FROM inserted;

    INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
    SELECT
        'User',
        UserID,
        'CrossSchemaSync',
        'Passenger record auto-created in RideService (UserRef, no FK)',
        SYSDATETIME()
    FROM inserted;
END;
GO

CREATE TRIGGER FoodService.trg_Orders_ReadyForDelivery
ON FoodService.Orders
AFTER UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        DECLARE @OrderID            INT,
                @RestaurantAddress  NVARCHAR(200),
                @CustomerAddress    NVARCHAR(200),
                @PickupLocationID   INT,
                @DropoffLocationID  INT;

        DECLARE order_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT i.OrderID
            FROM inserted i
            INNER JOIN deleted d ON i.OrderID = d.OrderID
            WHERE i.Status = 'ReadyForDelivery'
                AND d.Status <> 'ReadyForDelivery';

        OPEN order_cursor;
        FETCH NEXT FROM order_cursor INTO @OrderID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT TOP 1 @RestaurantAddress = r.Address
            FROM FoodService.OrderItems oi
            INNER JOIN FoodService.Foods f       ON oi.FoodID = f.FoodID
            INNER JOIN FoodService.Restaurants r ON f.RestaurantID = r.RestaurantID
            WHERE oi.OrderID = @OrderID;

            SELECT @CustomerAddress = CONCAT(a.Street, N', ', a.City)
            FROM FoodService.Orders o
            INNER JOIN FoodService.Addresses a ON o.AddressID = a.AddressID
            WHERE o.OrderID = @OrderID;

            INSERT INTO RideService.Locations (Address, LocationType)
            VALUES (@RestaurantAddress, 'Pickup');
            SET @PickupLocationID = SCOPE_IDENTITY();

            INSERT INTO RideService.Locations (Address, LocationType)
            VALUES (@CustomerAddress, 'Dropoff');
            SET @DropoffLocationID = SCOPE_IDENTITY();

            INSERT INTO RideService.DeliveryRequests
                (DriverID, OrderRef, PickupLocationID, DropoffLocationID, RequestTime, Status)
            VALUES
                (NULL, @OrderID, @PickupLocationID, @DropoffLocationID, SYSDATETIME(), 'PendingAssignment');

            INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedAt)
            VALUES ('Order', @OrderID, 'CrossSchemaSync', 'DeliveryRequest created in RideService (PendingAssignment)', SYSDATETIME());

            FETCH NEXT FROM order_cursor INTO @OrderID;
        END

        CLOSE order_cursor;
        DEALLOCATE order_cursor;
    END
END;
GO

CREATE TRIGGER RideService.trg_DeliveryRequests_Delivered
ON RideService.DeliveryRequests
AFTER UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        UPDATE fo
        SET fo.Status = 'Delivered'
        FROM FoodService.Orders fo
        INNER JOIN inserted i ON fo.OrderID = i.OrderRef
        INNER JOIN deleted  d ON i.DeliveryRequestID = d.DeliveryRequestID
        WHERE i.Status = 'Delivered'
            AND d.Status <> 'Delivered';

        UPDATE dr
        SET dr.DeliveredAt = SYSDATETIME()
        FROM RideService.DeliveryRequests dr
        INNER JOIN inserted i ON dr.DeliveryRequestID = i.DeliveryRequestID
        INNER JOIN deleted  d ON i.DeliveryRequestID = d.DeliveryRequestID
        WHERE i.Status = 'Delivered'
            AND d.Status <> 'Delivered'
            AND dr.DeliveredAt IS NULL;

        INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
        SELECT
            'DeliveryRequest',
            i.DeliveryRequestID,
            'CrossSchemaSync',
            CONCAT('FoodService.Orders (OrderID=', i.OrderRef, ') marked Delivered'),
            SYSDATETIME()
        FROM inserted i
        INNER JOIN deleted d ON i.DeliveryRequestID = d.DeliveryRequestID
        WHERE i.Status = 'Delivered'
            AND d.Status <> 'Delivered';
    END
END;
GO
