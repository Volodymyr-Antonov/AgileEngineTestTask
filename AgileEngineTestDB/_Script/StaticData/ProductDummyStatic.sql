SET XACT_ABORT, NOCOUNT ON

BEGIN TRY

DECLARE 
	 @AdhocQueryName VARCHAR(255) = 'ProductDummyStatic'
	,@AdhocQueryId UNIQUEIDENTIFIER = '6C79AA4E-54D7-48D3-9FA9-D65EE9F35B59'--SELECT NEWID()

IF NOT EXISTS (SELECT * FROM dbo.AdhocQuery WHERE AdhocQueryName = @AdhocQueryName AND AdhocQueryId = @AdhocQueryId)
BEGIN
	;WITH ProductCTE AS 
		(SELECT
			 x.ProductName
			,ProductTypeNo = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))%(SELECT COUNT(*) FROM dbo.ProductType) + 1
			FROM (VALUES
				 ('Apple Ukraine')
				,('Banana')
				,('Beetroot')
				,('Belozersky pepper')
				,('Big orange')
				,('Bread Own production without yeast 300g Ukraine')
				,('Cabbage')
				,('Carrot')
				,('Cauliflower')
				,('Chilled chicken breast')
				,('Chilled chicken thigh')
				,('Cucumber')
				,('Egg Kvochka chilled c0 10pcs 650g Ukraine')
				,('Egg Novus chilled c0 10pcs Ukraine')
				,('Fruit apple ligol fresh Ukraine')
				,('Ginger')
				,('Golden apple diameter 65-70+')
				,('Granulated sugar Marka promo white crystalline 1000g Ukraine')
				,('Greens dill fresh Ukraine')
				,('Lemon')
				,('Light sparkling mineral water Morshynska 1500ml')
				,('Long loaf Kulynychi (sliced) 500g')
				,('Mandarin Premium')
				,('Meat Indelika turkey fresh')
				,('Morshynska Mineral Still Water 6l')
				,('Onion')
				,('Packed eggplant')
				,('Pasteurized milk Yagotynske 2.6% plastic bottle 900g Ukraine')
				,('Pink tomato')
				,('Plum tomato')
				,('Prostokvashino Pasteurized Milk 2.5%')
				,('Red pepper import')
				,('Selyanske Ultrapasteurized special milk 2.5% 950g')
				,('Sharon persimmon, kg')
				,('Simirenko apple Ukraine')
				,('Still natural mineral water Morshynska 1500ml')
				,('Sultana grapes')
				,('Toast bran bread Kulynychi European 350g Ukraine')
				,('Toast bread Kulynychi European 330g Ukraine')
				,('Tomatoes')
				,('Vegetables eggplant Gelios fresh')
				,('Washed carrot')
				,('Yagotynske Sweet Cream Butter')
				,('Yasensvit Real Giants Chicken Eggs')
				,('Young cabbage')
				,('Young carrot')
				,('Zucchini squash')
				,('Potatoes range of colors')
			) AS x(ProductName)
		)
	,SOURCE AS 
		(SELECT pc.ProductName, pt.ProductTypeId FROM ProductCTE pc
		INNER JOIN
			(SELECT pt.ProductTypeId, ProductTypeNo = ROW_NUMBER() OVER (ORDER BY pt.ProductTypeId)
			FROM dbo.ProductType pt
			) pt ON pc.ProductTypeNo = pt.ProductTypeNo
		)
	MERGE dbo.vProduct AS TARGET
	USING SOURCE
	ON TARGET.ProductName = SOURCE.ProductName AND TARGET.ProductTypeId = SOURCE.ProductTypeId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (ProductName, ProductTypeId) VALUES (SOURCE.ProductName, SOURCE.ProductTypeId)
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