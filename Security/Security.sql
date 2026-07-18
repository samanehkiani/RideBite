USE RideBite;
GO


DROP PROCEDURE IF EXISTS Security.sp_AssignRoleToUser;
DROP FUNCTION IF EXISTS Security.fn_UserHasPermission;
DROP VIEW IF EXISTS Security.vw_UsersWithRoles;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Users_Roles')
    ALTER TABLE FoodService.Users DROP CONSTRAINT FK_Users_Roles;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_RolePermissions_Roles')
    ALTER TABLE Security.RolePermissions DROP CONSTRAINT FK_RolePermissions_Roles;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_RolePermissions_Permissions')
    ALTER TABLE Security.RolePermissions DROP CONSTRAINT FK_RolePermissions_Permissions;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_AdminUsers_Roles')
    ALTER TABLE Security.AdminUsers DROP CONSTRAINT FK_AdminUsers_Roles;
GO

DELETE FROM Security.RolePermissions;
GO

DELETE FROM Security.AdminUsers;
GO

DELETE FROM Security.Roles;
GO

DELETE FROM Security.Permissions;
GO

DBCC CHECKIDENT ('Security.Roles', RESEED, 0);
DBCC CHECKIDENT ('Security.Permissions', RESEED, 0);
DBCC CHECKIDENT ('Security.RolePermissions', RESEED, 0);
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_SCHEMA = 'FoodService' 
           AND TABLE_NAME = 'Users' 
           AND COLUMN_NAME = 'RoleID')
BEGIN
    ALTER TABLE FoodService.Users DROP COLUMN RoleID;
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_SCHEMA = 'FoodService' 
           AND TABLE_NAME = 'Users' 
           AND COLUMN_NAME = 'LastLogin')
BEGIN
    ALTER TABLE FoodService.Users DROP COLUMN LastLogin;
END
GO

ALTER TABLE FoodService.Users ADD RoleID INT NULL;
ALTER TABLE FoodService.Users ADD LastLogin DATETIME2 NULL;
GO

ALTER TABLE FoodService.Users
ADD CONSTRAINT FK_Users_Roles
FOREIGN KEY (RoleID) REFERENCES Security.Roles(RoleID);
GO

PRINT '=== Users table updated ===';
GO

IF NOT EXISTS (SELECT 1 FROM Security.Roles WHERE RoleName = 'SuperAdmin')
BEGIN
    INSERT INTO Security.Roles (RoleName, Description) VALUES
    ('SuperAdmin',   'Full system access - all modules and features'),
    ('Admin',        'Administrative access with limited system controls'),
    ('Customer',     'Regular customer - can order food and request rides'),
    ('Driver',       'Driver - can accept rides and deliveries'),
    ('RestaurantOwner', 'Restaurant owner - can manage their restaurant menu'),
    ('Support',      'Customer support - can view orders and assist customers'),
    ('Guest',        'Guest user - limited read-only access');
END
GO

PRINT '=== Roles inserted ===';
GO

IF NOT EXISTS (SELECT 1 FROM Security.Permissions WHERE PermissionName = 'Food.ViewMenu')
BEGIN
    INSERT INTO Security.Permissions (PermissionName, Description, Module) VALUES

    -- FoodService Permissions
    ('Food.ViewMenu',          'View food menu and restaurant listings', 'FoodService'),
    ('Food.ViewOrders',        'View own orders', 'FoodService'),
    ('Food.CreateOrder',       'Create new food orders', 'FoodService'),
    ('Food.UpdateOrderStatus', 'Update order status (Admin/Support)', 'FoodService'),
    ('Food.CancelOrder',       'Cancel own orders', 'FoodService'),
    ('Food.ManageRestaurants', 'Add/Edit/Delete restaurants', 'FoodService'),
    ('Food.ManageFoods',       'Add/Edit/Delete food items', 'FoodService'),
    ('Food.ManagePromotions',  'Create/Edit/Delete promotions', 'FoodService'),
    ('Food.ViewAllOrders',     'View all orders (Admin/Support)', 'FoodService'),
    ('Food.ArchiveOrders',     'Archive old orders', 'FoodService'),
    ('Food.ViewReviews',       'View food reviews', 'FoodService'),
    ('Food.SubmitReview',      'Submit food reviews', 'FoodService'),

    -- RideService Permissions
    ('Ride.ViewRides',         'View ride history', 'RideService'),
    ('Ride.RequestRide',       'Request a new ride', 'RideService'),
    ('Ride.AcceptRide',        'Accept ride requests (Driver)', 'RideService'),
    ('Ride.CompleteRide',      'Complete rides (Driver)', 'RideService'),
    ('Ride.ViewAllRides',      'View all rides (Admin)', 'RideService'),
    ('Ride.ManageDrivers',     'Add/Edit/Delete drivers', 'RideService'),
    ('Ride.ManageVehicles',    'Add/Edit/Delete vehicles', 'RideService'),
    ('Ride.ViewDriverPerformance', 'View driver performance reports', 'RideService'),
    ('Ride.ArchiveTrips',      'Archive old trips', 'RideService'),

    -- Security Permissions
    ('Security.ManageUsers',   'Add/Edit/Delete users', 'Security'),
    ('Security.ManageRoles',   'Create/Edit/Delete roles', 'Security'),
    ('Security.AssignRoles',   'Assign roles to users', 'Security'),
    ('Security.ViewAuditLogs', 'View audit logs', 'Security'),

    -- Reports Permissions
    ('Reports.ViewSales',      'View sales reports', 'Reports'),
    ('Reports.ViewDailyReport','View daily sales/rides reports', 'Reports'),
    ('Reports.ExportData',     'Export data to Excel/CSV', 'Reports'),
    ('Reports.ViewAnalytics',  'View advanced analytics', 'Reports');
END
GO

PRINT '=== Permissions inserted ===';
GO

DELETE FROM Security.RolePermissions;
GO

-- SuperAdmin (RoleID = 1)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 1, PermissionID FROM Security.Permissions;
GO

-- Admin (RoleID = 2)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 2, PermissionID FROM Security.Permissions
WHERE PermissionName NOT IN ('Security.ManageUsers', 'Security.ManageRoles', 'Security.AssignRoles');
GO

-- Customer (RoleID = 3)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 3, PermissionID FROM Security.Permissions
WHERE PermissionName IN (
    'Food.ViewMenu', 'Food.ViewOrders', 'Food.CreateOrder', 'Food.CancelOrder',
    'Food.ViewReviews', 'Food.SubmitReview',
    'Ride.ViewRides', 'Ride.RequestRide',
    'Reports.ViewSales'
);
GO

-- Driver (RoleID = 4)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 4, PermissionID FROM Security.Permissions
WHERE PermissionName IN (
    'Ride.ViewRides', 'Ride.AcceptRide', 'Ride.CompleteRide',
    'Reports.ViewSales'
);
GO

-- RestaurantOwner (RoleID = 5)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 5, PermissionID FROM Security.Permissions
WHERE PermissionName IN (
    'Food.ViewMenu', 'Food.ViewOrders', 'Food.CreateOrder',
    'Food.ManageFoods',
    'Food.ViewReviews', 'Food.SubmitReview',
    'Reports.ViewSales'
);
GO

-- Support (RoleID = 6)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 6, PermissionID FROM Security.Permissions
WHERE PermissionName IN (
    'Food.ViewMenu', 'Food.ViewOrders', 'Food.UpdateOrderStatus',
    'Food.ViewAllOrders', 'Food.ViewReviews',
    'Ride.ViewRides',
    'Reports.ViewSales'
);
GO

-- Guest (RoleID = 7)
INSERT INTO Security.RolePermissions (RoleID, PermissionID)
SELECT 7, PermissionID FROM Security.Permissions
WHERE PermissionName IN ('Food.ViewMenu', 'Ride.ViewRides');
GO

PRINT '=== Permissions assigned to roles ===';
GO

CREATE FUNCTION Security.fn_UserHasPermission
(
    @UserID     INT,
    @Permission NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    SELECT @Result = 1
    FROM FoodService.Users u
    INNER JOIN Security.RolePermissions rp ON u.RoleID = rp.RoleID
    INNER JOIN Security.Permissions p ON rp.PermissionID = p.PermissionID
    WHERE u.UserID = @UserID
        AND p.PermissionName = @Permission
        AND u.Status = 'Active';

    RETURN ISNULL(@Result, 0);
END;
GO

PRINT '=== fn_UserHasPermission created ===';
GO

CREATE PROCEDURE Security.sp_AssignRoleToUser
    @UserID INT,
    @RoleID INT,
    @AdminUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF Security.fn_UserHasPermission(@AdminUserID, 'Security.AssignRoles') = 0
    BEGIN
        RAISERROR('You do not have permission to assign roles.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM FoodService.Users WHERE UserID = @UserID)
    BEGIN
        RAISERROR('User not found.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Security.Roles WHERE RoleID = @RoleID)
    BEGIN
        RAISERROR('Role not found.', 16, 1);
        RETURN;
    END

    UPDATE FoodService.Users
    SET RoleID = @RoleID,
        UpdatedAt = SYSDATETIME()
    WHERE UserID = @UserID;

    INSERT INTO FoodService.FoodLogs (EntityType, EntityID, Action, Details, CreatedBy, CreatedAt)
    VALUES ('User', @UserID, 'AssignRole', CONCAT('RoleID ', @RoleID, ' assigned by Admin ', @AdminUserID), @AdminUserID, SYSDATETIME());

    PRINT CONCAT('Role assigned to UserID ', @UserID, ' successfully.');
END;
GO

PRINT '=== sp_AssignRoleToUser created ===';
GO

UPDATE FoodService.Users SET RoleID = 1 WHERE UserID = 7;
UPDATE FoodService.Users SET RoleID = 2 WHERE UserID = 8;
UPDATE FoodService.Users SET RoleID = 3 WHERE UserID IN (1,2,3,4,5,6);
UPDATE FoodService.Users SET RoleID = 4 WHERE UserID IN (9,10,11,12,13);
GO

PRINT '=== Users updated with roles ===';
GO

CREATE VIEW Security.vw_UsersWithRoles
AS
SELECT
    u.UserID,
    u.FullName,
    u.Email,
    u.UserType,
    u.Status,
    r.RoleID,
    r.RoleName,
    r.Description AS RoleDescription,
    u.CreatedAt,
    u.LastLogin
FROM FoodService.Users u
LEFT JOIN Security.Roles r ON u.RoleID = r.RoleID;
GO

PRINT '=== vw_UsersWithRoles created ===';
GO

PRINT '========================================';
PRINT '=== SETUP COMPLETE! ===';
PRINT '========================================';
PRINT '';

SELECT '=== Users with Roles ===' AS [Status];
SELECT * FROM Security.vw_UsersWithRoles;
PRINT '';

SELECT '=== Permission Tests ===' AS [Status];
SELECT 
    'Customer (UserID=1) can create order' AS Test,
    CASE WHEN Security.fn_UserHasPermission(1, 'Food.CreateOrder') = 1 THEN '✅ PASS' ELSE '❌ FAIL' END AS Result;
    
SELECT 
    'Customer (UserID=1) cannot manage foods' AS Test,
    CASE WHEN Security.fn_UserHasPermission(1, 'Food.ManageFoods') = 0 THEN '✅ PASS' ELSE '❌ FAIL' END AS Result;
    
SELECT 
    'SuperAdmin (UserID=7) can assign roles' AS Test,
    CASE WHEN Security.fn_UserHasPermission(7, 'Security.AssignRoles') = 1 THEN '✅ PASS' ELSE '❌ FAIL' END AS Result;
PRINT '';

GO