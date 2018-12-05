USE DBADemoDB
GO


--Using EXEC
DECLARE @sql nvarchar(MAX),
		@topCount int

SET @topCount = 5
SET @sql = 'SELECT TOP ' + CAST(@topCount as nvarchar(8)) + ' * FROM SALES ORDER BY SaleDate DESC'

EXEC(@sql)


--Using sp_ExecuteSQL
USE master;
GO

DECLARE UserDatabases CURSOR FOR
	SELECT name FROM sys.databases WHERE database_id > 4
OPEN UserDatabases

DECLARE @dbName nvarchar(128)
DECLARE @sql nvarchar(MAX)

FETCH NEXT FROM UserDatabases INTO @dbName
WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @sql = 'USE ' + @dbName + ';' + CHAR(13) + 'DBCC SHRINKDATABASE ('+ @dbName + ')'
		EXEC sp_ExecuteSQL @sql

		FETCH NEXT FROM UserDatabases INTO @dbName
	END
CLOSE UserDatabases
DEALLOCATE UserDatabases

