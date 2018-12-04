/*****************************************************************************************
** File:	rowlevelsecurity.sql
** Name:	Row Level Security
** Desc:	Setting up row level security and the full implementation of it
** Auth:	NoobInABox
** Date:	Mar 1, 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	3/1/2016	NoobInABox		Created
*****************************************************************************************/

USE [sampleDB];
GO

CREATE SCHEMA Customers;
GO
CREATE SCHEMA SecurityInfo;
GO

USE [sampleDB]
GO
CREATE USER John WITHOUT LOGIN WITH DEFAULT_SCHEMA = Customers;
CREATE USER Peter WITHOUT LOGIN WITH DEFAULT_SCHEMA = Customers;
CREATE USER Monica WITHOUT LOGIN WITH DEFAULT_SCHEMA = Customers;
GO

GRANT SELECT ON SCHEMA :: Customers TO John;
GRANT SELECT ON SCHEMA :: Customers TO Peter;
GRANT SELECT ON SCHEMA :: Customers TO Monica;
GO

GRANT INSERT ON SCHEMA :: Customers TO John;
GRANT INSERT ON SCHEMA :: Customers TO Peter;
GRANT INSERT ON SCHEMA :: Customers TO Monica;
GO

GRANT UPDATE ON SCHEMA :: Customers TO John;
GRANT UPDATE ON SCHEMA :: Customers TO Peter;
GRANT UPDATE ON SCHEMA :: Customers TO Monica;
GO

IF OBJECT_ID('Customers.Customers',  'U') IS NOT NULL
  DROP TABLE Customers.Customers
GO

CREATE TABLE Customers.Customers
(ID int IDENTITY NOT NULL,
 Name nvarchar(50) NOT NULL,
 Phone NVARCHAR(20), 
 Email nvarchar(50), 
 CreditCard NVARCHAR(296), 
 UserName sysname NOT NULL, --Row Level Securiry ID
 PRIMARY KEY (ID))
GO


INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Ken Sánchez', N'697-555-0142', 'Ken@mail.com',   N'6975550142', 'John');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName)
VALUES ('Terri Duffy', N'819-555-0175', 'Terri@mail.com',   N'8195550175', 'John');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Roberto Tamburello', N'212-555-0187', 'Roberto@mail.com',   N'2125550187', 'Peter');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Rob Walters', N'612-555-0100', 'Rob@mail.com',   N'6125550100', 'Peter');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Gail Erickson', N'849-555-0139', 'Gail@mail.com',   N'8495550139', 'Peter');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Jossef Goldberg', N'122-555-0189', 'Jossef@mail.com',   N'1225550189', 'Monica');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Dylan Miller', N'181-555-0156', 'Dylan@mail.com',   N'1815550156', 'Monica');

INSERT INTO Customers.Customers (Name, Phone, Email, CreditCard, UserName) 
VALUES ('Diane Margheim', N'815-555-0138', 'Diane@mail.com',   N'8155550138', 'Monica');


IF OBJECT_ID('SecurityInfo.fn_CustomersSecurity', 'IF') IS NOT NULL
BEGIN
DROP FUNCTION SecurityInfo.fn_CustomersSecurity
END
GO

CREATE FUNCTION SecurityInfo.fn_CustomersSecurity(@UserName AS sysname)
	RETURNS TABLE
WITH SCHEMABINDING
AS
	RETURN SELECT 1 AS IsAccessGranted
	WHERE @UserName = USER_NAME();
GO


IF OBJECT_ID('SecurityInfo.CustomersPolicy', 'SP') IS NOT NULL
BEGIN
DROP SECURITY POLICY SecurityInfo.CustomersPolicy
END
GO

CREATE SECURITY POLICY SecurityInfo.CustomersPolicy
ADD FILTER PREDICATE SecurityInfo.fn_CustomersSecurity(UserName) 
ON Customers.Customers
WITH (STATE= ON);

GO


USE [sampleDB]
GO

SELECT * FROM customers.Customers;

EXECUTE AS USER = 'Monica'
SELECT * FROM customers.Customers;
REVERT

EXECUTE AS USER = 'John'
SELECT * FROM customers.Customers;
REVERT

EXECUTE AS USER = 'Peter'
SELECT * FROM customers.Customers;
REVERT

