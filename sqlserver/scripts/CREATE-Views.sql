USE DBADemoDB
GO

CREATE VIEW	vEmployeesWithSales
AS
	SELECT DISTINCT
		Employees.*
	FROM
		Employees
			JOIN
		Sales ON Employees.EmployeeID = Sales.EmployeeID

GO


CREATE VIEW vTop10ProductSalesByQuantity
AS
	
	SELECT TOP 10
		Name AS ProductName,
		SUM(Sales.Quantity) AS TotalQuantity
	FROM
		Sales
			JOIN
		Products ON Sales.ProductID = Products.ProductID
	GROUP BY
		Name
	ORDER BY
		SUM(Sales.Quantity) DESC

GO