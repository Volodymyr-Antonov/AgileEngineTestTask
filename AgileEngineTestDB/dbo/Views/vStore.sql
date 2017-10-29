CREATE VIEW vStore
AS 
	SELECT StoreId,
           StoreName,
           CityId
	FROM dbo.Store
	WHERE IsDeleted = 0