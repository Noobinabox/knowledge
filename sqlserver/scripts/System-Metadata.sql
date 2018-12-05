USE NuggetDemoDB
GO

--Using OBJECT_ID metadata function
IF OBJECT_ID('iProductNofitication', 'TR') IS NOT NULL
	DROP TRIGGER iProductNofitication
GO

IF OBJECTPROPERTY(OBJECT_ID('Employees'), 'IsTable') = 1
	PRINT 'Yes, it''s a Table.'
ELSE
	PRINT 'No, it''s not a Table.'
GO


SELECT
	*
FROM
	sys.objects
WHERE
	OBJECTPROPERTY(object_id, 'SchemaID') = SCHEMA_ID('dbo')

SELECT * FROM INFORMATION_SCHEMA.TABLES
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

exec sp_Help 'Employees'


exec sp_MSforEachTable 'DBCC CHECKTABLE ([?])';
exec sp_MSforeachTable 'EXEC sp_spaceused [?]';

