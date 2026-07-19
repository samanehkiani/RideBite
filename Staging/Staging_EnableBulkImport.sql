USE RideBite;
GO

/*
    One-time server configuration for OPENROWSET / Excel access.
    Run as a sysadmin on the SQL Server instance.
*/

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

PRINT '=== Ad Hoc Distributed Queries enabled ===';
PRINT 'Ensure Microsoft Access Database Engine (ACE OLEDB 12.0) is installed for .xlsx files.';
GO
