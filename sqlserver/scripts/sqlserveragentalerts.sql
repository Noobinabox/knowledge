/*******************************************************************************************
** File:	sqlserveragentalerts.sql
** Name:	Setup SQL Server Agent Alerts
** Desc:	This will setup all the standard alerts you want to monitor in SQL Server
** Auth:	NoobInABox
** Date:	Nov 3, 2017
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	11/3/17		NoobInABox		Created
*****************************************************************************************/

/*
<summary>
	This scripts assumes you have a operator group called DB Notifications setup on your server and database mail setup as well. You
	can change all of this to meet your needs for notifications.
</summary>
*/


PRINT ''
PRINT 'Installing default alerts and Level 24 Errors...'
GO
 
USE [msdb]
GO

IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Full tempdb')
EXEC msdb.dbo.sp_delete_alert @name=N'Full tempdb'
GO

/****** Object: Alert [Full <database> log]    ******/
DECLARE @command varchar(4000);

SET @command = 'IF EXISTS(SELECT name FROM msdb.dbo.sysalerts WHERE name = ''Full ? log'') EXEC msdb.dbo.sp_delete_alert @name=''Full ? log''';

EXEC sp_MSforeachdb @command;

SET @command = '';
SET @command = 'EXEC msdb.dbo.sp_add_alert @name=''Full ? log'', @message_id=9002, @severity=0, @enabled=1, @delay_between_responses=10, @include_event_description_in=5, @database_name=''?'', @category_name=''[Uncategorized]'', @job_id=''00000000-0000-0000-0000-000000000000''';

EXEC sp_MSforeachdb @command;

SET @command = '';
SET @command = 'EXEC msdb.dbo.sp_add_notification @alert_name=''Full ? log'', @operator_name=''DB Notifications'', @notification_method=1';

EXEC sp_MSforeachdb @command;
GO


/****** Object:  Alert [Severity 14265 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 14265 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 14265 Errors'
GO

IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 3041 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 3041 Errors'
GO

IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Backup Failure')
EXEC msdb.dbo.sp_delete_alert @name=N'Backup Failure'
GO
 
/****** Object:  Alert [Severity 1459 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 1459 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 1459 Errors'
GO
 
/****** Object:  Alert [Severity 17405 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 17405 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 17405 Errors'
GO
 
/****** Object:  Alert [Severity 19 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 19 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 19 Errors'
GO
 
/****** Object:  Alert [Severity 20 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 20 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 20 Errors'
GO
 
/****** Object:  Alert [Severity 21 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 21 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 21 Errors'
GO
 
/****** Object:  Alert [Severity 22 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 22 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 22 Errors'
GO
 
/****** Object:  Alert [Severity 23 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 23 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 23 Errors'
GO
 
/****** Object:  Alert [Severity 24 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 24 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 24 Errors'
GO
 
/****** Object:  Alert [Severity 25 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 25 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 25 Errors'
GO
 
/****** Object:  Alert [Severity 3628 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 3628 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 3628 Errors'
GO
 
/****** Object:  Alert [Severity 5125 Errors]    ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 5125 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 5125 Errors'
GO
 
/****** Object:  Alert [Severity 5159 Errors]******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 5159 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 5159 Errors'
GO
 
/****** Object:  Alert [Severity 823 Errors]******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 823 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 823 Errors'
GO
 
/****** Object:  Alert [Severity 824 Errors]******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 824 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 824 Errors'
GO
 
/****** Object:  Alert [Severity 832 Errors]******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 832 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 832 Errors'
GO
 
/****** Object:  Alert [Severity 9015 Errors]******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Severity 9015 Errors')
EXEC msdb.dbo.sp_delete_alert @name=N'Severity 9015 Errors'
GO

IF	EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Backup Failure')
EXEC msdb.dbo.sp_delete_alert @name=N'Backup Failure'
GO

USE [msdb]
GO
 
/****** Object:  Alert [Severity 14265 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 14265 Errors',
        @message_id=14265,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'The MSSQLServer instance terminated unexpectedly.', 
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 14265 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
 
/****** Object:  Alert [Severity 1459 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 1459 Errors',
        @message_id=1459,
        @severity=0,
        @enabled=1,
		@notification_message=N'An error occurred while accessing the database mirroring metadata. Drop mirroring (ALTER DATABASE database_name SET PARTNER OFF) and reconfigure it.',
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 1459 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 17405 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 17405 Errors',
        @message_id=17405,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'An image corruption/hotpatch detected while reporting exceptional situation. This may be a sign of a hardware problem. Check SQLDUMPER_ERRORLOG.log for details.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 17405 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 19 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 19 Errors',
        @message_id=0,
        @severity=19,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'A nonconfigurable Database Engine limit has been exceeded and the current batch process has been terminated.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 19 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 20 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 20 Errors',
        @message_id=0,
        @severity=20,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'A statement has encountered a problem. Because the problem has affected only the current task, it is unlikely that the database itself has been damaged.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 20 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 21 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 21 Errors',
        @message_id=0,
        @severity=21,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'A problem has been encountered that affects all tasks in the current database, but it is unlikely that the database itself has been damaged.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 21 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 22 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 22 Errors',
        @message_id=0,
        @severity=22,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'A table or index specified in the message has been damaged by a software or hardware problem.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 22 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 23 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 23 Errors',
        @message_id=0,
        @severity=23,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'The integrity of the entire database is in question because of a hardware or software problem.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 23 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 24 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 24 Errors',
        @message_id=0,
        @severity=24,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'A media failure. You may have to restore the database. Not a good day to be a DBA',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 24 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 25 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 25 Errors',
        @message_id=0,
        @severity=25,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 25 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 3628 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 3628 Errors',
        @message_id=3628,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
		@notification_message=N'The Databas Engine received a floating point exception from the operating system while processing a user request.',
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 3628 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 5125 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 5125 Errors',
        @message_id=5125,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 5125 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 5159 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 5159 Errors',
        @message_id=5159,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 5159 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 823 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 823 Errors',
        @message_id=823,
        @severity=0,
        @enabled=1,
        @delay_between_responses=0,
        @include_event_description_in=0,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 823 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 824 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 824 Errors',
        @message_id=824,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 824 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 832 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 832 Errors',
        @message_id=832,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 832 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
/****** Object:  Alert [Severity 9015 Errors]******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 9015 Errors',
        @message_id=9015,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 9015 Errors', @operator_name=N'DB Notifications', @notification_method = 1
GO
 
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure',
        @message_id=3041,
        @severity=0,
        @enabled=1,
        @delay_between_responses=10,
        @include_event_description_in=5,
        @category_name=N'[Uncategorized]',
        @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Backup Failure', @operator_name=N'DB Notifications', @notification_method = 1
GO

PRINT ''
PRINT 'Completed.'
 
-- List the default alerts
EXECUTE msdb.dbo.sp_help_alert;
GO

