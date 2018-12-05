/*******************************************************************************************
** File:    usp-index-maintenance.sql
** Name:	Index Maintenance
** Desc:	Creates a stored procedure in master database to rebuild/reorganize indexes
** Auth:	NoobInAbox
** Date:	September 21 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	9/21/2016	NoobInAbox 		Created
*****************************************************************************************/

USE [master]
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'DBA')
BEGIN
	EXEC('CREATE SCHEMA [DBA]');
END

IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[usp_IndexMaintenance]') AND type IN (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [DBA].[usp_IndexMaintenance];
END
GO


CREATE PROCEDURE [DBA].[usp_IndexMaintenance]
	  @pDatabase		nvarchar(120) = NULL
	, @pLogToTable		tinyint = 1	
AS
BEGIN
	SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	DECLARE	      @objectid				int
				, @indexid				int
				, @partitioncount		bigint
				, @schemaname			nvarchar(130)
				, @objectname			nvarchar(130)
				, @index_type			nvarchar(130)
				, @indexname			nvarchar(130)
				, @page_count			int
				, @partitionnum			bigint
				, @partitions			bigint
				, @frag					float
				, @command				nvarchar(4000)
				, @lob_data				smallint
				, @actiontaken			nvarchar(10)
				, @startTime			datetime
				, @hostname				nvarchar(130)
				, @jobstarttime			datetime
				, @SQLString			nvarchar(4000)
				, @ParmDefinition		nvarchar(4000)
				, @Retval				int
				, @CRLF					char(2)
				, @DBName				varchar(130)
				, @RowCount				int
				, @RecordCount			int
				, @DatabaseName			varchar(130)
				, @ErrorSeverity		int
				, @ErrorState			int
				, @ErrorMessage			varchar(4000)
				, @RaiseErrorMessage	varchar(254);

	SET @hostname = @@SERVERNAME;
	SET @CRLF = CHAR(13) + CHAR(10);

	IF(@pDatabase IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @pDatabase))
	BEGIN
		RAISERROR('Database does not exist on server.', 16, 1);
		GOTO EOF;
	END

	IF(@pDatabase IS NULL)
	BEGIN

		IF OBJECT_ID('tempdb.dbo.#DatabaseIndexList') IS NOT NULL
		BEGIN
			DROP TABLE #DatabaseIndexList;
		END

		CREATE TABLE #DatabaseIndexList
		(
			ID int IDENTITY(1,1) NOT NULL,
			DatabaseName varchar(130)
		)

		INSERT INTO #DatabaseIndexList
			SELECT
				name
			FROM
				sys.databases
			WHERE database_id > 4 AND NAME NOT LIKE '%temp%' AND NAME NOT LIKE 'distribution' AND is_read_only != 1 AND state_desc = 'ONLINE';

		SET @RowCount = @@ROWCOUNT;
		SET @RecordCount = 1;


		IF @RowCount = 0
		BEGIN
			RAISERROR('No user databases to perform index maintenance on.', 16, 1);
			GOTO EOF;
		END


		WHILE @RecordCount <= @RowCount
		BEGIN
			SELECT @DatabaseName = DatabaseName FROM #DatabaseIndexList WHERE ID = @RecordCount;
			IF OBJECT_ID('tempdb.dbo.#work_to_do') IS NOT NULL
			BEGIN
				DROP TABLE #work_to_do;
			END

			SELECT
				  object_id AS objectid
				, index_id AS indexid
				, partition_number AS partitionnum
				, avg_fragmentation_in_percent AS frag
				, index_type_desc AS index_type
				, page_count AS page_count_kb
				, 0 AS lob_data
			INTO #work_to_do
			FROM
				sys.dm_db_index_physical_stats (DB_ID(@DatabaseName), NULL, NULL, NULL, 'LIMITED')
			WHERE
				avg_fragmentation_in_percent > 10.00 AND index_id > 0;

			SET @SQLString = 'UPDATE #work_to_do SET lob_data = 1 WHERE #work_to_do.objectid IN ';
			SET @SQLString = @SQLString + '(SELECT [' + @DatabaseName + '].[sys].[columns].[object_id] FROM ';
			SET @SQLString = @SQLString + '[' + @DatabaseName + '].[sys].[columns] WHERE max_length IN (-1,16));';

			EXEC sp_executesql @SQLString;

			SET @jobstarttime = GETDATE();

			DECLARE partitions CURSOR LOCAL FOR SELECT * FROM #work_to_do;
			BEGIN TRY
				OPEN partitions;
				WHILE (1=1)
				BEGIN
					FETCH NEXT FROM partitions INTO @objectid, @indexid, @partitionnum, @frag, @index_type, @page_count, @lob_data;
					IF @@FETCH_STATUS < 0 BREAK;

					SET @ParmDefinition = N'@objectname_out nvarchar(130) OUTPUT, @schemaname_out nvarchar(130) OUTPUT';
					SET @SQLString = 'SELECT @objectname_out = QUOTENAME(o.name)' + @CRLF;
					SET @SQLString = @SQLString + ' ,@schemaname_out = QUOTENAME(s.name)' + @CRLF;
					SET @SQLString = @SQLString + 'FROM [' + @DatabaseName + '].[sys].[objects] AS o' + @CRLF;
					SET @SQLString = @SQLString + 'JOIN [' + @DatabaseName + '].[sys].[schemas] AS s ON s.schema_id = o.schema_id' + @CRLF;
					SET @SQLString = @SQLString + 'WHERE o.object_id = ' + CAST(@objectid AS nvarchar(30));
					EXEC sp_executesql @SQLString, @ParmDefinition, @objectname_out=@objectname OUTPUT, @schemaname_out=@schemaname OUTPUT;

					SET @ParmDefinition = N'@indexname_out nvarchar(130) OUTPUT';
					SET @SQLString = 'SELECT @indexname_out = QUOTENAME(name)' + @CRLF;
					SET @SQLString = @SQLString + 'FROM [' + @DatabaseName + '].[sys].[indexes]' + @CRLF;
					SET @SQLString = @SQLString + 'WHERE object_id = ' + CAST(@objectid AS nvarchar(30)) + @CRLF;
					SET @SQLString = @SQLString + 'AND index_id = ' + CAST(@indexid AS nvarchar(30)) + ';';
					EXEC sp_executesql @SQLString, @ParmDefinition, @indexname_out=@indexname OUTPUT;

					SET @ParmDefinition = N'@partitioncount_out bigint OUTPUT';
					SET @SQLString = 'SELECT @partitioncount_out = count(*)' + @CRLF;
					SET @SQLString = @SQLString + 'FROM [' + @DatabaseName + '].[sys].[partitions]' + @CRLF;
					SET @SQLString = @SQLString + 'WHERE object_id = ' + CAST(@objectid AS nvarchar(30)) + ' AND index_id = ' + CAST(@indexid AS nvarchar(30)) + ';';
					EXEC sp_executesql @SQLString, @ParmDefinition, @partitioncount_out=@partitioncount OUTPUT;

					IF @frag < 30.00 AND @lob_data = 0
					BEGIN
						SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @DatabaseName + N'].' + @schemaname + N'.' + @objectname + N' REORGANIZE';
						SET @actiontaken = 'REORGANIZE';
					END

					IF @frag >= 30.0 and @lob_data = 1
					BEGIN
						SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @DatabaseName + N'].' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = ON, MAXDOP = 1)';
						SET @actiontaken = 'REBUILD'
					END

					IF @frag >= 30.0 and @lob_data = 0 and SERVERPROPERTY('EDITION') IN ('Developer Edition', 'Enterprise Edition', 'Enterprise Evaluation Edition')
					BEGIN
						SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @DatabaseName + N'].' + @schemaname + N'.' + @objectname + N' REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON, MAXDOP = 1)';  
						SET @actiontaken = 'REBUILD'
					END
					IF @frag >= 30.0 and @lob_data = 0 and SERVERPROPERTY('EDITION') NOT IN ('Developer Edition', 'Enterprise Edition', 'Enterprise Evaluation Edition')
					BEGIN
						SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @DatabaseName + N'].' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = ON, MAXDOP = 1)';  		
						SET @actiontaken = 'REBUILD'
					END

					IF @partitioncount > 1
						SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));

					SET @startTime = CURRENT_TIMESTAMP;
					EXEC sp_executesql @command;
					SET @indexname = REPLACE(@indexname, '[','');
					SET @indexname = REPLACE(@indexname, ']','');
					SET @schemaname = REPLACE(@schemaname, '[','');
					SET @schemaname =  REPLACE(@schemaname, ']','');
					SET @objectname = REPLACE(@objectname, '[','');
					SET @objectname = REPLACE(@objectname, ']','');
				END
				CLOSE partitions;
				DEALLOCATE partitions;

			END TRY
			BEGIN CATCH
				SELECT @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorMessage = ERROR_MESSAGE();

				RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
				GOTO EOL;
			END CATCH

			EOL:
			SET @RecordCount = @RecordCount + 1;
		END
	END

	IF(@pDatabase IS NOT NULL)
	BEGIN
	
		IF OBJECT_ID('tempdb.dbo.#work') IS NOT NULL
		BEGIN
			DROP TABLE #work;
		END

		SELECT
				object_id AS objectid
			, index_id AS indexid
			, partition_number AS partitionnum
			, avg_fragmentation_in_percent AS frag
			, index_type_desc AS index_type
			, page_count AS page_count_kb
			, 0 AS lob_data
		INTO #work
		FROM
			sys.dm_db_index_physical_stats (DB_ID(@pDatabase), NULL, NULL, NULL, 'LIMITED')
		WHERE
			avg_fragmentation_in_percent > 10.00 AND index_id > 0;

		SET @SQLString = 'UPDATE #work SET lob_data = 1 WHERE #work.objectid IN ';
		SET @SQLString = @SQLString + '(SELECT [' + @pDatabase + '].[sys].[columns].[object_id] FROM ';
		SET @SQLString = @SQLString + '[' + @pDatabase + '].[sys].[columns] WHERE max_length IN (-1,16));';

		EXEC sp_executesql @SQLString;

		SET @jobstarttime = GETDATE();

		DECLARE partitions CURSOR LOCAL FOR SELECT * FROM #work;
		BEGIN TRY
			OPEN partitions;
			WHILE (1=1)
			BEGIN
				FETCH NEXT FROM partitions INTO @objectid, @indexid, @partitionnum, @frag, @index_type, @page_count, @lob_data;
				IF @@FETCH_STATUS < 0 BREAK;

				SET @ParmDefinition = N'@objectname_out nvarchar(130) OUTPUT, @schemaname_out nvarchar(130) OUTPUT';
				SET @SQLString = 'SELECT @objectname_out = QUOTENAME(o.name)' + @CRLF;
				SET @SQLString = @SQLString + ' ,@schemaname_out = QUOTENAME(s.name)' + @CRLF;
				SET @SQLString = @SQLString + 'FROM [' + @pDatabase + '].[sys].[objects] AS o' + @CRLF;
				SET @SQLString = @SQLString + 'JOIN [' + @pDatabase + '].[sys].[schemas] AS s ON s.schema_id = o.schema_id' + @CRLF;
				SET @SQLString = @SQLString + 'WHERE o.object_id = ' + CAST(@objectid AS nvarchar(30));
				EXEC sp_executesql @SQLString, @ParmDefinition, @objectname_out=@objectname OUTPUT, @schemaname_out=@schemaname OUTPUT;

				SET @ParmDefinition = N'@indexname_out nvarchar(130) OUTPUT';
				SET @SQLString = 'SELECT @indexname_out = QUOTENAME(name)' + @CRLF;
				SET @SQLString = @SQLString + 'FROM [' + @pDatabase + '].[sys].[indexes]' + @CRLF;
				SET @SQLString = @SQLString + 'WHERE object_id = ' + CAST(@objectid AS nvarchar(30)) + @CRLF;
				SET @SQLString = @SQLString + 'AND index_id = ' + CAST(@indexid AS nvarchar(30)) + ';';
				EXEC sp_executesql @SQLString, @ParmDefinition, @indexname_out=@indexname OUTPUT;

				SET @ParmDefinition = N'@partitioncount_out bigint OUTPUT';
				SET @SQLString = 'SELECT @partitioncount_out = count(*)' + @CRLF;
				SET @SQLString = @SQLString + 'FROM [' + @pDatabase + '].[sys].[partitions]' + @CRLF;
				SET @SQLString = @SQLString + 'WHERE object_id = ' + CAST(@objectid AS nvarchar(30)) + ' AND index_id = ' + CAST(@indexid AS nvarchar(30)) + ';';
				EXEC sp_executesql @SQLString, @ParmDefinition, @partitioncount_out=@partitioncount OUTPUT;

				IF @frag < 30.00 AND @lob_data = 0
				BEGIN
					SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @pDatabase + N'].' + @schemaname + N'.' + @objectname + N' REORGANIZE';
					SET @actiontaken = 'REORGANIZE';
				END

				IF @frag >= 30.0 and @lob_data = 1
				BEGIN
					SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @pDatabase + N'].' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = ON, MAXDOP = 1)';
					SET @actiontaken = 'REBUILD'
				END

				IF @frag >= 30.0 and @lob_data = 0 and SERVERPROPERTY('EDITION') IN ('Developer Edition', 'Enterprise Edition', 'Enterprise Evaluation Edition')
				BEGIN
					SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @pDatabase + N'].' + @schemaname + N'.' + @objectname + N' REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON, MAXDOP = 1)';  
					SET @actiontaken = 'REBUILD'
				END
				IF @frag >= 30.0 and @lob_data = 0 and SERVERPROPERTY('EDITION') NOT IN ('Developer Edition', 'Enterprise Edition', 'Enterprise Evaluation Edition')
				BEGIN
					SET @command = N'ALTER INDEX ' + @indexname + N' ON [' + @pDatabase + N'].' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = ON, MAXDOP = 1)';  		
					SET @actiontaken = 'REBUILD'
				END

				IF @partitioncount > 1
					SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));

				SET @startTime = CURRENT_TIMESTAMP;
				EXEC sp_executesql @command;
				SET @indexname = REPLACE(@indexname, '[','');
				SET @indexname = REPLACE(@indexname, ']','');
				SET @schemaname = REPLACE(@schemaname, '[','');
				SET @schemaname =  REPLACE(@schemaname, ']','');
				SET @objectname = REPLACE(@objectname, '[','');
				SET @objectname = REPLACE(@objectname, ']','');

			END
			CLOSE partitions;
			DEALLOCATE partitions;
		END TRY
		BEGIN CATCH
			SELECT @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorMessage = ERROR_MESSAGE();
			RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		END CATCH
	END


	EOF:
END

