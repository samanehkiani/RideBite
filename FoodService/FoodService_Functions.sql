USE RideBite;
GO

DROP FUNCTION IF EXISTS FoodService.fn_GetOrderTotal;
DROP FUNCTION IF EXISTS FoodService.fn_GetFoodDiscountedPrice;
DROP FUNCTION IF EXISTS FoodService.fn_GetOrderItemsSubtotal;
DROP FUNCTION IF EXISTS FoodService.fn_GetOrderItemsDetails;
DROP FUNCTION IF EXISTS FoodService.fn_GetAverageFoodRating;
DROP FUNCTION IF EXISTS FoodService.fn_IsFoodAvailable;
GO

CREATE FUNCTION FoodService.fn_GetFoodDiscountedPrice
(
    @FoodID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @FinalPrice DECIMAL(10,2);
    DECLARE @Price DECIMAL(10,2);
    DECLARE @DiscountType VARCHAR(10);
    DECLARE @DiscountValue DECIMAL(10,2);
    DECLARE @IsPromoActive BIT;

    SELECT
        @Price = f.Price,
        @DiscountType = p.DiscountType,
        @DiscountValue = p.DiscountValue,
        @IsPromoActive =
            CASE
                WHEN p.PromotionID IS NOT NULL
                     AND p.IsActive = 1
                     AND GETDATE() BETWEEN p.StartDate AND p.EndDate
                THEN 1
                ELSE 0
            END
    FROM FoodService.Foods f
    LEFT JOIN FoodService.Promotions p
        ON f.PromotionID = p.PromotionID
    WHERE f.FoodID = @FoodID;

    IF @IsPromoActive = 1
    BEGIN
        IF @DiscountType = 'percent'
            SET @FinalPrice = @Price - (@Price * @DiscountValue / 100.0);
        ELSE
            SET @FinalPrice = @Price - @DiscountValue;
    END
    ELSE
        SET @FinalPrice = @Price;

    IF @FinalPrice < 0
        SET @FinalPrice = 0;

    RETURN @FinalPrice;
END;
GO

CREATE FUNCTION FoodService.fn_GetOrderItemsSubtotal
(
    @OrderID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);

    SELECT @Total = SUM(TotalPrice)
    FROM FoodService.OrderItems
    WHERE OrderID = @OrderID;

    RETURN ISNULL(@Total,0);
END;
GO

CREATE FUNCTION FoodService.fn_GetOrderItemsDetails
(
    @OrderID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        oi.OrderItemID,
        oi.OrderID,
        f.FoodID,
        f.Name AS FoodName,
        r.Name AS RestaurantName,
        oi.Quantity,
        oi.UnitPrice,
        oi.TotalPrice,
        oi.SpecialNote
    FROM FoodService.OrderItems oi
    INNER JOIN FoodService.Foods f
        ON oi.FoodID = f.FoodID
    INNER JOIN FoodService.Restaurants r
        ON f.RestaurantID = r.RestaurantID
    WHERE oi.OrderID = @OrderID
);
GO

CREATE FUNCTION FoodService.fn_GetAverageFoodRating
(
    @FoodID INT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @AverageRating DECIMAL(3,2);

    SELECT @AverageRating =
        AVG(CAST(Rating AS DECIMAL(3,2)))
    FROM FoodService.FoodReviews
    WHERE FoodID = @FoodID;

    RETURN ISNULL(@AverageRating,0);
END;
GO

CREATE FUNCTION FoodService.fn_IsFoodAvailable
(
    @FoodID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;

    SELECT @Result =
        CASE
            WHEN f.IsAvailable = 1
             AND r.IsActive = 1
            THEN 1
            ELSE 0
        END
    FROM FoodService.Foods f
    INNER JOIN FoodService.Restaurants r
        ON f.RestaurantID = r.RestaurantID
    WHERE f.FoodID = @FoodID;

    RETURN ISNULL(@Result,0);
END;
GO