USE NuggetDemoDB
GO

IF OBJECT_ID('iProductNotification', 'TR') IS NOT NULL
	DROP TRIGGER iProductNotification
GO

CREATE TRIGGER iProductNotification ON Products
	FOR INSERT
AS
	DECLARE @ProductInformation nvarchar(255);

	SELECT
		@ProductInformation = 'New product ' + Name + ' is now available for ' + CAST(Price as nvarchar(20)) + '!'
	FROM
		inserted;

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Notifications',
		@recipients = '[Email Address Here]',
		@body = @ProductInformation,
		@subject = 'New Product Notification';
GO