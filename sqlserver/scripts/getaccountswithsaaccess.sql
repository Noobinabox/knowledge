/*****************************************************************************************
** File:	getaccountswithsaaccess.sql
** Name:	Get Accounts with SA Access
** Desc:	Returns all accounts with sysadmin access
** Auth:	NoobInABox
** Date:	Mar 1, 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	3/1/2016	NoobInABox		Created
*****************************************************************************************/

USE [master]
GO

SELECT
	p.name AS [loginname],
	p.type,
	p.type_desc,
	p.is_disabled,
	CONVERT(varchar(10), p.create_date, 101) AS [created],
	CONVERT(varchar(10), p.modify_date, 101) AS [update]
FROM
	sys.server_principals p
		JOIN
	sys.syslogins s ON p.sid = s.sid
WHERE
	p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
		AND
	p.name NOT LIKE '##%'
		AND
	s.sysadmin = 1;
GO

