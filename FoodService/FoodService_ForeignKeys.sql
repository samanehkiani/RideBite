ALTER TABLE FoodService.Addresses
ADD CONSTRAINT FK_Addresses_Users
FOREIGN KEY (UserID) REFERENCES FoodService.Users(UserID);

ALTER TABLE FoodService.Orders
ADD CONSTRAINT FK_Orders_Users
FOREIGN KEY (UserID) REFERENCES FoodService.Users(UserID);

ALTER TABLE FoodService.Orders
ADD CONSTRAINT FK_Orders_Addresses
FOREIGN KEY (AddressID) REFERENCES FoodService.Addresses(AddressID);

ALTER TABLE FoodService.Foods
ADD CONSTRAINT FK_Foods_Restaurants
FOREIGN KEY (RestaurantID) REFERENCES FoodService.Restaurants(RestaurantID);

ALTER TABLE FoodService.Foods
ADD CONSTRAINT FK_Foods_Categories
FOREIGN KEY (CategoryID) REFERENCES FoodService.Categories(CategoryID);

ALTER TABLE FoodService.Foods
ADD CONSTRAINT FK_Foods_Promotions
FOREIGN KEY (PromotionID) REFERENCES FoodService.Promotions(PromotionID);

ALTER TABLE FoodService.OrderItems
ADD CONSTRAINT FK_OrderItems_Orders
FOREIGN KEY (OrderID) REFERENCES FoodService.Orders(OrderID);

ALTER TABLE FoodService.OrderItems
ADD CONSTRAINT FK_OrderItems_Foods
FOREIGN KEY (FoodID) REFERENCES FoodService.Foods(FoodID);

ALTER TABLE FoodService.Payments
ADD CONSTRAINT FK_Payments_Orders
FOREIGN KEY (OrderID) REFERENCES FoodService.Orders(OrderID);

ALTER TABLE FoodService.FoodReviews
ADD CONSTRAINT FK_FoodReviews_Users
FOREIGN KEY (UserID) REFERENCES FoodService.Users(UserID);

ALTER TABLE FoodService.FoodReviews
ADD CONSTRAINT FK_FoodReviews_Foods
FOREIGN KEY (FoodID) REFERENCES FoodService.Foods(FoodID);

ALTER TABLE FoodService.FoodReviews
ADD CONSTRAINT FK_FoodReviews_OrderItems
FOREIGN KEY (OrderItemID) REFERENCES FoodService.OrderItems(OrderItemID);

ALTER TABLE FoodService.FoodReviews
ADD CONSTRAINT UQ_FoodReviews_OrderItemID UNIQUE (OrderItemID);