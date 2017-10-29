CREATE PROCEDURE [dbo].[SaveStore]
	 @ErrorMessage NVARCHAR(4000) = NULL OUTPUT
	,@StoreXML XML
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	--Validation of XML structure
	DECLARE @SaveStoreXML XML(dbo.XMLSchema_SaveStore) = @StoreXML

	DECLARE @Processed TABLE 
		(Action NVARCHAR(10)
		,StoreId INT
		,CityId INT
		,StoreName NVARCHAR(250)
		)

	IF OBJECT_ID('tempdb..#SaveStore') IS NOT NULL DROP TABLE #SaveStore 

	SELECT 
		 NULLIF(p.n.value('@StoreId', 'int'), 0)             AS StoreId
		,NULLIF(p.n.value('@CityId', 'int'), 0)              AS CityId
		,NULLIF(p.n.value('@CityName', 'varchar(250)'), '')   AS CityName
		,NULLIF(p.n.value('@StoreName', 'varchar(250)'), '') AS StoreName
	INTO #SaveStore
	FROM @SaveStoreXML.nodes('/Stores/Store') p(n)

	--Validations
	DECLARE @OutList VARCHAR(2048)

	--Check if StoreId`s exists in DB 
	SET @OutList = STUFF(
							(SELECT 
								',' + CAST(StoreId AS VARCHAR(15))
							FROM #SaveStore
							WHERE StoreId NOT IN (SELECT StoreId FROM dbo.Store)
							ORDER BY StoreId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Following StoreId`s do not registered in the DB: "%s"', 16, 1, @OutList)

	--Check if CityId`s exists in DB 
	SET @OutList = STUFF(
							(SELECT 
								',' + CAST(CityId AS VARCHAR(15))
							FROM #SaveStore
							WHERE CityId NOT IN (SELECT CityId FROM dbo.City)
							ORDER BY CityId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Following CityId`s do not registered in the DB: "%s"', 16, 1, @OutList)

	--Check StoreName`s length
	IF EXISTS(SELECT * FROM #SaveStore WHERE LEN(StoreName) = 0 OR StoreName IS NULL)
		RAISERROR('Store Name is blank', 16, 1)

	--Check CityId and CityName pairs
	SET @OutList = STUFF(
							(SELECT 
								',' + CAST(CityId AS VARCHAR(15)) + ' -- ' + CityName
							FROM #SaveStore
							WHERE LEN(CityName) > 0 AND CityId IS NOT NULL
							ORDER BY CityId
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Both attributes CityId and CityName were provided for following pairs: "%s"', 16, 1, @OutList)

	SET @OutList = STUFF(
							(SELECT 
								',' + StoreName
							FROM #SaveStore
							WHERE (LEN(CityName) = 0 OR CityName IS NULL) AND CityId IS NULL
							ORDER BY StoreName
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('Neither CityId nor CityName were provided for following Stores: "%s"', 16, 1, @OutList)

	--Store uniqueness
	SET @OutList = STUFF(
							(SELECT 
								',' + CityName + ' -- ' + StoreName
							FROM 
								(SELECT DISTINCT ss.StoreName, CityName = ISNULL(ss.CityName, cc.CityName)
								FROM #SaveStore ss
								LEFT JOIN dbo.City cc ON ss.CityId = cc.CityId
								WHERE EXISTS(SELECT * FROM dbo.Store s
											INNER JOIN dbo.City c ON s.CityId = c.CityId
											WHERE ISNULL(ss.CityName, cc.CityName) = c.CityName AND ss.StoreName = s.StoreName
											AND NOT EXISTS(SELECT ss.StoreId INTERSECT SELECT s.StoreId)
											)
								UNION ALL 
								SELECT ss.StoreName, ISNULL(c.CityName, ss.CityName) AS CityName
								FROM #SaveStore ss
								LEFT JOIN dbo.City c ON c.CityId = ss.CityId
								GROUP BY ss.StoreName, ISNULL(c.CityName, ss.CityName) 
								HAVING COUNT(*) > 1
								) DuplicatedStores
							ORDER BY CityName, StoreName
							FOR XML PATH(''))
							, 1, 1, ''
						)
	IF LEN(@OutList)>0
		RAISERROR('StoreName must be unique within the City. Check following CityName and StoreName pairs: "%s"', 16, 1, @OutList)

	BEGIN TRAN
		
		IF EXISTS (SELECT * FROM #SaveStore WHERE LEN(CityName) > 0)
			MERGE dbo.City AS TARGET 
			USING (SELECT DISTINCT CityName FROM #SaveStore WHERE LEN(CityName) > 0
					) SOURCE
			ON TARGET.CityName = SOURCE.CityName
			WHEN NOT MATCHED THEN
				INSERT(CityName) VALUES (SOURCE.CityName)
			;
		
		;WITH SOURCE AS
			(SELECT
				 ss.StoreId
                ,CityId = ISNULL(ss.CityId, c.CityId)
                ,ss.StoreName
			FROM #SaveStore ss
			LEFT JOIN dbo.City c ON ss.CityName = c.CityName
			)
		MERGE dbo.vStore TARGET
		USING SOURCE
		ON TARGET.StoreId = SOURCE.StoreId
		WHEN MATCHED 
			AND (	TARGET.StoreName <> SOURCE.StoreName COLLATE SQL_Latin1_General_CP1_CS_AS 
				OR	TARGET.CityId <> SOURCE.CityId
				)
			THEN UPDATE SET
				 TARGET.StoreName = SOURCE.StoreName
				,TARGET.CityId = SOURCE.CityId
		WHEN NOT MATCHED THEN
			INSERT (CityId, StoreName) VALUES (SOURCE.CityId, SOURCE.StoreName)
		OUTPUT $action, Inserted.StoreId, inserted.CityId, inserted.StoreName
			INTO @Processed (Action, StoreId, CityId, StoreName)
		;

	COMMIT

	SELECT 
		 p.Action
        ,p.StoreId
        ,p.CityId
        ,c.CityName
        ,p.StoreName
	FROM @Processed p
	INNER JOIN dbo.City c ON p.CityId = c.CityId

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	EXEC dbo.LogError @ErrorMessage = @ErrorMessage OUTPUT
END CATCH