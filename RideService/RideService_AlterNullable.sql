USE RideBite;
GO

-- RideService Schema Adjustments

ALTER TABLE RideService.DeliveryRequests
ALTER COLUMN DriverID INT NULL;
GO

ALTER TABLE RideService.Locations
ALTER COLUMN Latitude DECIMAL(9,6) NULL;
GO

ALTER TABLE RideService.Locations
ALTER COLUMN Longitude DECIMAL(9,6) NULL;
GO
