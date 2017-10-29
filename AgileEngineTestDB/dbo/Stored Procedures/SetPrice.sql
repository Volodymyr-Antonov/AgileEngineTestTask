CREATE PROCEDURE [dbo].[SetPrice]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@PriceXML XML
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	--Validation of XML structure
	DECLARE @SetPriceXML XML(dbo.XMLSchema_SetPrice) = @PriceXML

	IF OBJECT_ID('tempdb..#SetPrice') IS NOT NULL DROP TABLE #SetPrice 
	IF OBJECT_ID('tempdb..#ProductPrice') IS NOT NULL DROP TABLE #ProductPrice 

	SELECT 
		 NULLIF(p.n.value('@ProductId', 'int'), 0)            AS ProductId
		,NULLIF(p.n.value('@StoreIDs', 'varchar(8000)'), '')  AS StoreIDs
		,p.n.value('@Price', 'decimal(18,2)')                 AS Price
	INTO #SetPrice
	FROM @SetPriceXML.nodes('/ProductPrices/ProductPrice') p(n)

	SELECT DISTINCT
		 sp.ProductId
        ,StoreId = CAST(c.Item AS INT)
        ,sp.Price
	INTO #ProductPrice
	FROM #SetPrice sp
	CROSS APPLY dbo.SplitString(sp.StoreIDs,',') c
	WHERE LEN(c.Item) > 0 AND ISNUMERIC(c.Item) = 1

	--Validations
	DECLARE @OutList VARCHAR(2048)

	--Check if ProductId`s exists in DB 
	SET @OutList = STUFF(
							(SELECT 
								',' + CAST(ProductId AS VARCHAR(15))
							FROM #ProductPrice
							WHERE ProductId NOT IN (SELECT ProductId FROM dbo.Product)
							ORDER BY ProductId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Following ProductId`s do not registered in the DB: "%s"', 16, 1, @OutList)

	--Check if StoreId`s exists in DB 
	SET @OutList = STUFF(
							(SELECT 
								',' + CAST(StoreId AS VARCHAR(15))
							FROM #ProductPrice
							WHERE StoreId NOT IN (SELECT StoreId FROM dbo.Store)
							ORDER BY StoreId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Following StoreId`s do not registered in the DB: "%s"', 16, 1, @OutList)

	--Check StoreId and CityName pairs
	SET @OutList = STUFF(
							(SELECT 
								',' + CAST(ProductId AS VARCHAR(15)) + ' -- ' + StoreId
							FROM #ProductPrice
							WHERE Price <= 0 OR Price IS NULL
							ORDER BY StoreId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Price should be greater than 0. Check following pairs of ProductId and StoreId: "%s"', 16, 1, @OutList)

	BEGIN TRAN
		
		IF OBJECT_ID('tempdb..#ProductStorePrice') IS NOT NULL DROP TABLE #ProductStorePrice 
		CREATE TABLE #ProductStorePrice
			(StoreId INT
			,ProductId INT
			,Price DECIMAL(18, 2)
			)

		DECLARE @SetDate DATETIME = GETUTCDATE()

		;WITH TARGET AS	
			(SELECT * FROM dbo.ProductStorePrice WHERE IsActual = 1)
		INSERT INTO #ProductStorePrice
			(StoreId
			,ProductId
			,Price
			)
		SELECT
			 MergeOUT.StoreId
			,MergeOUT.ProductId
			,MergeOUT.Price
		FROM
			(MERGE TARGET
			USING #ProductPrice SOURCE
				ON	TARGET.StoreId = SOURCE.StoreId
				AND TARGET.ProductId = SOURCE.ProductId
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (StoreId, ProductId, Price, StartDate)
				VALUES (SOURCE.StoreId, SOURCE.ProductId, SOURCE.Price, @SetDate)
			WHEN MATCHED AND TARGET.Price <> SOURCE.Price THEN
				UPDATE SET 
					 TARGET.IsActual = 0
					,TARGET.EndDate = @SetDate
			OUTPUT $action ActionOut, SOURCE.ProductId, SOURCE.StoreId, SOURCE.Price
			)AS MergeOUT
		WHERE MergeOUT.ActionOut = 'UPDATE';

		INSERT INTO dbo.ProductStorePrice
			(StoreId
			 ,ProductId
			 ,Price
			 ,StartDate
			)
		SELECT 
			StoreId
            ,ProductId
            ,Price
			,@SetDate AS StartDate
		FROM #ProductStorePrice

	COMMIT

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH