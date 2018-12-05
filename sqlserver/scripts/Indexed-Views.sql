USE NuggetDemoDB
GO

CREATE VIEW dbo.vEmployeeSalesOrders
	WITH SCHEMABINDING, VIEW_METADATA
AS
	SELECT
		Employees.EmployeeID,
		Products.ProductID,
		SUM(Price * Quantity) AS SalesTotal,
		SaleDate,
		COUNT_BIG(*) AS RecordCount
	FROM
		dbo.Employees
			JOIN
		dbo.Sales on Employees.EmployeeID = Sales.EmployeeID
			JOIN
		dbo.Products ON Sales.ProductID = Products.ProductID
	GROUP BY
		Employees.EmployeeID, Products.ProductID, SaleDate

GO

SELECT * FROM dbo.vEmployeeSalesOrders
SELECT * FROM dbo.vEmployeeSalesOrders WITH (NOEXPAND)

CREATE UNIQUE CLUSTERED INDEX CIDX_vEmployeesSalesOrders
	ON dbo.vEmployeeSalesOrders(EmployeeID, ProductID, SaleDate)
GO
