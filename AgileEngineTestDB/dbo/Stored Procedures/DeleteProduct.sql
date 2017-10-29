CREATE PROCEDURE [dbo].[DeleteProduct]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@ProductIDs VARCHAR(8000)
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	DECLARE @Processed TABLE (ProductId INT)

	;WITH TARGET AS 
		(SELECT * FROM dbo.Product WHERE IsDeleted = 0)
	MERGE TARGET
	USING
		(SELECT ProductId = CONVERT(INT, Item)
		FROM dbo.SplitString(@ProductIDs, ',')
		WHERE LEN(Item) > 0	AND ISNUMERIC(Item) = 1
		) SOURCE
	ON	TARGET.ProductId = SOURCE.ProductId
	WHEN MATCHED THEN UPDATE SET
		TARGET.IsDeleted = 1
	OUTPUT Deleted.ProductId
		INTO @Processed(ProductId)
	;

	SELECT ProductId FROM @Processed
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH