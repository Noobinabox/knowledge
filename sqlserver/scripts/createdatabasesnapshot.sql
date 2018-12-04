/*****************************************************************************************
** File:	createdatabasesnapshot.sql
** Name:	Create Database Snapshot
** Desc:	Create a snapshot of a database for all your snapshot database needs
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

CREATE DATABASE AdventureWorksDW2012_dbss_1400 ON
( NAME = AdventureWorksDW2012_Data,
  FILENAME = '[File Path Location]')
AS SNAPSHOT OF AdventureWorksDW2012;
GO
