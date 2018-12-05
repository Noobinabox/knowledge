/*******************************************************************************************
** File:	usp-statistics-maintenance.sql
** Name:	Statistics Maintenance
** Desc:	This SP checks the stats of a database for anything that hasn't been updated
**			in 3 days and updates it.
** Auth:	NoobInABox
** Date:	11/3/2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	11/3/16		NoobInABox		Created
*****************************************************************************************/

USE [master]
GO

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'DBA')
BEGIN
	EXEC('CREATE SCHEMA [DBA]');
END
GO


SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS( SELECT
				*
			FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[DBA].[usp_UpdateStatistics]')
				  AND type IN ( N'P',N'PC'))
BEGIN
	DROP PROCEDURE [DBA].[usp_UpdateStatistics];
END
GO


CREATE PROCEDURE [DBA].[usp_UpdateStatistics]
	 @pDatabase		nvarchar(120) = NULL
	,@pLogToTable	tinyint = 1
AS
BEGIN

	SET QUOTED_IDENTIFIER ON;
	SET NOCOUNT ON;
	
    /* Check to see if @pDatabase is valid otherwise exit the maintenance script */
    IF(@pDatabase IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @pDatabase))
    BEGIN
        RAISERROR('Database does not exist on the server.', 16, 1);
        GOTO EOF;
    END

	DECLARE	@hostname				nvarchar(130)
		   ,@starttime				datetime
		   ,@jobstarttime			datetime
		   ,@LinkSvr				nvarchar(130)
		   ,@schema					sysname
		   ,@tablename				sysname
		   ,@statistics				sysname
		   ,@SQLString				nvarchar(1024)
		   ,@SSS					nvarchar(4000)
		   ,@CRLF					char(2)
		   ,@dbname					nvarchar(120)
           ,@DatabaseName           varchar(130)
           ,@RowCount               int
           ,@RecordCount            int
           ,@ErrorSeverity          int
           ,@ErrorState             int
           ,@ErrorMessage           varchar(4000)
		   ,@dbstatid				int;
	
	SET @hostname		= @@SERVERNAME;
	SET @CRLF = CHAR(13) + CHAR(10);
	
    /* If @pDatabase is null we need to loop through all the users databases */
    IF(@pDatabase IS NULL)
    BEGIN
        IF OBJECT_ID('tempdb.dbo.#DatabaseStatisticsList') IS NOT NULL
        BEGIN
            DROP TABLE #DatabaseStatisticsList;
        END

        CREATE TABLE #DatabaseStatisticsList
        (
            ID int IDENTITY(1, 1) NOT NULL,
            DatabaseName varchar(130)
        )

        INSERT INTO #DatabaseStatisticsList
            SELECT
                name
            FROM
                sys.databases
            WHERE
                database_id > 4 AND name NOT LIKE '%temp%' AND name NOT LIKE 'distribution' AND state_desc = 'ONLINE' and is_read_only != 1;

        SET @RowCount = @@ROWCOUNT;
        SET @RecordCount = 1;

        IF @RowCount = 0
        BEGIN
            RAISERROR('No user databases to perform statistic maintenance on.', 16, 1);
            GOTO EOF;
        END

        WHILE @RecordCount <= @RowCount
        BEGIN
            SELECT @DatabaseName = DatabaseName FROM #DatabaseStatisticsList WHERE ID = @RecordCount;

            IF OBJECT_ID('tempdb.dbo.##StatsThatNeedUpdating') IS NOT NULL
            BEGIN
                DROP TABLE ##StatsThatNeedUpdating;
            END

            CREATE TABLE ##StatsThatNeedUpdating
            (
                StatsID int NOT NULL IDENTITY(1,1),
                DatabaseName nvarchar(130),
                ObjectSchema varchar(1024),
                ObjectName sysname,
                StatisticName sysname,
                StatisticUpdateDate DATETIME,
                StatUpdate bit
            )

            SET @SSS = 'USE [' + @DatabaseName + '];' + @CRLF;
            SET @SSS = @SSS + 'INSERT INTO ##StatsThatNeedUpdating' + @CRLF;
            SET @SSS = @SSS + '	SELECT	''' + @DatabaseName + '''' + @CRLF; 
            SET @SSS = @SSS + '		,OBJECT_SCHEMA_NAME(OBJECT_ID)' + @CRLF;
            SET @SSS = @SSS + '		,OBJECT_NAME(object_id)' + @CRLF;
            SET @SSS = @SSS + '		,[name]' + @CRLF;
            SET @SSS = @SSS + '		,STATS_DATE([object_id], [stats_id])' + @CRLF;
            SET @SSS = @SSS + '		,0' + @CRLF;
            SET @SSS = @SSS + '	FROM [' + @DatabaseName + '].[sys].[stats]' + @CRLF;
            SET @SSS = @SSS + '	WHERE STATS_DATE([object_id], [stats_id]) IS NOT NULL' + @CRLF;
            SET @SSS = @SSS + '		AND STATS_DATE([object_id], [stats_id]) < DATEADD(DAY, -3, GETDATE())' + @CRLF;
            SET @SSS = @SSS + '		AND OBJECT_NAME(object_id) NOT LIKE ''sys%''';

            EXEC sp_executesql @SSS;
            SET @jobstarttime = CURRENT_TIMESTAMP;

            DECLARE statCursor CURSOR LOCAL STATIC FORWARD_ONLY FOR
                SELECT StatsID, DatabaseName, ObjectSchema, ObjectName, StatisticName
                FROM ##StatsThatNeedUpdating
                WHERE DatabaseName = @DatabaseName AND StatUpdate = 0;
            BEGIN TRY
                OPEN statCursor
                WHILE(1=1)
                BEGIN
                    FETCH NEXT FROM statCursor INTO @dbstatid, @dbname, @schema, @tablename, @statistics;
                    
                    IF @@FETCH_STATUS < 0 BREAK;

                    SET @SQLString = 'UPDATE STATISTICS [' + @dbname + '].[' + @schema + '].[' + @tablename + ']([' + @statistics + '])';
                    SET @starttime = CURRENT_TIMESTAMP;
                    EXEC sp_executesql @SQLString;
                    UPDATE ##StatsThatNeedUpdating SET StatUpdate = 1 WHERE StatsID = @dbstatid;
                END
                CLOSE statCursor;
                DEALLOCATE statCursor;

                IF NOT EXISTS(SELECT 1 FROM ##StatsThatNeedUpdating WHERE StatUpdate = 0 AND DatabaseName = @DatabaseName)
                BEGIN
                    DELETE FROM ##StatsThatNeedUpdating WHERE DatabaseName = @DatabaseName;
                END
            END TRY
            BEGIN CATCH
                DELETE FROM ##StatsThatNeedUpdating WHERE StatUpdate = 0 AND DatabaseName = @DatabaseName;

                SELECT
                    @ErrorSeverity = ERROR_SEVERITY(),
                    @ErrorState = ERROR_STATE(),
                    @ErrorMessage = ERROR_MESSAGE();

                RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
                GOTO EOL;
            END CATCH

            EOL:
            SET @RecordCount = @RecordCount + 1;
        END

    END
	

    IF(@pDatabase IS NOT NULL)
    BEGIN
        IF OBJECT_ID('tempdb.dbo.StatsThatNeedUpdating') IS NULL
        BEGIN
            CREATE TABLE tempdb.dbo.StatsThatNeedUpdating (
                StatsID int NOT NULL IDENTITY(1,1),
                DatabaseName nvarchar(120),
                ObjectSchema varchar(1024),
                ObjectName sysname,
                StatisticName sysname,
                StatisticsUpdateDate DATETIME,
                StatUpdate bit,
                CONSTRAINT PK_StatsID_StatsThatNeedUpdating PRIMARY KEY CLUSTERED(StatsID ASC)
            )
            CREATE NONCLUSTERED INDEX IX_StatsThatNeedUpdating_ObjectName ON tempdb.dbo.StatsThatNeedUpdating (ObjectName);
            CREATE NONCLUSTERED INDEX IX_StatsThatNeedUpdating_StatisticName ON tempdb.dbo.StatsThatNeedUpdating (StatisticName);
        END
        
        SET @SSS = 'USE [' + @pDatabase + '];' + @CRLF;
        SET @SSS = @SSS + 'INSERT INTO tempdb.dbo.StatsThatNeedUpdating' + @CRLF;
        SET @SSS = @SSS + '	SELECT	''' + @pDatabase + '''' + @CRLF; 
        SET @SSS = @SSS + '		,OBJECT_SCHEMA_NAME(OBJECT_ID)' + @CRLF;
        SET @SSS = @SSS + '		,OBJECT_NAME(object_id)' + @CRLF;
        SET @SSS = @SSS + '		,[name]' + @CRLF;
        SET @SSS = @SSS + '		,STATS_DATE([object_id], [stats_id])' + @CRLF;
        SET @SSS = @SSS + '		,0' + @CRLF;
        SET @SSS = @SSS + '	FROM [' + @pDatabase + '].[sys].[stats]' + @CRLF;
        SET @SSS = @SSS + '	WHERE STATS_DATE([object_id], [stats_id]) IS NOT NULL' + @CRLF;
        SET @SSS = @SSS + '		AND STATS_DATE([object_id], [stats_id]) < DATEADD(DAY, -3, GETDATE())' + @CRLF;
        SET @SSS = @SSS + '		AND OBJECT_NAME(object_id) NOT LIKE ''sys%''';
        
        EXEC sp_executesql @SSS;
        SET @jobstarttime = CURRENT_TIMESTAMP;

        DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT StatsID, DatabaseName, ObjectSchema, ObjectName, StatisticName 
            FROM tempdb.dbo.StatsThatNeedUpdating 
            WHERE DatabaseName = @pDatabase AND StatUpdate = 0;
        BEGIN TRY
            OPEN cur;
            WHILE (1=1)
                BEGIN;
                    FETCH NEXT FROM cur INTO @dbstatid, @dbname, @schema, @tablename, @statistics;
                    IF @@FETCH_STATUS < 0 BREAK;
                    SET @SQLString = 'UPDATE STATISTICS [' + @dbname + '].[' + @schema + '].[' + @tablename + ']([' + @statistics + '])';
                    SET @starttime = CURRENT_TIMESTAMP;
                    EXEC sp_executesql @SQLString;
                    UPDATE tempdb.dbo.StatsThatNeedUpdating SET StatUpdate = 1 WHERE StatsID = @dbstatid;
                    IF (@Retval = 0 AND @pLogToTable = 1)
                        BEGIN
                            INSERT INTO [ENP-MPSQL].[sfmcsysadmin].[dbo].[StatisticsMaintenance]
                                (HostName, DatabaseName, TableName, Command, StartTime)
                            VALUES
                                (@hostname, @pDatabase, @schema + '.' + @tablename, @SQLString, @starttime);
                        END
                END;
            CLOSE cur;
            DEALLOCATE cur;

            IF NOT EXISTS(SELECT 1 FROM tempdb.dbo.StatsThatNeedUpdating WHERE StatUpdate = 0 AND DatabaseName = @pDatabase)
            BEGIN
                DELETE FROM tempdb.dbo.StatsThatNeedUpdating WHERE DatabaseName = @pDatabase;
            END
        END TRY
        BEGIN CATCH

            DELETE FROM tempdb.dbo.StatsThatNeedUpdating WHERE DatabaseName = @pDatabase;

            SELECT
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE(),
                @ErrorMessage = ERROR_MESSAGE()

            RAISERROR(@ErrorMessage, @ErrorSeverity,@ErrorState);
        END CATCH
    END
    EOF:
END

