SELECT * FROM Security.vw_UsersWithRoles;

SELECT Security.fn_UserHasPermission(1, 'Food.CreateOrder');  -- 1
SELECT Security.fn_UserHasPermission(1, 'Food.ManageFoods');  -- 0
SELECT Security.fn_UserHasPermission(7, 'Security.AssignRoles'); -- 1

EXEC Security.sp_AssignRoleToUser @UserID=1, @RoleID=5, @AdminUserID=7;