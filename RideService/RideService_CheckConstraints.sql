USE RideBite;
GO

-- Drivers.Rating 
ALTER TABLE RideService.Drivers
ADD CONSTRAINT CK_Drivers_Rating
CHECK (Rating IS NULL OR Rating BETWEEN 0 AND 5);
GO

-- RideReviews.Rating 
ALTER TABLE RideService.RideReviews
ADD CONSTRAINT CK_RideReviews_Rating
CHECK (Rating BETWEEN 1 AND 5);
GO

-- Vehicles.Capacity 
ALTER TABLE RideService.Vehicles
ADD CONSTRAINT CK_Vehicles_Capacity
CHECK (Capacity > 0);
GO

-- Trips.FareAmount 
ALTER TABLE RideService.Trips
ADD CONSTRAINT CK_Trips_FareAmount
CHECK (FareAmount IS NULL OR FareAmount >= 0);
GO

-- Trips.Distance 
ALTER TABLE RideService.Trips
ADD CONSTRAINT CK_Trips_Distance
CHECK (Distance IS NULL OR Distance >= 0);
GO

-- Trips.EndTime 
ALTER TABLE RideService.Trips
ADD CONSTRAINT CK_Trips_EndAfterStart
CHECK (EndTime IS NULL OR StartedAt IS NULL OR EndTime >= StartedAt);
GO

-- RidePayments.Amount 
ALTER TABLE RideService.RidePayments
ADD CONSTRAINT CK_RidePayments_Amount
CHECK (Amount >= 0);
GO

-- DriverShift.EndTime 
ALTER TABLE RideService.DriverShift
ADD CONSTRAINT CK_DriverShift_EndAfterStart
CHECK (EndTime >= StartTime);
GO