USE DBADemoDB
GO

ALTER VIEW vEmployees
AS

	SELECT
		*
	FROM
		Employees
	WHERE
		Title='Sales Person'

WITH CHECK OPTION

GO

INSERT vEmployees SELECT 4, 'Seth',NULL,'Lyon','Sales Person','1/1/2011',80,'57000.00'


EXEC sp_rename 'vEmployeesWithSales', 'vEmployees'

SELECT * FROM Employees