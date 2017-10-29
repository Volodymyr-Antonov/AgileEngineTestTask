CREATE PROCEDURE [dbo].[GetProduct]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@ProductTypeId INT = NULL
	,@ProductName VARCHAR(250) = NULL
	,@PageNo INT = 1
	,@ItemsPerPage INT = 2147483647
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@SortColumn NVARCHAR(128) = NULL
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	;WITH FilterCTE AS 
		(SELECT 
			 p.ProductId
			,p.ProductTypeId
			,pt.ProductTypeName
			,p.ProductName
			,OrderNo = ROW_NUMBER() OVER (ORDER BY 
											 CASE WHEN @SortColumn = 'ProductTypeName' AND @SortOrder = 'ASC' THEN pt.ProductTypeName END
											,CASE WHEN @SortColumn = 'ProductTypeName' AND @SortOrder = 'DESC' THEN pt.ProductTypeName END DESC
											,CASE WHEN @SortColumn = 'ProductName' AND @SortOrder = 'ASC' THEN p.ProductName END
											,CASE WHEN @SortColumn = 'ProductName' AND @SortOrder = 'DESC' THEN p.ProductName END DESC
											,p.ProductId
										)
			,TotalCount = COUNT(*) OVER()
		FROM vProduct p
		INNER JOIN dbo.ProductType pt ON p.ProductTypeId = pt.ProductTypeId
		WHERE 
			(p.ProductName LIKE '%' + @ProductName + '%' OR @ProductName IS NULL)
		AND (p.ProductTypeId = @ProductTypeId OR @ProductTypeId IS NULL)
		)
	SELECT 
		 f.ProductId
		,f.ProductTypeId
		,f.ProductName
		,f.ProductTypeName
		,f.TotalCount
		,NumberOnPage = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
	FROM FilterCTE f
	WHERE 
		(	ISNULL(@PageNo, 1) <= 1 AND @ItemsPerPage = 2147483647 --INT max value
		OR	f.OrderNo BETWEEN (@PageNo-1)*@ItemsPerPage+1 AND @PageNo*@ItemsPerPage
		)
	OPTION(RECOMPILE)
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH