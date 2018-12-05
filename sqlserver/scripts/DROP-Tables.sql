USE DBADemoDB
GO

--Used to drop a specific column
ALTER TABLE Products
	DROP COLUMN Price;
GO

--Basic drop table command
DROP TABLE Employees;
DROP TABLE Products;
DROP TABLE SaleOrder;
