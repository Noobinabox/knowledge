USE DBADemoDB
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id=OBJECT_ID(N'[dbo].[Employees]') AND OBJECTPROPERTY(id, N'IsUserTable') =1)
	DROP TABLE [dbo].[Employees]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id=OBJECT_ID(N'[dbo].[Products]') AND OBJECTPROPERTY(id, N'IsUserTable') =1)
	DROP TABLE [dbo].[Products]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id=OBJECT_ID(N'[dbo].[Sales]') AND OBJECTPROPERTY(id, N'IsUserTable') =1)
	DROP TABLE [dbo].[Sales]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] NOT NULL IDENTITY(1,1),
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](75) NOT NULL,
	[Title] [nvarchar](100) NULL DEFAULT ('New Hire'),
	[HireDate] [datetime] NOT NULL CONSTRAINT DF_HireDate DEFAULT (GETDATE()),
	[VacationHours] [smallint] NOT NULL DEFAULT (0),
	[Salary] [decimal](19, 4) NOT NULL,
	[ActiveFlag] [bit] NOT NULL
) ON [PRIMARY]

GO

USE [DBADemoDB]
GO



CREATE TABLE [dbo].[Products](
	[ProductID] [int] NOT NULL IDENTITY(1,1),
	[Name] [nvarchar](255) NOT NULL,
	[Price] [decimal](19, 4) NOT NULL,
	[DiscontinutedFlag] [bit] NOT NULL CONSTRAINT DF_DiscontinutedFlag DEFAULT(0)
) ON [PRIMARY]

GO

USE [DBADemoDB]
GO



CREATE TABLE [dbo].[Sales](
	[SaleID] [uniqueidentifier] NOT NULL DEFAULT NEWID(),
	[ProductID] [int] NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[SaleDate] [datetime] NOT NULL CONSTRAINT DF_SaleDate DEFAULT (GETDATE())
) ON [PRIMARY]

GO
