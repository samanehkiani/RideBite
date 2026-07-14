USE RideBite;
GO

DROP VIEW IF EXISTS FoodService.vw_OrderDetails;
DROP VIEW IF EXISTS FoodService.vw_FoodMenu;
DROP VIEW IF EXISTS FoodService.vw_DailySalesReport;
GO

CREATE VIEW FoodService.vw_OrderDetails
AS
SELECT 
    o.OrderID,
    u.FullName AS CustomerName,
    u.Phone,
    a.Street,
    a.City,
    a.State,
    o.OrderDate,
    o.Status,
    o.TotalAmount,
    o.PaymentStatus,
    COUNT(oi.OrderItemID) AS ItemCount,
    SUM(oi.Quantity) AS TotalItems
FROM FoodService.Orders o
INNER JOIN FoodService.Users u ON o.UserID = u.UserID
INNER JOIN FoodService.Addresses a ON o.AddressID = a.AddressID
INNER JOIN FoodService.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, u.FullName, u.Phone, a.Street, a.City, a.State,
         o.OrderDate, o.Status, o.TotalAmount, o.PaymentStatus;
GO

CREATE VIEW FoodService.vw_FoodMenu
AS
SELECT
    f.FoodID,
    f.Name AS FoodName,
    f.Description,
    f.Price,
    f.IsAvailable,
    r.Name AS RestaurantName,
    r.IsActive AS RestaurantActive,
    c.CategoryName,
    p.Title AS PromotionTitle,
    p.DiscountType,
    p.DiscountValue
FROM FoodService.Foods f
INNER JOIN FoodService.Restaurants r ON f.RestaurantID = r.RestaurantID
INNER JOIN FoodService.Categories c ON f.CategoryID = c.CategoryID
LEFT JOIN FoodService.Promotions p ON f.PromotionID = p.PromotionID;
GO

CREATE VIEW FoodService.vw_DailySalesReport
AS
SELECT 
    CAST(o.OrderDate AS DATE) AS SaleDate,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COUNT(DISTINCT o.UserID) AS UniqueCustomers,
    SUM(o.Subtotal) AS TotalSubtotal,
    SUM(o.DeliveryFee) AS TotalDeliveryFees,
    SUM(o.DiscountAmount) AS TotalDiscounts,
    SUM(o.Tax) AS TotalTax,
    SUM(o.TotalAmount) AS TotalRevenue,
    AVG(o.TotalAmount) AS AverageOrderValue
FROM FoodService.Orders o
WHERE o.Status = 'Delivered' 
    AND o.PaymentStatus = 'Paid'
GROUP BY CAST(o.OrderDate AS DATE);
GO