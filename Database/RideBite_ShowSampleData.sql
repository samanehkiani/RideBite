USE RideBite;
GO

SELECT 'FoodService.Users' AS TableName, COUNT(*) AS TotalRows FROM FoodService.Users
UNION ALL
SELECT 'FoodService.Addresses', COUNT(*) FROM FoodService.Addresses
UNION ALL
SELECT 'FoodService.Restaurants', COUNT(*) FROM FoodService.Restaurants
UNION ALL
SELECT 'FoodService.Categories', COUNT(*) FROM FoodService.Categories
UNION ALL
SELECT 'FoodService.Promotions', COUNT(*) FROM FoodService.Promotions
UNION ALL
SELECT 'FoodService.Foods', COUNT(*) FROM FoodService.Foods
UNION ALL
SELECT 'FoodService.Orders', COUNT(*) FROM FoodService.Orders
UNION ALL
SELECT 'FoodService.OrderItems', COUNT(*) FROM FoodService.OrderItems
UNION ALL
SELECT 'FoodService.Payments', COUNT(*) FROM FoodService.Payments
UNION ALL
SELECT 'FoodService.FoodReviews', COUNT(*) FROM FoodService.FoodReviews
UNION ALL
SELECT 'FoodService.FoodLogs', COUNT(*) FROM FoodService.FoodLogs
UNION ALL
SELECT 'RideService.Drivers', COUNT(*) FROM RideService.Drivers
UNION ALL
SELECT 'RideService.Vehicles', COUNT(*) FROM RideService.Vehicles
UNION ALL
SELECT 'RideService.DriverShift', COUNT(*) FROM RideService.DriverShift
UNION ALL
SELECT 'RideService.Passengers', COUNT(*) FROM RideService.Passengers
UNION ALL
SELECT 'RideService.Locations', COUNT(*) FROM RideService.Locations
UNION ALL
SELECT 'RideService.DriverLocations', COUNT(*) FROM RideService.DriverLocations
UNION ALL
SELECT 'RideService.RideRequests', COUNT(*) FROM RideService.RideRequests
UNION ALL
SELECT 'RideService.Trips', COUNT(*) FROM RideService.Trips
UNION ALL
SELECT 'RideService.RidePayments', COUNT(*) FROM RideService.RidePayments
UNION ALL
SELECT 'RideService.RideReviews', COUNT(*) FROM RideService.RideReviews
UNION ALL
SELECT 'RideService.DeliveryRequests', COUNT(*) FROM RideService.DeliveryRequests
UNION ALL
SELECT 'RideService.RideLogs', COUNT(*) FROM RideService.RideLogs
ORDER BY TableName;
GO


SELECT * FROM FoodService.Users;

SELECT * FROM FoodService.Addresses;

SELECT * FROM FoodService.Restaurants;

SELECT * FROM FoodService.Foods;

SELECT * FROM FoodService.Orders;

SELECT * FROM FoodService.OrderItems;

SELECT * FROM RideService.Drivers;

SELECT * FROM RideService.Passengers;

SELECT * FROM RideService.Trips;

SELECT * FROM RideService.RideRequests;