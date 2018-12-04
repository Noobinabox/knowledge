/*****************************************************************************************
** File:	checkgroupmembership.sql
** Name:	Check Windows Group Membership
** Desc:	Returns all users in a group assigned in SQL Server
** Auth:	NoobInABox
** Date:	Mar 1, 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	3/1/2016	NoobInABox		Created
*****************************************************************************************/

EXEC xp_loginfo '[Insert Domain\Local Group Account Here]', 'members';
GO
