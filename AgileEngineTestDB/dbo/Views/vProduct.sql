CREATE VIEW vProduct
AS 
	SELECT ProductId,
          ProductTypeId,
          ProductName
	FROM dbo.Product
	WHERE IsDeleted = 0