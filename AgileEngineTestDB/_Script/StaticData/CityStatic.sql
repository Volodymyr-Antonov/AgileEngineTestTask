SET XACT_ABORT, NOCOUNT ON

BEGIN TRY

DECLARE 
	 @AdhocQueryName VARCHAR(255) = 'CityStatic'
	,@AdhocQueryId UNIQUEIDENTIFIER = '536F630A-288D-4EA2-82C0-CF33360A9D1F'--SELECT NEWID()

IF NOT EXISTS (SELECT * FROM dbo.AdhocQuery WHERE AdhocQueryName = @AdhocQueryName AND AdhocQueryId = @AdhocQueryId)
BEGIN

	MERGE dbo.City AS TARGET
	USING
		(VALUES
			 ('Kiev')
			,('Kharkiv')
			,('Dnipro')
			,('Odessa')
			,('Donetsk')
			,('Zaporizhia')
			,('Lviv')
			,('Kryvyi Rih')
			,('Mykolaiv')
			,('Mariupol')
			,('Luhansk')
			,('Makiivka')
			,('Vinnytsia')
			,('Simferopol')
			,('Sevastopol')
			,('Kherson')
			,('Poltava')
			,('Chernihiv')
			,('Cherkasy')
			,('Sumy')
			,('Horlivka')
			,('Zhytomyr')
			,('Kamianske')
			,('Kropyvnytskyi')
			,('Khmelnytskyi')
		) AS SOURCE(CityName)
	ON TARGET.CityName = SOURCE.CityName
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (CityName) VALUES (SOURCE.CityName)
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