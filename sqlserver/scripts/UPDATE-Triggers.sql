USE DBADemoDB
GO


IF OBJECT_ID('ProductPriceHistory', 'U') IS NOT NULL
	DROP TABLE ProductPriceHistory
GO


CREATE TABLE ProductPriceHistory
(
	PriceHistoryID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
	ProductID int NOT NULL,
	PreviousPrice decimal(19,4) NULL,
	NewPrice decimal(19,4) NOT NULL,
	PriceChangeDate datetime NOT NULL
)


IF OBJECT_ID('uProductPriceChange', 'TR') IS NOT NULL
	DROP TRIGGER uProductPriceChange
GO

--Creating a trigger to insert into another database if a price changes on a product
CREATE TRIGGER uProductPriceChange ON Products
	FOR UPDATE
AS
	
	INSERT ProductPriceHistory (PriceHistoryID, ProductID, PreviousPrice, NewPrice, PriceChangeDate)
		SELECT
			NEWID(), p.ProductID, d.price, i.Price, GETDATE()
		FROM
			Products p
				JOIN
			inserted i on p.ProductID = i.ProductID
				JOIN
			deleted d on p.ProductID = d.ProductID

GO