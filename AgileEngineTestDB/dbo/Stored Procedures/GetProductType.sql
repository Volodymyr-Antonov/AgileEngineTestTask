CREATE PROCEDURE [dbo].[GetProductType]
	@ErrorMessage NVARCHAR(4000) = NULL OUTPUT
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	SELECT 
		  pt.ProductTypeId
		 ,pt.ProductTypeName
	FROM dbo.ProductType pt
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH
