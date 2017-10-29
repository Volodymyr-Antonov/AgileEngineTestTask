CREATE PROCEDURE [dbo].[GetStore]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@CityId INT = NULL
	,@StoreName VARCHAR(250) = NULL
	,@PageNo INT = 1
	,@ItemsPerPage INT = 2147483647
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@SortColumn NVARCHAR(128) = NULL
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	;WITH FilterCTE AS 
		(SELECT 
			 s.StoreId
			,s.StoreName
			,s.CityId
			,c.CityName
			,OrderNo = ROW_NUMBER() OVER (ORDER BY 
											 CASE WHEN @SortColumn = 'StoreName' AND @SortOrder = 'ASC' THEN s.StoreName END
											,CASE WHEN @SortColumn = 'StoreName' AND @SortOrder = 'DESC' THEN s.StoreName END DESC
											,CASE WHEN @SortColumn = 'CityName' AND @SortOrder = 'ASC' THEN c.CityName END
											,CASE WHEN @SortColumn = 'CityName' AND @SortOrder = 'DESC' THEN c.CityName END DESC
											,s.StoreId
										)
			,TotalCount = COUNT(*) OVER()
		FROM dbo.vStore s
		INNER JOIN dbo.City c ON c.CityId = s.CityId
		WHERE 
			(s.StoreName LIKE '%' + @StoreName + '%' OR @StoreName IS NULL)
		AND (s.CityId = @CityId OR @CityId IS NULL)
		)
	SELECT 
		  f.StoreId
         ,f.StoreName
         ,f.CityId
         ,f.CityName
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