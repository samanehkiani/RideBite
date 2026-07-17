USE RideBite;
GO

-- RideService Internal Triggers

DROP TRIGGER IF EXISTS RideService.trg_RideReviews_UpdateDriverRating;
DROP TRIGGER IF EXISTS RideService.trg_Trips_CalculateFareAndLog;
GO

CREATE TRIGGER RideService.trg_RideReviews_UpdateDriverRating
ON RideService.RideReviews
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE d
    SET d.Rating = RideService.fn_GetAverageDriverRating(d.DriverID)
    FROM RideService.Drivers d
    INNER JOIN inserted i ON d.DriverID = i.DriverID;

    INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
    SELECT
        'Driver',
        i.DriverID,
        'UpdateRating',
        CONCAT('Rating recalculated after ReviewID=', i.ReviewID),
        SYSDATETIME()
    FROM inserted i;
END;
GO

CREATE TRIGGER RideService.trg_Trips_CalculateFareAndLog
ON RideService.Trips
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        UPDATE t
        SET t.FareAmount = RideService.fn_CalculateFare(t.Distance)
        FROM RideService.Trips t
        INNER JOIN inserted i ON t.TripID = i.TripID
        INNER JOIN deleted  d ON i.TripID = d.TripID
        WHERE i.Status = 'completed'
            AND d.Status <> 'completed'
            AND i.FareAmount IS NULL;

        INSERT INTO RideService.RideLogs (EntityType, EntityID, Action, Details, CreatedAt)
        SELECT
            'Trip',
            i.TripID,
            'CalculateFareAndLog',
            CONCAT('Trip completed, Distance=', i.Distance),
            SYSDATETIME()
        FROM inserted i
        INNER JOIN deleted d ON i.TripID = d.TripID
        WHERE i.Status = 'completed'
            AND d.Status <> 'completed';
    END
END;
GO
