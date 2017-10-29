CREATE PROCEDURE [dbo].[SaveProduct]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@ProductXML XML
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	--Validation of XML structure
	DECLARE @SaveProductXML XML(dbo.XMLSchema_SaveProduct) = @ProductXML

	DECLARE @Processed TABLE 
		(Action NVARCHAR(10)
		,ProductId INT
		,ProductTypeId INT
		,ProductName NVARCHAR(250)
		)

	IF OBJECT_ID('tempdb..#SaveProduct') IS NOT NULL DROP TABLE #SaveProduct 

	SELECT 
		 NULLIF(p.n.value('@ProductId', 'int'), 0)             AS ProductId
		,p.n.value('@ProductTypeId', 'int')                    AS ProductTypeId
		,NULLIF(p.n.value('@ProductName', 'varchar(250)'), '') AS ProductName
	INTO #SaveProduct
	FROM @SaveProductXML.nodes('/Products/Product') p(n)

	--Validations
	DECLARE @OutIdList VARCHAR(2048)

	--Check if ProductId`s exists in DB 
	SET @OutIdList = STUFF(
							(SELECT 
								',' + CAST(ProductId AS VARCHAR(15))
							FROM #SaveProduct
							WHERE ProductId NOT IN (SELECT ProductId FROM dbo.Product)
							ORDER BY ProductId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutIdList)>0
		RAISERROR('Following ProductId`s do not registered in the DB: "%s"', 16, 1, @OutIdList)

	--Check if ProductTypeId`s exists in DB 
	SET @OutIdList = STUFF(
							(SELECT 
								',' + CAST(ProductTypeId AS VARCHAR(15))
							FROM #SaveProduct
							WHERE ProductTypeId NOT IN (SELECT ProductTypeId FROM dbo.ProductType)
							ORDER BY ProductTypeId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutIdList)>0
		RAISERROR('Following ProductTypeId`s do not registered in the DB: "%s"', 16, 1, @OutIdList)

	--Check ProductName`s length
	IF EXISTS(SELECT * FROM #SaveProduct WHERE LEN(ProductName) = 0 OR ProductName IS NULL)
		RAISERROR('Product Name is blank', 16, 1)

	;MERGE dbo.vProduct TARGET
	USING #SaveProduct SOURCE
	ON TARGET.ProductId = SOURCE.ProductId
	WHEN MATCHED AND TARGET.ProductName <> SOURCE.ProductName COLLATE SQL_Latin1_General_CP1_CS_AS 
		THEN UPDATE SET
			TARGET.ProductName = SOURCE.ProductName
	WHEN NOT MATCHED THEN
		INSERT (ProductTypeId, ProductName) VALUES (SOURCE.ProductTypeId, SOURCE.ProductName)
	OUTPUT $action, Inserted.ProductId, inserted.ProductTypeId, inserted.ProductName
		INTO @Processed (Action, ProductId, ProductTypeId, ProductName)
	;

	SELECT * FROM @Processed
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH