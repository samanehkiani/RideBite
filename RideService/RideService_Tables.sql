CREATE TABLE RideService.Drivers
(
    DriverID INT IDENTITY(1,1) PRIMARY KEY,

    UserRef INT NOT NULL,

    FullName NVARCHAR(100) NOT NULL,

    Phone VARCHAR(15) NOT NULL,

    LicenseNumber VARCHAR(30) NOT NULL,

    LicenseExpiryDate DATE NOT NULL,

    HomeAddress NVARCHAR(200) NULL,

    Rating DECIMAL(3,2) NULL,

    IsActive BIT NOT NULL
);
GO
CREATE TABLE RideService.Vehicles
(
    VehicleID INT IDENTITY(1,1) PRIMARY KEY,

    DriverID INT NOT NULL,

    PlateNumber VARCHAR(15) NOT NULL,

    Model NVARCHAR(50) NOT NULL,

    Color VARCHAR(30) NOT NULL,

    Type VARCHAR(20) NOT NULL,

    Capacity TINYINT NOT NULL,

    IsActive BIT NOT NULL
);
GO
CREATE TABLE RideService.DriverShift
(
    ShiftID INT IDENTITY(1,1) PRIMARY KEY,

    DriverID INT NOT NULL,

    ShiftDate DATE NOT NULL,

    StartTime DATETIME2 NOT NULL,

    EndTime DATETIME2 NOT NULL,

    IsActive BIT NOT NULL
);
GO
CREATE TABLE RideService.Passengers
(
    PassengerID INT IDENTITY(1,1) PRIMARY KEY,

    UserRef INT NOT NULL,

    FullName NVARCHAR(100) NOT NULL,

    Phone VARCHAR(15) NOT NULL,

    DefaultPaymentMethod VARCHAR(20) NOT NULL
);
GO
CREATE TABLE RideService.Locations
(
    LocationID INT IDENTITY(1,1) PRIMARY KEY,

    Address NVARCHAR(200) NOT NULL,

    Latitude DECIMAL(9,6) NOT NULL,

    Longitude DECIMAL(9,6) NOT NULL,

    LocationType VARCHAR(20) NOT NULL
);
GO
CREATE TABLE RideService.DriverLocations
(
    DriverLocationID INT IDENTITY(1,1) PRIMARY KEY,

    DriverID INT NOT NULL,

    LocationID INT NOT NULL,

    RecordedAt DATETIME2 NOT NULL,

    Status VARCHAR(20) NOT NULL
);
GO
CREATE TABLE RideService.RideRequests
(
    RideRequestID INT IDENTITY(1,1) PRIMARY KEY,

    PassengerID INT NOT NULL,

    PickupLocationID INT NOT NULL,

    DropoffLocationID INT NOT NULL,

    RequestTime DATETIME2 NOT NULL,

    Status VARCHAR(20) NOT NULL
);
GO
CREATE TABLE RideService.Trips
(
    TripID INT IDENTITY(1,1) PRIMARY KEY,

    RideRequestID INT NOT NULL,

    DriverID INT NOT NULL,

    VehicleID INT NOT NULL,

    AcceptedAt DATETIME2 NULL,

    StartedAt DATETIME2 NULL,

    EndTime DATETIME2 NULL,

    Distance DECIMAL(6,2) NULL,

    FareAmount DECIMAL(10,2) NULL,

    Status VARCHAR(20) NOT NULL
);
GO
CREATE TABLE RideService.RidePayments
(
    RidePaymentID INT IDENTITY(1,1) PRIMARY KEY,

    TripID INT NOT NULL,

    Amount DECIMAL(10,2) NOT NULL,

    PaymentMethod VARCHAR(20) NOT NULL,

    PaymentStatus VARCHAR(20) NOT NULL,

    TransactionRef VARCHAR(50) NULL,

    PaidAt DATETIME2 NULL
);
GO
CREATE TABLE RideService.RideReviews
(
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,

    TripID INT NOT NULL,

    PassengerID INT NOT NULL,

    DriverID INT NOT NULL,

    Rating TINYINT NOT NULL,

    Comment NVARCHAR(500) NULL,

    CreatedAt DATETIME2 NOT NULL
);
GO
CREATE TABLE RideService.DeliveryRequests
(
    DeliveryRequestID INT IDENTITY(1,1) PRIMARY KEY,

    DriverID INT NOT NULL,

    OrderRef INT NOT NULL,

    PickupLocationID INT NOT NULL,

    DropoffLocationID INT NOT NULL,

    RequestTime DATETIME2 NOT NULL,

    AssignedAt DATETIME2 NULL,

    DeliveredAt DATETIME2 NULL,

    Status VARCHAR(20) NOT NULL
);
GO
CREATE TABLE RideService.RideLogs
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,

    EntityType VARCHAR(50) NOT NULL,

    EntityID INT NOT NULL,

    Action VARCHAR(50) NOT NULL,

    Details NVARCHAR(500) NULL,

    CreatedBy INT NULL,

    IPAddress VARCHAR(45) NULL,

    CreatedAt DATETIME2 NOT NULL
);
GO