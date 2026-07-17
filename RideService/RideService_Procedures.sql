USE RideBite;
GO


CREATE PROCEDURE RideService.sp_AssignDriverToRequest
    @RideRequestID  INT,
    @NewTripID      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM RideService.RideRequests WHERE RideRequestID = @RideRequestID)
    BEGIN
        RAISERROR('Ride request not found.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @DriverID  INT;
        DECLARE @VehicleID INT;

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

        SELECT TOP 1 @VehicleID = VehicleID
        FROM RideService.Vehicles
        WHERE DriverID = @DriverID AND IsActive = 1;

        INSERT INTO RideService.Trips (RideRequestID, DriverID, VehicleID, AcceptedAt, Status)
        VALUES (@RideRequestID, @DriverID, @VehicleID, SYSDATETIME(), 'accepted');

        SET @NewTripID = SCOPE_IDENTITY();

        UPDATE RideService.RideRequests
        SET Status = 'accepted'
        WHERE RideRequestID = @RideRequestID;

        INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
        VALUES ('Trip', @NewTripID, 'AssignDriver', 'Driver assigned via sp_AssignDriverToRequest', SYSDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


CREATE PROCEDURE RideService.sp_CompleteTrip
    @TripID         INT,
    @PaymentMethod  VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM RideService.Trips WHERE TripID = @TripID)
    BEGIN
        RAISERROR('Trip not found.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Distance DECIMAL(6,2);
        DECLARE @Fare     DECIMAL(10,2);

        SELECT @Distance = Distance FROM RideService.Trips WHERE TripID = @TripID;

        IF @Distance IS NULL
        BEGIN
            RAISERROR('Trip distance must be set before completing the trip.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @Fare = RideService.fn_CalculateFare(@Distance);

        UPDATE RideService.Trips
        SET FareAmount = @Fare,
            Status      = 'completed',
            EndTime      = SYSDATETIME()
        WHERE TripID = @TripID;

        INSERT INTO RideService.RidePayments (TripID, Amount, PaymentMethod, PaymentStatus, PaidAt)
        VALUES (@TripID, @Fare, @PaymentMethod, 'success', SYSDATETIME());

        INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
        VALUES ('Trip', @TripID, 'Complete', 'Trip completed and payment recorded via sp_CompleteTrip', SYSDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE RideService.sp_ArchiveOldTrips
    @OlderThanDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @OlderThanDate IS NULL
        SET @OlderThanDate = DATEADD(YEAR, -1, SYSDATETIME());

    DECLARE @ArchivedTrips TABLE (TripID INT);

    UPDATE RideService.Trips
    SET Status = 'archived'
    OUTPUT inserted.TripID INTO @ArchivedTrips
    WHERE EndTime < @OlderThanDate
        AND Status = 'completed';

    INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
    SELECT 'Trip', TripID, 'Archive', 'Trip archived automatically (older than cutoff date)', SYSDATETIME()
    FROM @ArchivedTrips;
END;
GO
