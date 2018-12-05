USE DBADemoDB
GO

INSERT Employees SELECT 1, 'John', NULL, 'Shepard','Sales Person', '1/1/2010',80,35000;
INSERT Employees SELECT 2, 'Jane', NULL, 'Shepard','Sales Person','1/1/2010',80,35000;

INSERT Products SELECT 1, 'Shirt', 12.99
INSERT Products SELECT 2, 'Shorts', 14.99
INSERT Products SELECT 3, 'Pants', 19.99
INSERT Products SELECT 4, 'Hat', 9.99

INSERT Sales SELECT NEWID(),1,1,4,'02/01/2012'
INSERT Sales SELECT NEWID(),2,1,1,'03/01/2012'
INSERT Sales SELECT NEWID(),3,1,2,'02/01/2012'
INSERT Sales SELECT NEWID(),2,2,2,'04/01/2012'
INSERT Sales SELECT NEWID(),3,2,1,'03/01/2012'
INSERT Sales SELECT NEWID(),4,2,2,'01/01/2012'

DECLARE @counter INT
SET @counter = 1

WHILE @counter <= 50000
	BEGIN
		INSERT Sales
			SELECT
				NEWID(),
				(ABS(CHECKSUM(NEWID())) % 4) + 1,
				(ABS(CHECKSUM(NEWID())) % 2) + 1,
				(ABS(CHECKSUM(NEWID())) % 9) + 1,
				DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '2002-04-01')

		SET @counter += 1
	END