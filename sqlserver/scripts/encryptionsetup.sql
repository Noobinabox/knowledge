/*****************************************************************************************
** File:	encryptionsetup.sql
** Name:	Setup Encryption
** Desc:	Creates a master key, certificate, and database encryption key to enable TDE
** Auth:	NoobInABox
** Date:	Mar 1, 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	3/1/2016	NoobInABox		Created
*****************************************************************************************/
/*
<danger>
If you don't know what you are doing with this don't use it, because you will not be able to restore your database without these certificates...
</danger>
*/
USE [master]
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '[Password Goes Here]';
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '[Password for Master Key Here]';
BACKUP MASTER KEY TO FILE = N'[File Path Location]'
	ENCRYPTION BY PASSWORD = '[New Password to decrypt the master key]';
GO

CREATE CERTIFICATE [Certificate Name Here] WITH SUBJECT = '[Something meaningful here]';
GO

BACKUP CERTIFICATE [Certificate Name Here] TO FILE = N'[File Path Location]'
	WITH PRIVATE KEY ( FILE = N'[File Path Location for PK]',
					   ENCRYPTION BY PASSWORD = '[New password for decryption]');
GO

USE [Database You Want to Encrypt]
GO

CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE [Cerificate Name Here];
GO

ALTER DATABASE [Database You Want to Encrypt] SET ENCRYPTION ON;
GO


