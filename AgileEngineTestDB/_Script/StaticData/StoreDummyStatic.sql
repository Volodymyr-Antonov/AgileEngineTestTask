SET XACT_ABORT, NOCOUNT ON

BEGIN TRY

DECLARE 
	 @AdhocQueryName VARCHAR(255) = 'StoreDummyStatic'
	,@AdhocQueryId UNIQUEIDENTIFIER = '6C79AA4E-54D7-48D3-9FA9-D65EE9F35B59'--SELECT NEWID()

IF NOT EXISTS (SELECT * FROM dbo.AdhocQuery WHERE AdhocQueryName = @AdhocQueryName AND AdhocQueryId = @AdhocQueryId)
BEGIN

	IF OBJECT_ID('tempdb..#RandomStore') IS NOT NULL DROP TABLE #RandomStore

	CREATE TABLE #RandomStore ([StoreName] NVARCHAR(250) NOT NULL, [CityId] INT NOT NULL)

	DECLARE
		@RandomItemsPerGroup INT = ABS(CHECKSUM(NEWID()))%5 + 5 --Pure random 5..10
		,@CitiesToInsert INT = 7
		,@i INT = 0

	WHILE @i <@CitiesToInsert
	BEGIN

		;WITH E1(N) AS (
						 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
						 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
						 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
						)
		,TallyCTE(N) AS 
			(SELECT TOP (ABS(CHECKSUM(NEWID()))%5 + 5 ) --Pure random 5..10
				ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) 
			FROM E1
			)
		INSERT #RandomStore	(StoreName, CityId)
		SELECT 
			StoreName = 'Store No ' + CAST(cte.N AS VARCHAR(20))
			,c.CityId 
		FROM TallyCTE cte
		CROSS JOIN
			(SELECT TOP 1 CityId
			FROM dbo.City
			WHERE CityId NOT IN (SELECT CityId FROM #RandomStore)
			ORDER BY NEWID()
			)c

		SET @i += 1
	END


	MERGE dbo.vStore AS TARGET
	USING #RandomStore SOURCE
	ON TARGET.StoreName = SOURCE.StoreName AND TARGET.CityId = SOURCE.CityId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (StoreName, CityId) VALUES (SOURCE.StoreName, SOURCE.CityId)
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