SET XACT_ABORT, NOCOUNT ON

BEGIN TRY

DECLARE 
	 @AdhocQueryName VARCHAR(255) = 'ProductTypeStatic'
	,@AdhocQueryId UNIQUEIDENTIFIER = '08003E29-191D-4760-B9D7-51F65A748A4D'--SELECT NEWID()

IF NOT EXISTS (SELECT * FROM dbo.AdhocQuery WHERE AdhocQueryName = @AdhocQueryName AND AdhocQueryId = @AdhocQueryId)
BEGIN

	MERGE dbo.ProductType AS TARGET
	USING
		(VALUES
			 ('Book')
			,('Toy')
			,('Clothes')
		) AS SOURCE(ProductTypeName)
	ON TARGET.ProductTypeName = SOURCE.ProductTypeName
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (ProductTypeName) VALUES (SOURCE.ProductTypeName)
	;

	INSERT INTO dbo.AdhocQuery (AdhocQueryName, AdhocQueryId) VALUES (@AdhocQueryName, @AdhocQueryId)

	PRINT '+Adhoc query has been succesfully applied: AdhocQueryName = ''' + @AdhocQueryName 
			+ ''', AdhocQueryId = ''' + CAST(@AdhocQueryId AS VARCHAR(50)) + ''''

END
ELSE
	PRINT '-Adhoc query skipped: AdhocQueryName = ''' + @AdhocQueryName
			+ ''', AdhocQueryId = ''' + CAST(@AdhocQueryId AS VARCHAR(50)) + ''''
END TRY
BEGIN CATCH
   EXEC dbo.LogError @ErrorProcedure = @AdhocQueryName, @Raiserror = 1
END CATCH
GO