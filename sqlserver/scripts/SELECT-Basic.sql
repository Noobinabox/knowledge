USE DBADemoDB
GO


--Basic SELECT all columns from table
SELECT
	*
FROM
	Employees


--Basic SELECT specific columns from table
SELECT
	FirstName,
	LastName,
	Title
FROM
	Employees


--Basic SELECT specific columns from table with a filter (WHERE clause)
SELECT
	FirstName,
	LastName,
	Title
FROM
	Employees
WHERE	
	Title LIKE 'Sales%'


--SELECT using INNER JOIN
SELECT
	*
FROM
	Products P
		JOIN
	Sales s on p.ProductID = s.ProductID


--SELECT using left OUTER JOIN, products with sales
SELECT
	Name,
	COUNT(s.ProductID) as NumberOfSales,
	ISNULL(SUM(Quantity), 0) as SalesQuantityTotal,
	ISNULL(SUM(Price * Quantity), 0) as SalesGrossTotal
FROM
	Products p
		LEFT JOIN
	Sales s on p.ProductID = s.ProductID
GROUP BY
	Name


--SELECT using right OUTER JOIN, employees with sales
SELECT
	FirstName + ' ' + LastName + ' - ' + Title as NameAndTitle,
	COUNT(s.SaleID) as NumberOfSales
FROM
	Sales s
		RIGHT JOIN
	Employees e on s.EmployeeID = e.EmployeeID
GROUP BY
	FirstName + ' ' + LastName + ' - ' + Title
HAVING
	COUNT(s.SaleID) > 0


/** Derived Tables **/
--Simple Derived Table Query
SELECT
	FirstName + ' ' + LastName as Employee
FROM
	(SELECT * FROM Employees WHERE Title LIKE 'Sales%') EmployeeDerived


--Derived Table Query with JOINS
SELECT TOP 10
	Name,
	Quantity,
	FirstName + ' ' + LastName as Employee,
	SaleDate
FROM
	(SELECT * FROM Sales WHERE Quantity = 10) AS SalesQuantityOf10
		JOIN
	Products on SalesQuantityOf10.ProductID = Products.ProductID
		JOIN
	Employees ON SalesQuantityOf10.EmployeeID = Employees.EmployeeID
WHERE
	Products.ProductID = 5
ORDER BY
	SaleDate DESC


--Derived Table Query Aggregate
SELECT
	Name,
	NumberOfSales,
	SalesQuantityTotal,
	SalesGrossTotal
FROM
	Products pout
		JOIN
	(SELECT
		s.ProductID,
		COUNT(*) as NumberOfSales,
		SUM(Quantity) as SalesQuantityTotal,
		SUM(Price * Quantity) as SalesGrossTotal
	FROM
		Sales s
			JOIN
		Products p on s.ProductID = p.ProductID
	GROUP BY
		s.ProductID) sout ON  pout.ProductID = sout.ProductID


--Synonyms
CREATE SYNONYM AWEmployee
	FOR AdventureWorks2012.HumanResources.Employee
GO

SELECT * FROM AWEmployee

DROP SYNONYM AWEmployee
GO