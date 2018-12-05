USE DBADemoDB
GO

CREATE TABLE Employees
(
	EmployeeID int NOT NULL,
	FirstName nvarchar(50) NOT NULL,
	MiddleName nvarchar(50) NULL,
	LastName nvarchar(75) NOT NULL,
	Title nvarchar(100) NULL,
	HireDate datetime NOT NULL,
	VacationHours smallint NOT NULL,
	Salary decimal(19,4) NOT NULL
)
GO

CREATE TABLE Products
(
	ProductID int NOT NULL,
	Name nvarchar(255) NOT NULL,
	Price decimal(19,4) NOT NULL,
)
GO

CREATE TABLE Sales
(
	SaleID uniqueidentifier NOT NULL,
	ProductID int NOT NULL,
	EmployeeID int NOT NULL,
	Quantity smallint NOT NULL
)
GO