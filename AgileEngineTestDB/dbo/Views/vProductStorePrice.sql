CREATE VIEW [dbo].[vProductStorePrice]
AS
	SELECT StoreId,
           ProductId,
           Price,
           StartDate
	FROM dbo.ProductStorePrice
	WHERE IsActual = 1