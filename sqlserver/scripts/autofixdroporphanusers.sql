/**************************************************************************************************************
Script to identify all orphaned users in a database and fix the ones that match logins and drop the ones that
do not.  This will also now drop any certificates and keys to aid when moving a reporting database from one
server to aanother

N. Reichel - 08/05/2009 - First version of the script
N. Reichel - 05/11/2011 - Adding Certificate and Key drops to account for Reporting database moves

Adapted from the works at:
http://social.msdn.microsoft.com/Forums/en-US/sqlsecurity/thread/4a45a56c-31b4-4396-93fb-f46a881bdb7f

It is recommend that this be run against a non production database that is restorable first to verify that
the correct users are being dropped and preserved.  You must also have all your logins created prior to running
this script or the database user will be dropped and need to be recreated manually.
***************************************************************************************************************/

-- Generate list of orphaned users that match an existing login
PRINT 'Getting list of orphaned users that match an existing login'
SELECT
Row_Number() OVER(ORDER BY [m].[name]) AS [id], [m].[name]
INTO [#temptbl]
FROM [sysusers] [loc] Inner Join [sys].[server_principals] [m] ON [loc].[name] = [m].[name]
WHERE [loc].[sid] <> [m].[sid] And [type] IN ('S','U')

DECLARE @liI INT,
        @liMax INT,
        @lcUserName NVARCHAR(256)

SELECT @liI =Min([id]), @liMax = Max([id]) FROM [#temptbl]

-- Iterate through list of orphaned users and realign the user with the login
PRINT ' '
PRINT 'Fixing orphaned users that match an existing login'
WHILE @liI <= @liMax
BEGIN
    SELECT @lcUserName = [name] FROM [#temptbl] WHERE [id] = @liI
    PRINT 'FIXING USER ' + @lcUserName
    EXEC sp_change_users_login 'Auto_Fix', @lcUserName
    SET @liI = @liI + 1
END
DROP TABLE [#temptbl]
GO

PRINT ' '
PRINT 'Getting list of orphaned users that DO NOT match an existing login'
SELECT
Row_Number() OVER(ORDER BY [u].[name]) AS [id], [u].[name]
INTO [#temptbl]
FROM master..syslogins l right join sysusers u on l.sid = u.sid
WHERE l.sid is null and issqlrole <> 1 and isapprole <> 1
And (u.name <> 'INFORMATION_SCHEMA' and u.name <> 'guest'
And u.name <> 'system_function_schema'
And u.name <> 'dbo'
And u.name <> 'sys')

DECLARE @liI INT,
        @liMax INT,
        @lcUserName NVARCHAR(256)

SELECT @liI =Min([id]), @liMax = Max([id]) FROM [#temptbl]

-- Iterate through list of orphaned users and realign the user with the login
PRINT 'Dropping orphaned users that dont match an existing login'
WHILE @liI <= @liMax
BEGIN
    SELECT @lcUserName = [name] FROM [#temptbl] WHERE [id] = @liI
    PRINT 'DROPPING UNFOUND USER ' + @lcUserName
    EXEC sp_dropuser @lcUserName
    SET @liI = @liI + 1
END
DROP TABLE [#temptbl]
GO


