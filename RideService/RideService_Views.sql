USE RideBite;
GO


DROP VIEW IF EXISTS RideService.vw_TripDetails;
GO

DROP VIEW IF EXISTS RideService.vw_DriverPerformance;
GO

DROP VIEW IF EXISTS RideService.vw_DailyRidesReport;
GO


CREATE VIEW RideService.vw_TripDetails
AS
SELECT
    t.TripID,
    rr.RideRequestID,

    p.FullName AS PassengerName,
    d.FullName AS DriverName,

    v.PlateNumber,
    v.Type AS VehicleType,

    pl.Address AS PickupAddress,
    dl.Address AS DropoffAddress,

    t.StartedAt,
    t.EndTime,

    t.Distance,
    t.FareAmount,

    t.Status AS TripStatus
FROM RideService.Trips t
INNER JOIN RideService.RideRequests rr
    ON t.RideRequestID = rr.RideRequestID
INNER JOIN RideService.Passengers p
    ON rr.PassengerID = p.PassengerID
INNER JOIN RideService.Drivers d
    ON t.DriverID = d.DriverID
INNER JOIN RideService.Vehicles v
    ON t.VehicleID = v.VehicleID
INNER JOIN RideService.Locations pl
    ON rr.PickupLocationID = pl.LocationID
INNER JOIN RideService.Locations dl
    ON rr.DropoffLocationID = dl.LocationID;
GO



CREATE VIEW RideService.vw_DriverPerformance
AS
SELECT

    d.DriverID,
    d.FullName,

    d.Rating,

    COUNT(t.TripID) AS TotalTrips,

    SUM(
        CASE
            WHEN t.Status = 'completed' THEN 1
            ELSE 0
        END
    ) AS CompletedTrips,

    ISNULL(SUM(t.FareAmount),0) AS TotalEarnings

FROM RideService.Drivers d

LEFT JOIN RideService.Trips t
    ON d.DriverID = t.DriverID

GROUP BY
    d.DriverID,
    d.FullName,
    d.Rating;
GO



CREATE VIEW RideService.vw_DailyRidesReport
AS
SELECT

    CAST(t.StartedAt AS DATE) AS RideDate,

    COUNT(*) AS TotalTrips,

    SUM(t.Distance) AS TotalDistance,

    SUM(t.FareAmount) AS TotalRevenue,

    AVG(t.FareAmount) AS AverageFare

FROM RideService.Trips t

WHERE t.Status = 'completed'

GROUP BY
    CAST(t.StartedAt AS DATE);
GO
