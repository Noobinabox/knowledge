USE DBADemoDB
GO


--case (equality expression)
SELECT
	FirstName,
	LastName,
	CASE Gender
		WHEN 'F' THEN 'FEMALE'
		WHEN 'M' THEN 'MALE'
		ELSE 'Unknown'
	END AS GenderDescription,
	MaritalStatusDescription = CASE MaritalStatus
		WHEN 'S' THEN 'Single'
		WHEN 'M' THEN 'Married'
		ELSE 'Unknown'
	END
FROM
	AdventureWorks2012.HumanResources.Employee e
		JOIN
	AdventureWorks2012.Person.Person p on e.BusinessEntityID = p.BusinessEntityID


-- CASE (searched expression using range)
SELECT
	ProductID,
	Name,
	Price,
	CASE
		WHEN Price < 100 THEN 'Hmm... affordable!'
		WHEN Price >= 100 AND Price < 1000 THEN 'How much??'
		WHEN Price >= 1000 THEN 'Galactic Robbery!'
	END as CustomerResponse
FROM
	Products


--CASE (in ORDER BY)
SELECT
	*
FROM
	Products
ORDER BY
	CASE DiscontinutedFlag WHEN 0 THEN ProductID END DESC


--CASE (in WHERE)
SELECT
	*
FROM
	Products
WHERE
	1 = CASE WHEN Price < 100 THEN 1 ELSE 0 END


--COALESCE (x params, ANSI SQL standard)
SELECT
	EmployeeID,
	FirstName,
	MiddleName,
	LastName,
	FirstName + ' ' + LastName as FirstLastName,
	COALESCE(FirstName + ' ' + MiddleName + ' ' + LastName, 
		FirstName + ' ' + LastName, 
			FirstName, 
				LastName) as FullName
FROM
	Employees


--ISNULL (2 params, T-SQL specific)
SELECT
	EmployeeID,
	FirstName,
	ISNULL(MiddleName, 'N/A') AS MiddleName,
	LastName
FROM
	Employees


--Ranking (employee by salary)
SELECT
	COALESCE(FirstName + ' ' + MiddleName + ' ' + LastName,
				FirstName + ' ' + LastName,
					FirstName,
						LastName) as FullName,
	Title,
	Salary,
	RANK() OVER (ORDER BY Salary DESC) AS SalaryRank,
	ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum,
	DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM
	Employees



--Ranking (top sales by employee, products)
SELECT
	s.EmployeeID,
	p.ProductID,
	SUM(Quantity * Price) as TotalProductSales,
	RANK() OVER (PARTITION BY s.EmployeeID ORDER BY SUM(Quantity * Price) DESC) AS EmployeeProductSalesRank
FROM
	Sales s
		JOIN
	Products p on s.ProductID = p.ProductID
GROUP BY
	s.Employeeid, p.ProductID
