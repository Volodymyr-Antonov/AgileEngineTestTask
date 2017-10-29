CREATE PROCEDURE [dbo].[DeleteStore]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@StoreIDs VARCHAR(8000)
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	DECLARE @Processed TABLE (StoreId INT)

	;WITH TARGET AS 
		(SELECT * FROM dbo.Store WHERE IsDeleted = 0)
	MERGE TARGET
	USING
		(SELECT StoreId = CONVERT(INT, Item)
		FROM dbo.SplitString(@StoreIDs, ',')
		WHERE LEN(Item) > 0	AND ISNUMERIC(Item) = 1
		) SOURCE
	ON	TARGET.StoreId = SOURCE.StoreId
	WHEN MATCHED THEN UPDATE SET
		TARGET.IsDeleted = 1
	OUTPUT Deleted.StoreId
		INTO @Processed(StoreId)
	;

	SELECT StoreId  FROM @Processed
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH