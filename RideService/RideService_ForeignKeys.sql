USE RideBite;
GO

--Foreign Keys

-- 1. Vehicles.DriverID → Drivers.DriverID
ALTER TABLE RideService.Vehicles
ADD CONSTRAINT FK_Vehicles_Drivers
FOREIGN KEY (DriverID)
REFERENCES RideService.Drivers(DriverID);
GO

-- 2. DriverShift.DriverID → Drivers.DriverID
ALTER TABLE RideService.DriverShift
ADD CONSTRAINT FK_DriverShift_Drivers
FOREIGN KEY (DriverID)
REFERENCES RideService.Drivers(DriverID);
GO

-- 3. DriverLocations.DriverID → Drivers.DriverID
ALTER TABLE RideService.DriverLocations
ADD CONSTRAINT FK_DriverLocations_Drivers
FOREIGN KEY (DriverID)
REFERENCES RideService.Drivers(DriverID);
GO

-- 4. DriverLocations.LocationID → Locations.LocationID
ALTER TABLE RideService.DriverLocations
ADD CONSTRAINT FK_DriverLocations_Locations
FOREIGN KEY (LocationID)
REFERENCES RideService.Locations(LocationID);
GO

-- 5. RideRequests.PassengerID → Passengers.PassengerID
ALTER TABLE RideService.RideRequests
ADD CONSTRAINT FK_RideRequests_Passengers
FOREIGN KEY (PassengerID)
REFERENCES RideService.Passengers(PassengerID);
GO

-- 6. RideRequests.PickupLocationID → Locations.LocationID
ALTER TABLE RideService.RideRequests
ADD CONSTRAINT FK_RideRequests_PickupLocation
FOREIGN KEY (PickupLocationID)
REFERENCES RideService.Locations(LocationID);
GO

-- 7. RideRequests.DropoffLocationID → Locations.LocationID
ALTER TABLE RideService.RideRequests
ADD CONSTRAINT FK_RideRequests_DropoffLocation
FOREIGN KEY (DropoffLocationID)
REFERENCES RideService.Locations(LocationID);
GO

-- 8. Trips.RideRequestID → RideRequests.RideRequestID
ALTER TABLE RideService.Trips
ADD CONSTRAINT FK_Trips_RideRequests
FOREIGN KEY (RideRequestID)
REFERENCES RideService.RideRequests(RideRequestID);
GO

-- 9. Trips.DriverID → Drivers.DriverID
ALTER TABLE RideService.Trips
ADD CONSTRAINT FK_Trips_Drivers
FOREIGN KEY (DriverID)
REFERENCES RideService.Drivers(DriverID);
GO

-- 10. Trips.VehicleID → Vehicles.VehicleID
ALTER TABLE RideService.Trips
ADD CONSTRAINT FK_Trips_Vehicles
FOREIGN KEY (VehicleID)
REFERENCES RideService.Vehicles(VehicleID);
GO

-- 11. RidePayments.TripID → Trips.TripID
ALTER TABLE RideService.RidePayments
ADD CONSTRAINT FK_RidePayments_Trips
FOREIGN KEY (TripID)
REFERENCES RideService.Trips(TripID);
GO

-- 12. RideReviews.TripID → Trips.TripID
ALTER TABLE RideService.RideReviews
ADD CONSTRAINT FK_RideReviews_Trips
FOREIGN KEY (TripID)
REFERENCES RideService.Trips(TripID);
GO

-- 13. RideReviews.PassengerID → Passengers.PassengerID
ALTER TABLE RideService.RideReviews
ADD CONSTRAINT FK_RideReviews_Passengers
FOREIGN KEY (PassengerID)
REFERENCES RideService.Passengers(PassengerID);
GO

-- 14. RideReviews.DriverID → Drivers.DriverID
ALTER TABLE RideService.RideReviews
ADD CONSTRAINT FK_RideReviews_Drivers
FOREIGN KEY (DriverID)
REFERENCES RideService.Drivers(DriverID);
GO

-- 15. DeliveryRequests.DriverID → Drivers.DriverID
ALTER TABLE RideService.DeliveryRequests
ADD CONSTRAINT FK_DeliveryRequests_Drivers
FOREIGN KEY (DriverID)
REFERENCES RideService.Drivers(DriverID);
GO

-- 16. DeliveryRequests.PickupLocationID → Locations.LocationID
ALTER TABLE RideService.DeliveryRequests
ADD CONSTRAINT FK_DeliveryRequests_PickupLocation
FOREIGN KEY (PickupLocationID)
REFERENCES RideService.Locations(LocationID);
GO

-- 17. DeliveryRequests.DropoffLocationID → Locations.LocationID
ALTER TABLE RideService.DeliveryRequests
ADD CONSTRAINT FK_DeliveryRequests_DropoffLocation
FOREIGN KEY (DropoffLocationID)
REFERENCES RideService.Locations(LocationID);
GO

-- UNIQUE Constraints

ALTER TABLE RideService.Vehicles
ADD CONSTRAINT UQ_Vehicles_PlateNumber
UNIQUE (PlateNumber);
GO

ALTER TABLE RideService.Trips
ADD CONSTRAINT UQ_Trips_RideRequestID
UNIQUE (RideRequestID);
GO

ALTER TABLE RideService.RideReviews
ADD CONSTRAINT UQ_RideReviews_TripID
UNIQUE (TripID);
GO