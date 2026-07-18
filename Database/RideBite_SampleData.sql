USE RideBite;
GO

DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'DISABLE TRIGGER ALL ON ' + 
              QUOTENAME(OBJECT_SCHEMA_NAME(parent_id)) + '.' + 
              QUOTENAME(OBJECT_NAME(parent_id)) + ';'
FROM sys.triggers;
EXEC sp_executesql @sql;
GO

DELETE FROM RideService.RideLogs;
DELETE FROM RideService.DeliveryRequests;
DELETE FROM RideService.RideReviews;
DELETE FROM RideService.RidePayments;
DELETE FROM RideService.Trips;
DELETE FROM RideService.RideRequests;
DELETE FROM RideService.DriverLocations;
DELETE FROM RideService.Locations;
DELETE FROM RideService.Passengers;
DELETE FROM RideService.DriverShift;
DELETE FROM RideService.Vehicles;
DELETE FROM RideService.Drivers;
DELETE FROM FoodService.FoodLogs;
DELETE FROM FoodService.FoodReviews;
DELETE FROM FoodService.Payments;
DELETE FROM FoodService.OrderItems;
DELETE FROM FoodService.Orders;
DELETE FROM FoodService.Foods;
DELETE FROM FoodService.Promotions;
DELETE FROM FoodService.Categories;
DELETE FROM FoodService.Restaurants;
DELETE FROM FoodService.Addresses;
DELETE FROM FoodService.Users;
GO

DBCC CHECKIDENT ('FoodService.Users', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Addresses', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Restaurants', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Categories', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Promotions', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Foods', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Orders', RESEED, 0);
DBCC CHECKIDENT ('FoodService.OrderItems', RESEED, 0);
DBCC CHECKIDENT ('FoodService.Payments', RESEED, 0);
DBCC CHECKIDENT ('FoodService.FoodReviews', RESEED, 0);
DBCC CHECKIDENT ('FoodService.FoodLogs', RESEED, 0);
DBCC CHECKIDENT ('RideService.Drivers', RESEED, 0);
DBCC CHECKIDENT ('RideService.Vehicles', RESEED, 0);
DBCC CHECKIDENT ('RideService.DriverShift', RESEED, 0);
DBCC CHECKIDENT ('RideService.Passengers', RESEED, 0);
DBCC CHECKIDENT ('RideService.Locations', RESEED, 0);
DBCC CHECKIDENT ('RideService.DriverLocations', RESEED, 0);
DBCC CHECKIDENT ('RideService.RideRequests', RESEED, 0);
DBCC CHECKIDENT ('RideService.Trips', RESEED, 0);
DBCC CHECKIDENT ('RideService.RidePayments', RESEED, 0);
DBCC CHECKIDENT ('RideService.RideReviews', RESEED, 0);
DBCC CHECKIDENT ('RideService.DeliveryRequests', RESEED, 0);
DBCC CHECKIDENT ('RideService.RideLogs', RESEED, 0);
GO

SET IDENTITY_INSERT FoodService.Users ON;
INSERT INTO FoodService.Users (UserID, FullName, Phone, Email, PasswordHash, UserType, Status, CreatedAt, UpdatedAt) VALUES
(1,  'John Carter',      '15551234501', 'john.carter@example.com',    'hash_9f3a1c8e', 'Customer',       'Active',   '2025-01-10T09:00:00', '2025-01-10T09:00:00'),
(2,  'Sara Ahmadi',      '15551234502', 'sara.ahmadi@example.com',    'hash_2d7b6f31', 'Customer',       'Active',   '2025-01-12T10:15:00', '2025-01-12T10:15:00'),
(3,  'Mohammad Rezaei',  '15551234503', 'mohammad.rezaei@example.com','hash_a4e88b02', 'Customer',       'Active',   '2025-01-15T11:30:00', '2025-01-15T11:30:00'),
(4,  'Elena Petrova',    '15551234504', 'elena.petrova@example.com',  'hash_77c5d9aa', 'Customer',       'Active',   '2025-01-18T08:45:00', '2025-01-18T08:45:00'),
(5,  'David Kim',        '15551234505', 'david.kim@example.com',      'hash_11f0e2bb', 'Customer',       'Inactive', '2025-01-20T14:00:00', '2025-02-01T09:00:00'),
(6,  'Fatima Zahra',     '15551234506', 'fatima.zahra@example.com',   'hash_de34a190', 'Customer',       'Active',   '2025-01-22T16:20:00', '2025-01-22T16:20:00'),
(7,  'Admin Root',       '15551234507', 'admin.root@ridebite.com',    'hash_root0001', 'Admin',          'Active',   '2025-01-01T00:00:00', '2025-01-01T00:00:00'),
(8,  'Nora Bennett',     '15551234508', 'nora.bennett@ridebite.com',  'hash_rest0001', 'RestaurantOwner','Active',   '2025-01-05T09:00:00', '2025-01-05T09:00:00'),
(9,  'Amir Hosseini',    '15551234509', 'amir.hosseini@ridebite.com', 'hash_drv00001', 'Driver',         'Active',   '2025-02-01T09:00:00', '2025-02-01T09:00:00'),
(10, 'Layla Nasser',     '15551234510', 'layla.nasser@ridebite.com',  'hash_drv00002', 'Driver',         'Active',   '2025-02-03T09:00:00', '2025-02-03T09:00:00'),
(11, 'Kevin Chen',       '15551234511', 'kevin.chen@ridebite.com',    'hash_drv00003', 'Driver',         'Active',   '2025-02-05T09:00:00', '2025-02-05T09:00:00'),
(12, 'Sophia Rossi',     '15551234512', 'sophia.rossi@ridebite.com',  'hash_drv00004', 'Driver',         'Inactive', '2025-02-07T09:00:00', '2025-03-01T09:00:00'),
(13, 'Omar Farouk',      '15551234513', 'omar.farouk@ridebite.com',   'hash_drv00005', 'Driver',         'Active',   '2025-02-10T09:00:00', '2025-02-10T09:00:00');
SET IDENTITY_INSERT FoodService.Users OFF;
GO

SET IDENTITY_INSERT FoodService.Addresses ON;
INSERT INTO FoodService.Addresses (AddressID, UserID, Title, Street, City, State, PostalCode, IsDefault) VALUES
(1, 1, 'Home',   '12 Maple Street',      'Springfield', 'IL', '62701', 1),
(2, 1, 'Work',   '400 Corporate Plaza',  'Springfield', 'IL', '62702', 0),
(3, 2, 'Home',   '88 Sunset Boulevard',  'Riverdale',   'NY', '10471', 1),
(4, 3, 'Home',   '215 Elm Court',        'Lakeview',    'CA', '90210', 1),
(5, 4, 'Home',   '77 Birch Lane',        'Hillsborough','NJ', '08844', 1),
(6, 5, 'Home',   '33 Pine Avenue',       'Brookfield',  'WI', '53005', 1),
(7, 6, 'Home',   '9 Willow Way',         'Greenfield',  'MA', '01301', 1),
(8, 6, 'Work',   '1200 Market Street',   'Greenfield',  'MA', '01301', 0);
SET IDENTITY_INSERT FoodService.Addresses OFF;
GO

SET IDENTITY_INSERT FoodService.Restaurants ON;
INSERT INTO FoodService.Restaurants (RestaurantID, Name, Description, Address, Phone, ImageURL, OpeningHours, IsActive) VALUES
(1, 'Pizza Palace',       'Classic wood-fired pizzas and Italian favorites', '10 Bakery Row, Springfield, IL',   '15559990001', '/images/pizza_palace.jpg',   '10:00-23:00', 1),
(2, 'Sushi World',        'Fresh sushi and Japanese specialties',            '55 Harbor Street, Riverdale, NY',  '15559990002', '/images/sushi_world.jpg',    '11:00-22:00', 1),
(3, 'Burger House',       'Hand-pressed burgers and crispy fries',           '21 Grill Avenue, Lakeview, CA',    '15559990003', '/images/burger_house.jpg',   '09:00-23:30', 1),
(4, 'Curry Kingdom',      'Authentic South Asian curries and biryanis',      '8 Spice Lane, Hillsborough, NJ',   '15559990004', '/images/curry_kingdom.jpg',  '11:30-22:30', 1),
(5, 'Green Bowl Salads',  'Fresh salads and healthy grain bowls',            '3 Garden Street, Brookfield, WI',  '15559990005', '/images/green_bowl.jpg',     '08:00-20:00', 1);
SET IDENTITY_INSERT FoodService.Restaurants OFF;
GO

SET IDENTITY_INSERT FoodService.Categories ON;
INSERT INTO FoodService.Categories (CategoryID, CategoryName, Description) VALUES
(1, 'Pizza',   'Wood-fired and traditional pizzas'),
(2, 'Sushi',   'Rolls, nigiri, and sashimi'),
(3, 'Burgers', 'Beef, chicken, and plant-based burgers'),
(4, 'Curry',   'Curries, biryanis, and South Asian dishes'),
(5, 'Salads',  'Fresh salads and grain bowls');
SET IDENTITY_INSERT FoodService.Categories OFF;
GO

SET IDENTITY_INSERT FoodService.Promotions ON;
INSERT INTO FoodService.Promotions (PromotionID, Title, DiscountType, DiscountValue, StartDate, EndDate, IsActive) VALUES
(1, 'Summer Fest 20% Off',   'percent', 20.00, '2025-06-01T00:00:00', '2025-09-01T00:00:00', 1),
(2, 'Fixed $5 Off',          'fixed',    5.00, '2025-01-01T00:00:00', '2026-12-31T00:00:00', 1),
(3, 'Winter Clearance 15%',  'percent', 15.00, '2024-01-01T00:00:00', '2024-03-01T00:00:00', 0);
SET IDENTITY_INSERT FoodService.Promotions OFF;
GO

SET IDENTITY_INSERT FoodService.Foods ON;
INSERT INTO FoodService.Foods (FoodID, RestaurantID, CategoryID, PromotionID, Name, Description, Price, ImageURL, IsAvailable) VALUES
(1,  1, 1, 1,    'Margherita Pizza',      'Tomato, mozzarella, and fresh basil',          12.99, '/images/food/margherita.jpg',   1),
(2,  1, 1, NULL, 'Pepperoni Pizza',       'Classic pepperoni with mozzarella',            14.99, '/images/food/pepperoni.jpg',    1),
(3,  1, 1, 2,    'Veggie Supreme Pizza',  'Bell peppers, olives, onions, and mushrooms',  13.49, '/images/food/veggie_supreme.jpg',1),
(4,  2, 2, NULL, 'California Roll',       'Crab, avocado, and cucumber',                   9.99, '/images/food/california_roll.jpg',1),
(5,  2, 2, 2,    'Salmon Nigiri Set',     '8-piece fresh salmon nigiri',                  15.99, '/images/food/salmon_nigiri.jpg',1),
(6,  2, 2, NULL, 'Dragon Roll',           'Eel, cucumber, and avocado',                   16.50, '/images/food/dragon_roll.jpg',  1),
(7,  3, 3, NULL, 'Classic Cheeseburger',  'Beef patty with cheddar and pickles',           8.99, '/images/food/cheeseburger.jpg', 1),
(8,  3, 3, 1,    'Bacon BBQ Burger',      'Beef patty with bacon and BBQ sauce',          10.99, '/images/food/bacon_bbq.jpg',    1),
(9,  3, 3, NULL, 'Veggie Burger',         'Plant-based patty with fresh vegetables',       9.49, '/images/food/veggie_burger.jpg',1),
(10, 4, 4, NULL, 'Chicken Tikka Masala',  'Grilled chicken in creamy tomato curry',       11.99, '/images/food/tikka_masala.jpg', 1),
(11, 4, 4, 2,    'Lamb Rogan Josh',       'Slow-cooked lamb in aromatic curry sauce',     13.99, '/images/food/rogan_josh.jpg',   1),
(12, 4, 4, NULL, 'Vegetable Korma',       'Mixed vegetables in mild coconut curry',       10.49, '/images/food/veg_korma.jpg',    0),
(13, 5, 5, NULL, 'Caesar Salad',          'Romaine, parmesan, croutons, Caesar dressing',  7.99, '/images/food/caesar_salad.jpg', 1),
(14, 5, 5, 1,    'Quinoa Power Bowl',     'Quinoa, chickpeas, avocado, and greens',        9.99, '/images/food/quinoa_bowl.jpg',  1),
(15, 5, 5, NULL, 'Greek Salad',           'Tomatoes, cucumber, feta, and olives',           8.49, '/images/food/greek_salad.jpg',  1);
SET IDENTITY_INSERT FoodService.Foods OFF;
GO

SET IDENTITY_INSERT FoodService.Orders ON;
INSERT INTO FoodService.Orders (OrderID, UserID, AddressID, OrderDate, Status, Subtotal, DeliveryFee, DiscountAmount, Tax, TotalAmount, PaymentStatus) VALUES
(1,  1, 1, '2025-06-15T18:30:00', 'Delivered',        35.77, 2.99, 5.20,  3.22, 41.98, 'Paid'),
(2,  2, 3, '2025-07-01T12:15:00', 'Delivered',        36.48, 3.49, 0.00,  3.28, 43.25, 'Paid'),
(3,  3, 4, '2025-07-10T19:00:00', 'ReadyForDelivery', 36.46, 2.50, 0.00,  3.28, 42.24, 'Paid'),
(4,  4, 5, '2025-07-12T13:45:00', 'Preparing',        31.97, 3.00, 0.00,  2.88, 37.85, 'Pending'),
(5,  1, 2, '2025-07-15T20:10:00', 'Placed',            7.99, 2.99, 2.00,  0.72, 11.70, 'Pending'),
(6,  5, 6, '2025-07-16T17:25:00', 'Cancelled',         8.49, 2.99, 5.00,  0.76, 12.24, 'Failed'),
(7,  6, 7, '2025-07-17T11:05:00', 'Delivered',        21.98, 3.49, 10.00, 1.98, 27.45, 'Paid'),
(8,  2, 3, '2025-07-17T18:50:00', 'Accepted',         17.58, 2.50, 4.40,  1.58, 21.66, 'Pending'),
(9,  3, 4, '2025-07-18T09:40:00', 'Delivered',        20.98, 3.00, 5.00,  1.89, 25.87, 'Paid'),
(10, 6, 8, '2025-07-18T14:20:00', 'ReadyForDelivery', 24.97, 2.99, 0.00,  2.25, 30.21, 'Paid');
SET IDENTITY_INSERT FoodService.Orders OFF;
GO

SET IDENTITY_INSERT FoodService.OrderItems ON;
INSERT INTO FoodService.OrderItems (OrderItemID, OrderID, FoodID, Quantity, UnitPrice, TotalPrice, SpecialNote) VALUES
(1,  1, 1,  2, 10.39, 20.78, 'Extra basil please'),
(2,  1, 2,  1, 14.99, 14.99, NULL),
(3,  2, 4,  2,  9.99, 19.98, NULL),
(4,  2, 6,  1, 16.50, 16.50, 'No wasabi'),
(5,  3, 7,  3,  8.99, 26.97, NULL),
(6,  3, 9,  1,  9.49,  9.49, 'No onions'),
(7,  4, 10, 2, 11.99, 23.98, 'Medium spicy'),
(8,  4, 13, 1,  7.99,  7.99, NULL),
(9,  5, 14, 1,  7.99,  7.99, NULL),
(10, 6, 3,  1,  8.49,  8.49, NULL),
(11, 7, 5,  2, 10.99, 21.98, NULL),
(12, 8, 8,  2,  8.79, 17.58, 'Extra sauce'),
(13, 9, 11, 1,  8.99,  8.99, NULL),
(14, 9, 10, 1, 11.99, 11.99, NULL),
(15, 10, 15,2,  8.49, 16.98, NULL),
(16, 10, 13,1,  7.99,  7.99, NULL);
SET IDENTITY_INSERT FoodService.OrderItems OFF;
GO

SET IDENTITY_INSERT FoodService.Payments ON;
INSERT INTO FoodService.Payments (PaymentID, OrderID, Amount, PaymentMethod, PaymentStatus, TransactionRef, PaidAt) VALUES
(1,  1, 41.98, 'CreditCard', 'Success', 'TXN-FS-000001', '2025-06-15T18:32:00'),
(2,  2, 43.25, 'DebitCard',  'Success', 'TXN-FS-000002', '2025-07-01T12:17:00'),
(3,  3, 42.24, 'Wallet',     'Success', 'TXN-FS-000003', '2025-07-10T19:02:00'),
(4,  4, 37.85, 'Cash',       'Pending', NULL,             NULL),
(5,  5, 11.70, 'Wallet',     'Pending', NULL,             NULL),
(6,  6, 12.24, 'CreditCard', 'Failed',  'TXN-FS-000006', '2025-07-16T17:27:00'),
(7,  7, 27.45, 'DebitCard',  'Success', 'TXN-FS-000007', '2025-07-17T11:07:00'),
(8,  8, 21.66, 'Cash',       'Pending', NULL,             NULL),
(9,  9, 25.87, 'CreditCard', 'Success', 'TXN-FS-000009', '2025-07-18T09:42:00'),
(10, 10, 30.21, 'Wallet',    'Success', 'TXN-FS-000010', '2025-07-18T14:22:00');
SET IDENTITY_INSERT FoodService.Payments OFF;
GO

SET IDENTITY_INSERT FoodService.FoodReviews ON;
INSERT INTO FoodService.FoodReviews (ReviewID, UserID, FoodID, OrderItemID, Rating, Comment, CreatedAt) VALUES
(1, 1, 1,  1,  5, 'Amazing pizza, best Margherita in town!',        '2025-06-16T10:00:00'),
(2, 2, 4,  3,  4, 'Fresh and tasty rolls.',                          '2025-07-02T09:30:00'),
(3, 2, 6,  4,  5, 'Dragon roll was fantastic.',                      '2025-07-02T09:35:00'),
(4, 6, 5,  11, 4, 'Good salmon nigiri, a bit pricey.',               '2025-07-18T08:00:00'),
(5, 3, 11, 13, 5, 'Rich and flavorful curry.',                       '2025-07-19T07:45:00'),
(6, 3, 10, 14, 3, 'Tikka masala was okay, a bit too spicy for me.',  '2025-07-19T07:50:00');
SET IDENTITY_INSERT FoodService.FoodReviews OFF;
GO

SET IDENTITY_INSERT FoodService.FoodLogs ON;
INSERT INTO FoodService.FoodLogs (LogID, EntityType, EntityID, Action, Details, CreatedBy, IPAddress, CreatedAt) VALUES
(1, 'Order', 1,  'Create',       'Order created via sp_CreateOrder',        1, '192.168.1.10', '2025-06-15T18:30:00'),
(2, 'Order', 1,  'StatusChange', 'Status changed to Delivered',             7, '192.168.1.1',  '2025-06-15T19:10:00'),
(3, 'Order', 2,  'Create',       'Order created via sp_CreateOrder',        2, '192.168.1.11', '2025-07-01T12:15:00'),
(4, 'Order', 3,  'StatusChange', 'Status changed to ReadyForDelivery',      7, '192.168.1.1',  '2025-07-10T19:00:00'),
(5, 'Order', 6,  'StatusChange', 'Status changed to Cancelled',             5, '192.168.1.15', '2025-07-16T17:26:00'),
(6, 'Order', 9,  'StatusChange', 'Status changed to Delivered',             7, '192.168.1.1',  '2025-07-18T10:15:00'),
(7, 'Order', 10, 'StatusChange', 'Status changed to ReadyForDelivery',      7, '192.168.1.1',  '2025-07-18T14:20:00'),
(8, 'User',  1,  'InsertPassenger','Passenger created for UserID=1',        NULL, NULL,          '2025-01-10T09:00:01');
SET IDENTITY_INSERT FoodService.FoodLogs OFF;
GO

SET IDENTITY_INSERT RideService.Drivers ON;
INSERT INTO RideService.Drivers (DriverID, UserRef, FullName, Phone, LicenseNumber, LicenseExpiryDate, HomeAddress, Rating, IsActive) VALUES
(1, 9,  'Amir Hosseini', '15551234509', 'DL-10293', '2027-05-01', '55 Oak Street, Springfield, IL',  4.50, 1),
(2, 10, 'Layla Nasser',  '15551234510', 'DL-20481', '2026-11-20', '12 Cedar Avenue, Riverdale, NY',   4.80, 1),
(3, 11, 'Kevin Chen',    '15551234511', 'DL-33920', '2028-02-15', '9 Palm Court, Lakeview, CA',       4.20, 1),
(4, 12, 'Sophia Rossi',  '15551234512', 'DL-44810', '2025-09-01', '77 Rose Lane, Hillsborough, NJ',   NULL, 0),
(5, 13, 'Omar Farouk',   '15551234513', 'DL-55210', '2027-08-10', '4 Birch Road, Brookfield, WI',     4.60, 1);
SET IDENTITY_INSERT RideService.Drivers OFF;
GO

SET IDENTITY_INSERT RideService.Vehicles ON;
INSERT INTO RideService.Vehicles (VehicleID, DriverID, PlateNumber, Model, Color, Type, Capacity, IsActive) VALUES
(1, 1, 'ABC-1234', 'Toyota Corolla', 'White',  'Sedan',      4, 1),
(2, 2, 'ABC-5678', 'Honda Civic',    'Black',  'Sedan',      4, 1),
(3, 3, 'XYZ-9012', 'Ford Transit',   'Silver', 'Van',        6, 1),
(4, 4, 'MTB-3344', 'Yamaha NMAX',    'Red',    'Motorcycle', 1, 0),
(5, 5, 'ABC-7799', 'Toyota Camry',   'Blue',   'Sedan',      4, 1);
SET IDENTITY_INSERT RideService.Vehicles OFF;
GO

SET IDENTITY_INSERT RideService.DriverShift ON;
INSERT INTO RideService.DriverShift (ShiftID, DriverID, ShiftDate, StartTime, EndTime, IsActive) VALUES
(1,  1, '2025-07-17', '2025-07-17T08:00:00', '2025-07-17T16:00:00', 0),
(2,  1, '2025-07-18', '2025-07-18T08:00:00', '2025-07-18T16:00:00', 1),
(3,  2, '2025-07-17', '2025-07-17T09:00:00', '2025-07-17T17:00:00', 0),
(4,  2, '2025-07-18', '2025-07-18T09:00:00', '2025-07-18T17:00:00', 1),
(5,  3, '2025-07-17', '2025-07-17T07:00:00', '2025-07-17T15:00:00', 0),
(6,  3, '2025-07-18', '2025-07-18T07:00:00', '2025-07-18T15:00:00', 1),
(7,  4, '2025-06-20', '2025-06-20T10:00:00', '2025-06-20T18:00:00', 0),
(8,  5, '2025-07-17', '2025-07-17T06:00:00', '2025-07-17T14:00:00', 0),
(9,  5, '2025-07-18', '2025-07-18T06:00:00', '2025-07-18T14:00:00', 1),
(10, 5, '2025-07-19', '2025-07-19T06:00:00', '2025-07-19T14:00:00', 0);
SET IDENTITY_INSERT RideService.DriverShift OFF;
GO

SET IDENTITY_INSERT RideService.Passengers ON;
INSERT INTO RideService.Passengers (PassengerID, UserRef, FullName, Phone, DefaultPaymentMethod) VALUES
(1,  1,  'John Carter',     '15551234501', 'CreditCard'),
(2,  2,  'Sara Ahmadi',     '15551234502', 'Wallet'),
(3,  3,  'Mohammad Rezaei', '15551234503', 'Cash'),
(4,  4,  'Elena Petrova',   '15551234504', 'DebitCard'),
(5,  5,  'David Kim',       '15551234505', 'Cash'),
(6,  6,  'Fatima Zahra',    '15551234506', 'Wallet'),
(7,  7,  'Admin Root',      '15551234507', 'Cash'),
(8,  8,  'Nora Bennett',    '15551234508', 'CreditCard'),
(9,  9,  'Amir Hosseini',   '15551234509', 'Cash'),
(10, 10, 'Layla Nasser',    '15551234510', 'Wallet'),
(11, 11, 'Kevin Chen',      '15551234511', 'CreditCard'),
(12, 12, 'Sophia Rossi',    '15551234512', 'Cash'),
(13, 13, 'Omar Farouk',     '15551234513', 'DebitCard');
SET IDENTITY_INSERT RideService.Passengers OFF;
GO

SET IDENTITY_INSERT RideService.Locations ON;
INSERT INTO RideService.Locations (LocationID, Address, Latitude, Longitude, LocationType) VALUES
(1,  '10 Bakery Row, Springfield, IL',   39.781700, -89.650400, 'Restaurant'),
(2,  '55 Harbor Street, Riverdale, NY',  40.885700, -73.912800, 'Restaurant'),
(3,  '21 Grill Avenue, Lakeview, CA',    34.090800, -118.291500,'Restaurant'),
(4,  '8 Spice Lane, Hillsborough, NJ',   40.499000, -74.647300, 'Restaurant'),
(5,  '3 Garden Street, Brookfield, WI',  43.060700, -88.107900, 'Restaurant'),
(6,  '12 Maple Street, Springfield, IL', 39.798400, -89.644300, 'Customer'),
(7,  '88 Sunset Boulevard, Riverdale, NY',40.891200,-73.902100, 'Customer'),
(8,  '215 Elm Court, Lakeview, CA',      34.080200, -118.300900,'Customer'),
(9,  '77 Birch Lane, Hillsborough, NJ',  40.508800, -74.632100, 'Customer'),
(10, '9 Willow Way, Greenfield, MA',     42.586700, -72.598900, 'Customer'),
(11, 'Downtown Transit Station',        39.799000, -89.644400, 'Pickup'),
(12, 'City Airport Terminal',           40.639800, -73.778900, 'Dropoff');
SET IDENTITY_INSERT RideService.Locations OFF;
GO

SET IDENTITY_INSERT RideService.DriverLocations ON;
INSERT INTO RideService.DriverLocations (DriverLocationID, DriverID, LocationID, RecordedAt, Status) VALUES
(1, 1, 6,  '2025-07-18T08:05:00', 'Online'),
(2, 2, 7,  '2025-07-18T09:05:00', 'Online'),
(3, 3, 8,  '2025-07-18T07:05:00', 'OnTrip'),
(4, 5, 10, '2025-07-18T06:05:00', 'Online'),
(5, 1, 11, '2025-07-18T12:30:00', 'OnTrip'),
(6, 4, 9,  '2025-06-20T10:05:00', 'Offline');
SET IDENTITY_INSERT RideService.DriverLocations OFF;
GO

SET IDENTITY_INSERT RideService.RideRequests ON;
INSERT INTO RideService.RideRequests (RideRequestID, PassengerID, PickupLocationID, DropoffLocationID, RequestTime, Status) VALUES
(1, 1, 6,  11, '2025-07-17T08:10:00', 'completed'),
(2, 2, 7,  12, '2025-07-17T09:15:00', 'completed'),
(3, 3, 8,  11, '2025-07-17T07:20:00', 'completed'),
(4, 4, 9,  12, '2025-07-18T13:00:00', 'accepted'),
(5, 5, 10, 11, '2025-07-18T13:30:00', 'pending'),
(6, 6, 6,  12, '2025-07-16T18:00:00', 'cancelled'),
(7, 1, 11, 7,  '2025-07-18T09:00:00', 'completed'),
(8, 2, 12, 8,  '2025-07-18T14:10:00', 'accepted');
SET IDENTITY_INSERT RideService.RideRequests OFF;
GO

SET IDENTITY_INSERT RideService.Trips ON;
INSERT INTO RideService.Trips (TripID, RideRequestID, DriverID, VehicleID, AcceptedAt, StartedAt, EndTime, Distance, FareAmount, Status) VALUES
(1, 1, 1, 1, '2025-07-17T08:12:00', '2025-07-17T08:15:00', '2025-07-17T08:35:00', 5.20,  56600.00, 'completed'),
(2, 2, 2, 2, '2025-07-17T09:17:00', '2025-07-17T09:20:00', '2025-07-17T09:55:00', 12.50, 115000.00,'completed'),
(3, 3, 3, 3, '2025-07-17T07:22:00', '2025-07-17T07:25:00', '2025-07-17T07:40:00', 3.10,  39800.00, 'completed'),
(4, 4, 1, 1, '2025-07-18T13:02:00', '2025-07-18T13:05:00', NULL,                  NULL,  NULL,      'started'),
(5, 7, 5, 5, '2025-07-18T09:02:00', '2025-07-18T09:05:00', '2025-07-18T09:35:00', 7.80,  77400.00, 'completed'),
(6, 8, 2, 2, '2025-07-18T14:12:00', NULL,                  NULL,                  NULL,  NULL,      'accepted');
SET IDENTITY_INSERT RideService.Trips OFF;
GO

SET IDENTITY_INSERT RideService.RidePayments ON;
INSERT INTO RideService.RidePayments (RidePaymentID, TripID, Amount, PaymentMethod, PaymentStatus, TransactionRef, PaidAt) VALUES
(1, 1, 56600.00,  'Cash',       'success', 'TXN-RS-000001', '2025-07-17T08:36:00'),
(2, 2, 115000.00, 'CreditCard', 'success', 'TXN-RS-000002', '2025-07-17T09:56:00'),
(3, 3, 39800.00,  'Wallet',     'success', 'TXN-RS-000003', '2025-07-17T07:41:00'),
(4, 5, 77400.00,  'Cash',       'success', 'TXN-RS-000004', '2025-07-18T09:36:00');
SET IDENTITY_INSERT RideService.RidePayments OFF;
GO

SET IDENTITY_INSERT RideService.RideReviews ON;
INSERT INTO RideService.RideReviews (ReviewID, TripID, PassengerID, DriverID, Rating, Comment, CreatedAt) VALUES
(1, 1, 1, 1, 5, 'Great driver, smooth ride!',            '2025-07-17T09:00:00'),
(2, 2, 2, 2, 4, 'Comfortable car, arrived on time.',     '2025-07-17T10:10:00'),
(3, 3, 3, 3, 5, 'Very professional driver.',             '2025-07-17T08:00:00'),
(4, 5, 1, 5, 4, 'Good service overall.',                 '2025-07-18T10:00:00');
SET IDENTITY_INSERT RideService.RideReviews OFF;
GO

SET IDENTITY_INSERT RideService.DeliveryRequests ON;
INSERT INTO RideService.DeliveryRequests (DeliveryRequestID, DriverID, OrderRef, PickupLocationID, DropoffLocationID, RequestTime, AssignedAt, DeliveredAt, Status) VALUES
(1, 1,    1, 1, 6,  '2025-06-15T18:35:00', '2025-06-15T18:40:00', '2025-06-15T19:05:00', 'Delivered'),
(2, 2,    2, 2, 7,  '2025-07-01T12:20:00', '2025-07-01T12:25:00', '2025-07-01T12:50:00', 'Delivered'),
(3, NULL, 3, 3, 8,  '2025-07-10T19:05:00', NULL,                   NULL,                  'PendingAssignment'),
(4, 5,    7, 2, 10, '2025-07-17T11:10:00', '2025-07-17T11:15:00', '2025-07-17T11:40:00', 'Delivered'),
(5, 3,    9, 4, 8,  '2025-07-18T09:45:00', '2025-07-18T09:50:00', '2025-07-18T10:15:00', 'Delivered'),
(6, NULL, 10,5, 10, '2025-07-18T14:25:00', NULL,                   NULL,                  'PendingAssignment');
SET IDENTITY_INSERT RideService.DeliveryRequests OFF;
GO
SET IDENTITY_INSERT RideService.RideLogs ON;
INSERT INTO RideService.RideLogs (LogID, EntityType, EntityID, Action, Details, CreatedBy, IPAddress, CreatedAt) VALUES
(1, 'Trip', 1, 'AssignDriver', 'Driver 1 assigned via sp_AssignDriverToRequest', 7, '192.168.1.1', '2025-07-17T08:12:00'),
(2, 'Trip', 1, 'Complete',     'Trip completed and payment recorded',            7, '192.168.1.1', '2025-07-17T08:36:00'),
(3, 'Trip', 2, 'AssignDriver', 'Driver 2 assigned via sp_AssignDriverToRequest', 7, '192.168.1.1', '2025-07-17T09:17:00'),
(4, 'Trip', 2, 'Complete',     'Trip completed and payment recorded',            7, '192.168.1.1', '2025-07-17T09:56:00'),
(5, 'Driver', 1, 'UpdateRating', 'Rating recalculated after ReviewID=1',         NULL, NULL,        '2025-07-17T09:00:01'),
(6, 'Driver', 2, 'UpdateRating', 'Rating recalculated after ReviewID=2',         NULL, NULL,        '2025-07-17T10:10:01'),
(7, 'DeliveryRequest', 1, 'AssignDriver', 'Driver 1 assigned via sp_AssignDriverToDeliveryRequest', 7, '192.168.1.1', '2025-06-15T18:40:00'),
(8, 'DeliveryRequest', 3, 'CrossSchemaSync', 'DeliveryRequest created in RideService (PendingAssignment)', NULL, NULL, '2025-07-10T19:05:00');
SET IDENTITY_INSERT RideService.RideLogs OFF;
GO

DECLARE @sql_enable NVARCHAR(MAX) = '';
SELECT @sql_enable = @sql_enable + 'ENABLE TRIGGER ALL ON ' + 
                     QUOTENAME(OBJECT_SCHEMA_NAME(parent_id)) + '.' + 
                     QUOTENAME(OBJECT_NAME(parent_id)) + ';'
FROM sys.triggers;
EXEC sp_executesql @sql_enable;
GO

