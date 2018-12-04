/*****************************************************************************************************
** File: changeownertosasid.sql
** Name: Change Database Owner to sa SID
** Desc: Loops through all databases filtering on a username, which then switches them to the sa sid.
** Auth: Noobinabox
** Date: Mar 1, 2016
**********************************************************************
** Change History
**********************************************************************
** PR 	Date 		Author 			Description
** -- 	----------- --------------- -----------------------------------------------------------------
** 1 	3/1/2016 	Noobinabox 		Created
******************************************************************************************************/

/*
<summary>
This script is very simple and the only modification that needs to happen is remove the owners to
search by for the one you wish to replace. If you have renamed your sa account for security reasons
the scripts still works because it uses the sid instead of the username.
</summary>
*/

IF OBJECT_ID('tempdb.dbo.#DatabaseOwners') IS NOT NULL
BEGIN
	DROP TABLE #DatabaseOwners;
END
GO

CREATE TABLE #DatabaseOwners
(
	ID int IDENTITY(1,1) NOT NULL,
	name varchar(128),
	owner varchar(128)
);

DECLARE @DatabaseName nvarchar(128);
DECLARE @SQLCommand nvarchar(2000);
DECLARE @RowCount int;
DECLARE @RecordCount int;
DECLARE @OwnerSearch sysname;

SET @OwnerSearch = N'NoobInAbox'; -- Replace this value with the username you wish to replace.

INSERT INTO #DatabaseOwners
	SELECT name, SUSER_SNAME(owner_sid) AS 'owner' FROM sys.databases WHERE SUSER_SNAME(owner_sid) = @OwnerSearch;

SET @RowCount = @@ROWCOUNT;
SET @RecordCount = 1;

IF @RowCount = 0
BEGIN
	PRINT 'There are no databases currently listed under ' + @OwnerSearch + '.';
	GOTO EOF;
END

WHILE @RecordCount <= @RowCount
BEGIN
	SELECT @DatabaseName = name FROM #DatabaseOwners WHERE ID = @RecordCount;
	BEGIN TRY
		SET @SQLCommand = 'ALTER AUTHORIZATION ON DATABASE::' + @DatabaseName + ' TO [' + SUSER_SNAME(0x01) + '];';
		BEGIN TRANSACTION DATABASEOWNERCHANGE
			EXEC sp_executesql @SQLCommand;
		COMMIT TRANSACTION DATABASEOWNERCHANGE
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION DATABASEOWNERCHANGE
		PRINT 'The following database ' + @DatabaseName + ' wasn''t able to change the owner...';
		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage
	END CATCH
	SET @RecordCount = @RecordCount + 1;
END

SELECT name, SUSER_SNAME(owner_sid) FROM sys.databases WHERE database_id > 4;

EOF:

