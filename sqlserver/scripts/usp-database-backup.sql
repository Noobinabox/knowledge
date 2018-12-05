/*******************************************************************************************
** File:    usp-database-backup.sql
** Name:	Stored Procedure Database Backup
** Desc:	Creates a stored procedure in master database for backing up
			databases.
** Auth:	NoobInABox
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

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'DBA')
BEGIN
	EXEC('CREATE SCHEMA [DBA]');
END
GO


SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS( SELECT 1	FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[usp_DatabaseBackup]') AND type IN ( N'P',N'PC'))
BEGIN
	DROP PROCEDURE [DBA].[usp_DatabaseBackup];
END
GO


CREATE PROCEDURE [DBA].[usp_DatabaseBackup]
	 @pDatabase		nvarchar(120) = NULL
	,@pDirectory	nvarchar(2000)
	,@pBackupType	nvarchar(5)
	,@pCompress		tinyint = 1
	,@pExpireDate	datetime = NULL
	,@pEncrypt		tinyint = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	
	DECLARE  @FormatedTime			nvarchar(30)
		   , @LinkSvr				nvarchar(130)
		   , @BackupSize			decimal(9,2)
		   , @CBackupSize			decimal(9,2)
		   , @Results				varchar(4000)
		   , @HostName				varchar(130)
		   , @BackupFileName		varchar(1000)
		   , @FolderLocation		varchar(3000)
		   , @JobStartTime			datetime
		   , @BackupName			varchar(200)
		   , @MSSQLVersion			decimal(5,2)
		   , @SQLCommand			nvarchar(4000)
		   , @CRLF					char(2)
		   , @JobDesc				nvarchar(100)
		   , @ParmDefinition		nvarchar(1000)
		   , @SQLString				nvarchar(4000)
		   , @DatabaseName			varchar(130)
		   , @BackupType			nvarchar(30)
           , @RowCount              int
           , @RecordCount           int
		   , @RaiseErrorMessage		varchar(254)
		   , @CertificateName		nvarchar(130)
		   , @ErrorSeverity			int
		   , @ErrorState			int;


	/******************************************************************************************************
	** First we should check if the database exists before doing anymore computing
	*******************************************************************************************************/
	IF @pDatabase IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @pDatabase)
	BEGIN
		RAISERROR('Database does not exist.', 16, 1);
		GOTO EOF;
	END

	SET @HostName = @@SERVERNAME;
	SET @JobStartTime = CURRENT_TIMESTAMP;
	SET @FormatedTime = CONVERT(nvarchar, CURRENT_TIMESTAMP, 126);
	SET @FormatedTime = REPLACE(@FormatedTime, ':', '.');
	SET @MSSQLVersion = LEFT(CONVERT(varchar, SERVERPROPERTY('ProductVersion')), 4);
	SET @CRLF = CHAR(13) + CHAR(10);

	/******************************************************************************************************
	** If the database parameter isn't null set the folder directory
	*******************************************************************************************************/
	IF @pDatabase IS NOT NULL
	BEGIN
		SET @FolderLocation = @pDirectory + '\' + @pDatabase + '\';
	END

	/******************************************************************************************************
	** Check to see if @pBackupType is a supported type.
	*******************************************************************************************************/
	IF (UPPER(@pBackupType) NOT IN ('COPY', 'FULL', 'DIFF','TLOG'))
	BEGIN
		SET @RaiseErrorMessage = 'Backup type (' + @pBackupType + ') is not supported.';
		RAISERROR(@RaiseErrorMessage, 16, 1);
		GOTO EOF;
	END

	/******************************************************************************************************
	** If @pDatabase is null then we assume you want all user databases backed up
	*******************************************************************************************************/
    IF(@pDatabase IS NULL)
    BEGIN
        IF OBJECT_ID('tempdb.dbo.#DatabaseList') IS NOT NULL
        BEGIN
            DROP TABLE #DatabaseList;
        END
        
        CREATE TABLE #DatabaseList
        (
            ID int IDENTITY(1,1) NOT NULL,
            DatabaseName varchar(130)
        )
	
			INSERT INTO #DatabaseList
				SELECT name FROM sys.databases where database_id > 4 AND name NOT LIKE '%temp%' AND state_desc = 'ONLINE'

		SET @RowCount = @@ROWCOUNT;
		SET @RecordCount = 1;

		/******************************************************************************************************
		** When @RowCount is 0 then no user databases were found
		*******************************************************************************************************/
		IF @RowCount = 0
		BEGIN
			RAISERROR('No users databases to backup.', 16, 1);
			GOTO EOF;
		END


		/******************************************************************************************************
		** Loop through the database names in the temp table
		*******************************************************************************************************/
		WHILE @RecordCount <= @RowCount
		BEGIN
			SELECT @DatabaseName = DatabaseName FROM #DatabaseList WHERE ID = @RecordCount;
			SET @FolderLocation = @pDirectory + '\' + @DatabaseName + '\';

			/******************************************************************************************************
			** For COPY_ONLY database backups
			*******************************************************************************************************/
			IF(UPPER(@pBackupType) = 'COPY')
			BEGIN
				SET @BackupFileName = @FolderLocation + @DatabaseName + '_' + @FormatedTime + '.cpy';
				SET @BackupName = @pDatabase + ' -Full Database Backup(Copy) ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
				SET @SQLCommand = 'BACKUP DATABASE [' + @DatabaseName + ']' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   TO DISK = ''' + @BackupFileName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
				SET @SQLCommand = @SQLCommand + '  COPY_ONLY' + @CRLF;
				SET @JobDesc = 'Full Database Backup(';
			END

			/******************************************************************************************************
			** For FULL database backups
			*******************************************************************************************************/
			IF(UPPER(@pBackupType) = 'FULL')
			BEGIN
				SET @BackupFileName = @FolderLocation + @DatabaseName + '_' + @FormatedTime + '.bak';
				SET @BackupName = @DatabaseName + '-Full Database Backup ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
				SET @SQLCommand = 'BACKUP DATABASE [' + @DatabaseName + ']' + @CRLF;
				SET @SQLCommand = @SQLCommand + '    TO DISK = ''' + @BackupFileName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
				SET @SQLCommand = @SQLCommand + '    NOFORMAT' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NOINIT' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NAME = N''' + @BackupName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,SKIP' + @CRLF;
				SET @JobDesc = 'Full Database Backup(';
			END

			/******************************************************************************************************
			** For TRANSACTION LOG database backups
			*******************************************************************************************************/
			IF(UPPER(@pBackupType) = 'TLOG')
			BEGIN
				/******************************************************************************************************
				** When tlog is passed we need to check if the current database in the loop is set to
				** full recovery model.
				*******************************************************************************************************/
				IF EXISTS(SELECT 1 FROM sys.databases WHERE recovery_model_desc = 'FULL' AND name = @DatabaseName)
				BEGIN
					SET @BackupFileName = @FolderLocation + @DatabaseName + '_' + @FormatedTime + '.trn';
					SET @BackupName = @DatabaseName + '-Transaction Log Backup ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
					SET @SQLCommand = 'BACKUP LOG [' + @DatabaseName + ']' + @CRLF;
					SET @SQLCommand = @SQLCommand + '    TO DISK = ''' + @BackupFileName + '''' + @CRLF;
					SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
					SET @SQLCommand = @SQLCommand + '    NOFORMAT' + @CRLF;
					SET @SQLCommand = @SQLCommand + '   ,NOINIT' + @CRLF;
					SET @SQLCommand = @SQLCommand + '   ,NAME = N''' + @BackupName + '''' + @CRLF;
					SET @SQLCommand = @SQLCommand + '   ,SKIP' + @CRLF;
					SET @JobDesc = 'Transaction Log Backup(';
				END
				ELSE
				BEGIN
					GOTO EOL;
				END
			END

			/******************************************************************************************************
			** For DIFF database backups
			*******************************************************************************************************/
			IF(UPPER(@pBackupType) = 'DIFF')
			BEGIN
				SET @BackupFileName = @FolderLocation + @DatabaseName + '_' + @FormatedTime + '.diff';
				SET @BackupName = @DatabaseName + '-Differential Database Backup ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
				SET @SQLCommand = 'BACKUP DATABASE [' + @DatabaseName + ']' + @CRLF;
				SET @SQLCommand = @SQLCommand + '    TO DISK = ''' + @BackupFileName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
				SET @SQLCommand = @SQLCommand + '    DIFFERENTIAL' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NOFORMAT' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NOINIT' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NAME = N''' + @BackupName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,SKIP' + @CRLF;
				SET @JobDesc = 'Differential Database Backup(';
			END

			/******************************************************************************************************
			** Check to see if the expiration date is set and append it to the @SQLCommand
			*******************************************************************************************************/
			IF(@pExpireDate IS NOT NULL)
			BEGIN
				SET @SQLCommand = @SQLCommand + '	,EXPIREDATE = ''' + @pExpireDate + '''' + @CRLF;
			END

			/******************************************************************************************************
			** Check to see if compression is enabled and append it to @SQLCommand
			*******************************************************************************************************/
			IF(@MSSQLVersion >= 10.50 AND @pCompress = 1)
			BEGIN
				SET @SQLCommand = @SQLCommand + '	,COMPRESSION' + @CRLF;
				IF(UPPER(@pBackupType) = 'COPY')
					SET @JobDesc = @JobDesc + 'Compressed, Copy-Only)';
				ELSE
					SET @JobDesc = @JobDesc + 'Compressed)';			
			END
			ELSE
			BEGIN
				IF(UPPER(@pBackupType) = 'COPY')
					SET @JobDesc = @JobDesc + 'Non-Compressed, Copy-Only)';
				ELSE
					SET @JobDesc = @JobDesc + 'Non-Compressed)';
			END

			/******************************************************************************************************
			** Here we are checking to see if the server supports encryption and if encryption is
			** passed as a parameter.
			*******************************************************************************************************/
			IF(@MSSQLVersion >= 10.50 AND @pEncrypt = 1)
			BEGIN
				/******************************************************************************************************
				** Because sys.certificates wasn't implemented till SQL Server 2008R2 we need to run 
				** this as sp_executesql to keep the script from erroring out.
				*******************************************************************************************************/
				SET @ParmDefinition = N'@CertificateName_out nvarchar(130) OUTPUT';
				SET @SQLString = 'SELECT TOP 1 @CertificateName_out = name FROM sys.certificates WHERE pvt_key_encryption_type_desc = ''ENCRYPTED_BY_MASTER_KEY''';
				EXEC sp_executesql @SQLString, @ParmDefinition, @CertificateName_out=@CertificateName OUTPUT

				IF @CertificateName <> ''
				BEGIN
					SET @SQLCommand = @SQLCommand + '	,ENCRYPTION( ALGORITHM = AES_256, SERVER CERTIFICATE = ' + @CertificateName + ')' + @CRLF;
				END
			END
			
			/******************************************************************************************************
			** Let's do some work!
			*******************************************************************************************************/
			BEGIN TRY
				SET @JobStartTime = CURRENT_TIMESTAMP;
				EXEC master.sys.xp_create_subdir @FolderLocation;

				EXEC sp_executesql @SQLCommand;

			END TRY
			BEGIN CATCH
				SELECT
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

				RAISERROR(@Results, @ErrorSeverity, @ErrorState);
			END CATCH


			EOL:
			SET @RecordCount = @RecordCount + 1;

		END
	END
	/******************************************************************************************************
	** Here we are setting up the backup command if a database is passed in the parameter
	** @pDatabase
	*******************************************************************************************************/
    IF(@pDatabase IS NOT NULL)
	BEGIN

		/******************************************************************************************************
		** Check to see if the database exists, if not goto EOF
		*******************************************************************************************************/
		IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = @pDatabase)
		BEGIN
			SET @RaiseErrorMessage = 'Database (' + @pDatabase + ') does not exist';
			RAISERROR(@RaiseErrorMessage, 16, 1);
			GOTO EOF;
		END

		/******************************************************************************************************
		** For COPY_ONLY database backups
		*******************************************************************************************************/
		IF(UPPER(@pBackupType) = 'COPY')
		BEGIN
			SET @BackupFileName = @FolderLocation + @pDatabase + '_' + @FormatedTime + '.cpy';
			SET @BackupName = @pDatabase + ' -Full Database Backup(Copy) ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
			SET @SQLCommand = 'BACKUP DATABASE [' + @pDatabase + ']' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   TO DISK = ''' + @BackupFileName + '''' + @CRLF;
			SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
			SET @SQLCommand = @SQLCommand + '  COPY_ONLY' + @CRLF;
			IF(@pExpireDate IS NOT NULL)
			SET @JobDesc = 'Full Database Backup(';
		END

		/******************************************************************************************************
		** For FULL database backups
		*******************************************************************************************************/
		IF(UPPER(@pBackupType) = 'FULL')
		BEGIN
			SET @BackupFileName = @FolderLocation + @pDatabase + '_' + @FormatedTime + '.bak';
			SET @BackupName = @pDatabase + '-Full Database Backup ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
			SET @SQLCommand = 'BACKUP DATABASE [' + @pDatabase + ']' + @CRLF;
			SET @SQLCommand = @SQLCommand + '    TO DISK = ''' + @BackupFileName + '''' + @CRLF;
			SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
			SET @SQLCommand = @SQLCommand + '    NOFORMAT' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,NOINIT' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,NAME = N''' + @BackupName + '''' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,SKIP' + @CRLF;
			SET @JobDesc = 'Full Database Backup(';
		END

		/******************************************************************************************************
		** For TRANSACTION_LOG database backups
		*******************************************************************************************************/
		IF(UPPER(@pBackupType) = 'TLOG')
		BEGIN
			/******************************************************************************************************
			** When tlog is passed we need to check if @pDatabase is set to full recovery model.
			*******************************************************************************************************/
			IF EXISTS(SELECT 1 FROM sys.databases WHERE recovery_model_desc = 'FULL' and name=@pDatabase)
			BEGIN
				SET @BackupFileName = @FolderLocation + @pDatabase + '_' + @FormatedTime + '.trn';
				SET @BackupName = @pDatabase + '-Transaction Log Backup ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
				SET @SQLCommand = 'BACKUP LOG [' + @pDatabase + ']' + @CRLF;
				SET @SQLCommand = @SQLCommand + '    TO DISK = ''' + @BackupFileName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
				SET @SQLCommand = @SQLCommand + '    NOFORMAT' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NOINIT' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,NAME = N''' + @BackupName + '''' + @CRLF;
				SET @SQLCommand = @SQLCommand + '   ,SKIP' + @CRLF;
				SET @JobDesc = 'Transaction Log Backup(';
			END
			ELSE
			BEGIN
				/******************************************************************************************************
				** @pDatabase isn't set to full recovery model so we raise an error and goto EOF
				*******************************************************************************************************/
				SET @RaiseErrorMessage = 'Database (' + @pDatabase + ') is not set to FULL recovery model.';
				RAISERROR(@RaiseErrorMessage, 16, 1);
				GOTO EOF;
			END
		END

		/******************************************************************************************************
		** For DIFF database backups
		*******************************************************************************************************/
		IF(UPPER(@pBackupType) = 'DIFF')
		BEGIN
			SET @BackupFileName = @FolderLocation + @pDatabase + '_' + @FormatedTime + '.diff';
			SET @BackupName = @pDatabase + '-Differential Database Backup ' + CONVERT(nvarchar, CURRENT_TIMESTAMP);
			SET @SQLCommand = 'BACKUP DATABASE [' + @pDatabase + ']' + @CRLF;
			SET @SQLCommand = @SQLCommand + '    TO DISK = ''' + @BackupFileName + '''' + @CRLF;
			SET @SQLCommand = @SQLCommand + 'WITH' + @CRLF;
			SET @SQLCommand = @SQLCommand + '    DIFFERENTIAL' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,NOFORMAT' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,NOINIT' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,NAME = N''' + @BackupName + '''' + @CRLF;
			SET @SQLCommand = @SQLCommand + '   ,SKIP' + @CRLF;
			SET @JobDesc = 'Differential Database Backup(';
		END

		/******************************************************************************************************
		** Check to see if the expiration date is set and append it to @SQLCommand
		*******************************************************************************************************/
		IF(@pExpireDate IS NOT NULL)
		BEGIN
			SET @SQLCommand = @SQLCommand + '	,EXPIREDATE = ''' + @pExpireDate + '''' + @CRLF;
		END

		/******************************************************************************************************
		** Check to see if compression is enabled and append it to @SQLCommand
		*******************************************************************************************************/
		IF(@MSSQLVersion >= 10.50 AND @pCompress = 1)
		BEGIN
			SET @SQLCommand = @SQLCommand + '	,COMPRESSION' + @CRLF;
			IF(UPPER(@pBackupType) = 'COPY')
				SET @JobDesc = @JobDesc + 'Compressed, Copy-Only)';
			ELSE
				SET @JobDesc = @JobDesc + 'Compressed)';			
		END
		ELSE
		BEGIN
			IF(UPPER(@pBackupType) = 'COPY')
				SET @JobDesc = @JobDesc + 'Non-Compressed, Copy-Only)';
			ELSE
				SET @JobDesc = @JobDesc + 'Non-Compressed)';
		END

		/* Check if server certificate exists and encrypt the backup if it does. */
		/******************************************************************************************************
		** Here we are checking to see if the server supports encryption and if encryption is
		** passed as a parameter.
		*******************************************************************************************************/
		IF(@MSSQLVersion >= 10.50 AND @pEncrypt = 1)
		BEGIN
			/******************************************************************************************************
			** Because sys.certificates wasn't implemented till SQL Server 2008R2 we need to run
			** this as sp_executesql to keep the script from erroring out.
			*******************************************************************************************************/
			SET @ParmDefinition = N'@CertificateName_out nvarchar(130) OUTPUT';
			SET @SQLString = 'SELECT TOP 1 @CertificateName_out = name FROM sys.certificates WHERE pvt_key_encryption_type_desc = ''ENCRYPTED_BY_MASTER_KEY''';
			EXEC sp_executesql @SQLString, @ParmDefinition, @CertificateName_out=@CertificateName OUTPUT

			IF @CertificateName <> ''
			BEGIN
				SET @SQLCommand = @SQLCommand + '	,ENCRYPTION( ALGORITHM = AES_256, SERVER CERTIFICATE = ' + @CertificateName + ')' + @CRLF;
			END
		END

        /******************************************************************************************************
		** Let's try to create the file directory first and if something goes wrong raise
		** an error.
		*******************************************************************************************************/
        BEGIN TRY
            EXEC master.sys.xp_create_subdir @FolderLocation;
        END TRY
        BEGIN CATCH
			SET @RaiseErrorMessage = 'Error creating directory ' + @FolderLocation + '';
            RAISERROR(@RaiseErrorMessage, 16, 1);
			GOTO EOF;
        END CATCH

		BEGIN TRY
			EXEC sp_executesql @SQLCommand;

			END
		END TRY
		BEGIN CATCH
			SELECT
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE()

			RAISERROR(@Results,@ErrorSeverity,@ErrorState);
		END CATCH
	END

	EOF: -- End of File 

END

