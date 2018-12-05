USE DBADemoDB
GO

CREATE TABLE EmployeeAuditTrail
(
	EmployeeAuditID INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	EmployeeID int NOT NULL,
	FirstName nvarchar(50) NULL,
	MiddleName nvarchar(50) NULL,
	LastName nvarchar(75) NULL,
	Title nvarchar(100) NULL,
	HireDate datetime NULL,
	VacationHours int NULL,
	Salary decimal(19,4) NULL,
	ModifiedDate datetime NULL,
	ModifiedBy nvarchar(255) NULL
)
GO


IF OBJECT_ID ('udEmployeeAudit', 'TR') IS NOT NULL
	DROP TRIGGER udEmployeeAudit
GO

CREATE TRIGGER udEmployeeAudit ON Employees
	FOR UPDATE, DELETE
AS
		INSERT EmployeeAuditTrail
			SELECT
				e.EmployeeID, d.FirstName, d.MiddleName, d.LastName,
				d.Title, d.HireDate, d.VacationHours, d.Salary,
				GETDATE(), SYSTEM_USER
			FROM
				Employees e
					JOIN
				deleted d on e.EmployeeID = d.EmployeeID
GO

IF OBJECT_ID ('uRecalucateVacationHours', 'TR') IS NOT NULL
	DROP TRIGGER uRecalucateVacationHours
GO

CREATE TRIGGER uRecalucateVacationHours ON Employees
	FOR UPDATE
AS
		IF UPDATE(HireDate)
			BEGIN
				DECLARE @RecalcFlag bit
				SELECT @RecalcFlag = IIF(YEAR(HireDate) = 2012, 1, 0) FROM inserted

				IF (@RecalcFlag = 1)
					UPDATE Employees SET VacationHours += 40 FROM Employees e JOIN inserted i ON e.EmployeeID = i.EmployeeID
			END
GO