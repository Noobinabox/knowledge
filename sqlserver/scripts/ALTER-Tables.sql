USE DBADemoDB
GO

--How to add an additional column
ALTER TABLE Employees
	ADD
		ActiveFlag bit NOT NULL,
		ModifiedDate datetime NOT NULL
GO

--How to change a column type
ALTER TABLE Products
	ALTER COLUMN Price money
GO

--Used to rename any object
EXEC sp_rename 'Sales', 'SaleOrder'
GO