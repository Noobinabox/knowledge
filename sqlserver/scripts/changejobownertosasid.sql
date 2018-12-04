/*****************************************************************************************
** File:	changejobownertosasid.sql
** Name:	Change JobOwner to SA SID
** Desc:	Loops through all jobs on SQL Server and assign all job owners to the sa SID
**          instead of the specified user.
** Auth:	NoobInABox
** Date:	Mar 1, 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	3/1/2016	NoobInABox		Created
*****************************************************************************************/

IF OBJECT_ID('tempdb.dbo.#AgentJobOwners') IS NOT NULL
BEGIN
	DROP TABLE #AgentJobOwners;
END

CREATE TABLE #AgentJobOwners
(
	ID int IDENTITY(1,1) NOT NULL,
	job_id nvarchar(1000),
	name nvarchar(128),
	owner nvarchar(128)
);
DECLARE @JobName nvarchar(128);
DECLARE @JobID nvarchar(1000);
DECLARE @SQLCommand nvarchar(3000);
DECLARE @RowCount int;
DECLARE @RecordCount int;
DECLARE @SAAccount nvarchar(128);
DECLARE @OwnerToReplace nvarchar(128);

SET @OwnerToReplace = N''; -- Change this to the user you want to replace as the job owner to sa

SET @SAAccount = CONVERT(nvarchar(128), QUOTENAME(SUSER_SNAME(0x01)));

INSERT INTO #AgentJobOwners
	SELECT CONVERT(nvarchar(1000), job_id) AS 'job_id', name, SUSER_SNAME(owner_sid) AS 'owner' FROM msdb..sysjobs WHERE SUSER_SNAME(owner_sid) = @OwnerToReplace;

SET @RowCount = @@ROWCOUNT;
SET @RecordCount = 1;

IF @RowCount = 0
BEGIN
	PRINT 'There are no SQL Server Agent jobs currently listed under ' + @OwnerToReplace + '.';
	GOTO EOF;
END

WHILE @RecordCount <= @RowCount
BEGIN
	SELECT @JobID = job_id, @JobName = name FROM #AgentJobOwners WHERE ID = @RecordCount;
	SET @SQLCommand = 'EXEC msdb.dbo.sp_update_job @job_id = N''' + @JobID + ''', @owner_login_name = N''' + SUSER_SNAME(0x01) + ''';';
	BEGIN TRY
		BEGIN TRANSACTION ALTERAGENTJOBOWNERS
			EXEC sp_executesql @SQLCommand;
		COMMIT TRANSACTION ALTERAGENTJOBOWNERS
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION ALTERAGENTJOBOWNERS
		PRINT 'The following job ' + @JobName + ' wasn''t able to change the owner...';
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

SELECT job_id, name, SUSER_SNAME(owner_sid) as 'owner' FROM msdb..sysjobs;

EOF:

