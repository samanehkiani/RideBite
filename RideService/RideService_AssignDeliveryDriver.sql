USE RideBite;
GO

-- RideService Stored Procedure (‌Added)
-- Workflow: PendingAssignment → Assigned → PickedUp → Delivered

DROP PROCEDURE IF EXISTS RideService.sp_AssignDriverToDeliveryRequest;
GO

CREATE PROCEDURE RideService.sp_AssignDriverToDeliveryRequest
    @DeliveryRequestID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM RideService.DeliveryRequests WHERE DeliveryRequestID = @DeliveryRequestID)
    BEGIN
        RAISERROR('Delivery request not found.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM RideService.DeliveryRequests WHERE DeliveryRequestID = @DeliveryRequestID AND DriverID IS NOT NULL)
    BEGIN
        RAISERROR('Driver already assigned to this delivery request.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @DriverID INT;

        SELECT TOP 1 @DriverID = d.DriverID
        FROM RideService.Drivers d
        WHERE RideService.fn_IsDriverAvailable(d.DriverID) = 1
        ORDER BY d.Rating DESC;

        IF @DriverID IS NULL
        BEGIN
            RAISERROR('No available driver found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE RideService.DeliveryRequests
        SET DriverID   = @DriverID,
            AssignedAt = SYSDATETIME(),
            Status     = 'Assigned'
        WHERE DeliveryRequestID = @DeliveryRequestID;

        INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
        VALUES ('DeliveryRequest', @DeliveryRequestID, 'AssignDriver',
                CONCAT('Driver ', @DriverID, ' assigned via sp_AssignDriverToDeliveryRequest'), SYSDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
