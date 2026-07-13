CREATE TABLE FoodService.Users
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,

    FullName NVARCHAR(100) NOT NULL,

    Phone VARCHAR(15) NOT NULL,

    Email NVARCHAR(100) NOT NULL,

    PasswordHash NVARCHAR(255) NOT NULL,

    UserType VARCHAR(20) NOT NULL,

    Status VARCHAR(20) NOT NULL,

    CreatedAt DATETIME2 NOT NULL,

    UpdatedAt DATETIME2 NOT NULL
);
GO
CREATE TABLE FoodService.Addresses
(
    AddressID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL,

    Title NVARCHAR(50) NOT NULL,

    Street NVARCHAR(200) NOT NULL,

    City NVARCHAR(50) NOT NULL,

    State NVARCHAR(50) NOT NULL,

    PostalCode VARCHAR(10) NOT NULL,

    IsDefault BIT NOT NULL
);
GO
CREATE TABLE FoodService.Restaurants
(
    RestaurantID INT IDENTITY(1,1) PRIMARY KEY,

    Name NVARCHAR(100) NOT NULL,

    Description NVARCHAR(500) NULL,

    Address NVARCHAR(200) NOT NULL,

    Phone VARCHAR(15) NOT NULL,

    ImageURL NVARCHAR(255) NULL,

    OpeningHours NVARCHAR(100) NOT NULL,

    IsActive BIT NOT NULL
);
GO
CREATE TABLE FoodService.Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,

    CategoryName NVARCHAR(50) NOT NULL,

    Description NVARCHAR(200) NULL
);
GO
CREATE TABLE FoodService.Promotions
(
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,

    Title NVARCHAR(100) NOT NULL,

    DiscountType VARCHAR(10) NOT NULL,

    DiscountValue DECIMAL(10,2) NOT NULL,

    StartDate DATETIME2 NOT NULL,

    EndDate DATETIME2 NOT NULL,

    IsActive BIT NOT NULL
);
GO
CREATE TABLE FoodService.Foods
(
    FoodID INT IDENTITY(1,1) PRIMARY KEY,

    RestaurantID INT NOT NULL,

    CategoryID INT NOT NULL,

    PromotionID INT NULL,

    Name NVARCHAR(100) NOT NULL,

    Description NVARCHAR(500) NULL,

    Price DECIMAL(10,2) NOT NULL,

    ImageURL NVARCHAR(255) NULL,

    IsAvailable BIT NOT NULL
);
GO
CREATE TABLE FoodService.Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL,

    AddressID INT NOT NULL,

    OrderDate DATETIME2 NOT NULL,

    Status VARCHAR(20) NOT NULL,

    Subtotal DECIMAL(10,2) NOT NULL,

    DeliveryFee DECIMAL(10,2) NOT NULL,

    DiscountAmount DECIMAL(10,2) NOT NULL,

    Tax DECIMAL(10,2) NOT NULL,

    TotalAmount DECIMAL(10,2) NOT NULL,

    PaymentStatus VARCHAR(20) NOT NULL
);
GO
CREATE TABLE FoodService.OrderItems
(
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL,

    FoodID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(10,2) NOT NULL,

    TotalPrice DECIMAL(10,2) NOT NULL,

    SpecialNote NVARCHAR(200) NULL
);
GO
CREATE TABLE FoodService.Payments
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL,

    Amount DECIMAL(10,2) NOT NULL,

    PaymentMethod VARCHAR(20) NOT NULL,

    PaymentStatus VARCHAR(20) NOT NULL,

    TransactionRef VARCHAR(50) NULL,

    PaidAt DATETIME2 NULL
);
GO
CREATE TABLE FoodService.FoodReviews
(
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL,

    FoodID INT NOT NULL,

    OrderItemID INT NOT NULL,

    Rating TINYINT NOT NULL,

    Comment NVARCHAR(500) NULL,

    CreatedAt DATETIME2 NOT NULL
);
GO
CREATE TABLE FoodService.FoodLogs
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