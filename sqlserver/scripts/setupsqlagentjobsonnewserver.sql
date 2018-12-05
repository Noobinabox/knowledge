/*******************************************************************************************
** File:	setupsqlagentjobsonnewserver.sql
** Name:	Creates SQL Server Agent Maintenance Jobs
** Desc:	This will setup SQL Server Agent jobs for backups, index, and statistics maintenance.
** Auth:	NoobInABox
** Date:	Nov 3, 2017
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	11/3/17		NoobInABox		Created
*****************************************************************************************/

USE [msdb];
GO

/********************************************************************
** Creates a job for each database for backing up
**
** NOTE: Please change the directory per server
********************************************************************/
DECLARE @SQLCommand		nvarchar(4000)
	   ,@CRLF			char(2)
	   ,@Database		nvarchar(128)
	   ,@FilePath		nvarchar(400);

SET @CRLF = CHAR(13)+CHAR(10);
SET @FilePath = N'G:\MSSQL User Database Backups';

SET @SQLCommand = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''distribution'', ''ReportServerTempDB'')' + @CRLF;
SET @SQLCommand = @SQLCommand + 'BEGIN' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_job @job_name=N''User Database Backup - ? (Full)'', @category_name=''Database Maintenance'';' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobstep @job_name=N''User Database Backup - ? (Full)'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@step_name = N''Backup DB ? (Full)'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@subsystem = N''TSQL'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@database_name = N''master'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@command = N''EXEC DBA.usp_DatabaseBackup @pDatabase=''''?'''', @pDirectory=''''' + @FilePath + ''''', @pBackupType=''''full''''''' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobserver @job_name = N''User Database Backup - ? (Full)'', @server_name = '''+ @@SERVERNAME + '''' + @CRLF;
SET @SQLCommand = @SQLCommand + 'END';

BEGIN TRY
	EXEC sp_MSforeachdb @SQLCommand
END TRY
BEGIN CATCH
	SELECT 'Error while creating backup jobs' AS 'Error Instance', ERROR_MESSAGE() AS 'Error Message';
END CATCH
/********************************************************************
** Creates a job for each database to rebuild or reorg indexes
**
** NOTE: Nothing needs to be changed.
********************************************************************/

SET @SQLCommand = NULL; --Clearing out anything in SQLCommand

SET @SQLCommand = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''distribution'', ''ReportServerTempDB'')' + @CRLF;
SET @SQLCommand = @SQLCommand + 'BEGIN' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_job @job_name=N''Index Maintenance - ?'', @category_name=''Database Maintenance'';' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobstep @job_name=N''Index Maintenance - ?'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@step_name = N''Check Indexes for Fragmentation'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@subsystem = N''TSQL'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@database_name = N''master'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@command = N''EXEC DBA.usp_IndexMaintenance ''''?''''''' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobserver @job_name = N''Index Maintenance - ?'', @server_name = '''+ @@SERVERNAME + '''' + @CRLF;
SET @SQLCommand = @SQLCommand + 'END';

BEGIN TRY
	EXEC sp_MSforeachdb @SQLCommand;
END TRY
BEGIN CATCH
	SELECT 'Error while creating index jobs' AS 'Error Instance', ERROR_MESSAGE() AS 'Error Message';
END CATCH

/********************************************************************
** Creates a job for each database to update statistics if
** they haven't been updated in three days
** 
** NOTE: Nothing needs to be changed.
********************************************************************/

SET @SQLCommand = NULL; --Clearing out anything in SQLCommand

SET @SQLCommand = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''distribution'', ''ReportServerTempDB'')' + @CRLF;
SET @SQLCommand = @SQLCommand + 'BEGIN' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_job @job_name=N''Update Statistics - ?'', @category_name=''Database Maintenance'';' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobstep @job_name=N''Update Statistics - ?'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@step_name = N''Update Outdated Statistics'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@subsystem = N''TSQL'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@database_name = N''master'',' + @CRLF;
SET @SQLCommand = @SQLCommand + '		@command = N''EXEC DBA.usp_UpdateStatistics ''''?''''''' + @CRLF;
SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobserver @job_name = N''Update Statistics - ?'', @server_name = '''+ @@SERVERNAME + '''' + @CRLF;
SET @SQLCommand = @SQLCommand + 'END';


BEGIN TRY
	EXEC sp_MSforeachdb @SQLCommand;
END TRY
BEGIN CATCH
	SELECT 'Error while creating statistics jobs' AS 'Error Instance', ERROR_MESSAGE() AS 'Error Message';
END CATCH


/********************************************************************
** Creates a transaction log backup job for each database 
** that's set to full recovery
** 
** NOTE: If you want TLOG backups to go to a different directory you need
** 		 need to change @FilePath
********************************************************************/

--SET @FilePath = N'G:\MSSQL User Log Backups';
SET @SQLCommand = NULL;

DECLARE db_cursor CURSOR LOCAL FOR
	SELECT name	FROM sys.databases WHERE database_id > 4 AND recovery_model_desc = 'full'
BEGIN TRY
	OPEN db_cursor
	WHILE (1=1)
	BEGIN
		FETCH NEXT FROM db_cursor INTO @Database;
		IF @@FETCH_STATUS < 0 BREAK;
		SET @SQLCommand = 'EXEC dbo.sp_add_job @job_name=N''User Database Backup - ' + @Database + ' (TLOG)'', @category_name=''Database Maintenance'';' + @CRLF;
		SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobstep @job_name=N''User Database Backup - ' + @Database + ' (TLOG)'',' + @CRLF;
		SET @SQLCommand = @SQLCommand + '		@step_name = N''Backup DB ' + @Database + ' (TLOG)'',' + @CRLF;
		SET @SQLCommand = @SQLCommand + '		@subsystem = N''TSQL'',' + @CRLF;
		SET @SQLCommand = @SQLCommand + '		@database_name = N''master'',' + @CRLF;
		SET @SQLCommand = @SQLCommand + '		@command = N''EXEC DBA.usp_DatabaseBackup @pDatabase=''''' + @Database + ''''', @pDirectory=''''' + @FilePath + ''''', @pBackupType=''''tlog''''''' + @CRLF;
		SET @SQLCommand = @SQLCommand + '	EXEC dbo.sp_add_jobserver @job_name = N''User Database Backup - ' + @Database + ' (TLOG)'', @server_name = '''+ @@SERVERNAME + '''' + @CRLF;
		EXEC sp_executesql @SQLCommand;
	END
	CLOSE db_cursor;
	DEALLOCATE db_cursor;
END TRY
BEGIN CATCH
	SELECT 'Error while creating TLOG backup jobs' AS 'Error Instance', ERROR_MESSAGE() AS 'Error Message';
END CATCH

