USE RideBite;
GO


CREATE FUNCTION RideService.fn_GetAverageDriverRating
(
    @DriverID INT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @AverageRating DECIMAL(3,2);
    SELECT @AverageRating =
        AVG(CAST(Rating AS DECIMAL(3,2)))
    FROM RideService.RideReviews
    WHERE DriverID = @DriverID;
    RETURN ISNULL(@AverageRating, 0);
END;
GO


CREATE FUNCTION RideService.fn_CalculateFare
(
    @Distance DECIMAL(6,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @BaseFare   DECIMAL(10,2) = 15000;   
    DECLARE @RatePerKm  DECIMAL(10,2) = 8000;    
    DECLARE @TotalFare  DECIMAL(10,2);

    SET @TotalFare = @BaseFare + (ISNULL(@Distance, 0) * @RatePerKm);

    RETURN @TotalFare;
END;
GO


CREATE FUNCTION RideService.fn_GetDriverEarnings
(
    @DriverID   INT,
    @StartDate  DATETIME2,
    @EndDate    DATETIME2
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalEarnings DECIMAL(10,2);
    SELECT @TotalEarnings =
        SUM(FareAmount)
    FROM RideService.Trips
    WHERE DriverID = @DriverID
        AND Status = 'completed'
        AND EndTime BETWEEN @StartDate AND @EndDate;
    RETURN ISNULL(@TotalEarnings, 0);
END;
GO


CREATE FUNCTION RideService.fn_GetTripDetailsByPassenger
(
    @PassengerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        t.TripID,
        d.FullName      AS DriverName,
        v.PlateNumber,
        v.Type           AS VehicleType,
        pl.Address        AS PickupAddress,
        dl.Address         AS DropoffAddress,
        t.StartedAt,
        t.EndTime,
        t.Distance,
        t.FareAmount,
        t.Status
    FROM RideService.Trips t
    INNER JOIN RideService.RideRequests rr
        ON t.RideRequestID = rr.RideRequestID
    INNER JOIN RideService.Drivers d
        ON t.DriverID = d.DriverID
    INNER JOIN RideService.Vehicles v
        ON t.VehicleID = v.VehicleID
    INNER JOIN RideService.Locations pl
        ON rr.PickupLocationID = pl.LocationID
    INNER JOIN RideService.Locations dl
        ON rr.DropoffLocationID = dl.LocationID
    WHERE rr.PassengerID = @PassengerID
);
GO


CREATE FUNCTION RideService.fn_IsDriverAvailable
(
    @DriverID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;
    DECLARE @OpenTrips INT;

    SELECT @OpenTrips = COUNT(*)
    FROM RideService.Trips
    WHERE DriverID = @DriverID
        AND Status IN ('accepted', 'started');

    SELECT @Result =
        CASE
            WHEN d.IsActive = 1 AND @OpenTrips = 0
            THEN 1
            ELSE 0
        END
    FROM RideService.Drivers d
    WHERE d.DriverID = @DriverID;

    RETURN ISNULL(@Result, 0);
END;
GO
