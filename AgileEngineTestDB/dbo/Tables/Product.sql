CREATE TABLE [dbo].[Product]
(
	[ProductId] INT NOT NULL IDENTITY, 
    [ProductTypeId] INT NOT NULL, 
    [ProductName] NVARCHAR(250) NOT NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (ProductId),
	CONSTRAINT FK_Product_ProductType FOREIGN KEY (ProductTypeId) REFERENCES dbo.ProductType (ProductTypeId)
)
GO

CREATE TRIGGER [dbo].[TR_Product_Insert] ON [dbo].[Product]
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO dbo.ProductHistory
		(ProductId
		,ProductTypeId
		,ProductName
		,IsDeleted
		,Action)
	SELECT
		 ProductId
		,ProductTypeId
		,ProductName
		,IsDeleted
		,'I' AS Action
	FROM Inserted
END
GO
CREATE TRIGGER [dbo].[TR_Product_Update] ON [dbo].[Product]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO dbo.ProductHistory
		(ProductId
		,ProductTypeId
		,ProductName
		,IsDeleted
		,Action)
	SELECT
		 ProductId
		,ProductTypeId
		,ProductName
		,IsDeleted
		,'U' AS Action
	FROM Inserted
END
GO
CREATE TRIGGER [dbo].[TR_Product_Delete] ON [dbo].[Product]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO dbo.ProductHistory
		(ProductId
		,ProductTypeId
		,ProductName
		,IsDeleted
		,Action)
	SELECT
		 ProductId
		,ProductTypeId
		,ProductName
		,IsDeleted
		,'D' AS Action
	FROM Deleted
END
GO

CREATE INDEX [IX_Product_ProductTypeId] ON [dbo].[Product] (ProductTypeId)
GO

CREATE INDEX [FIX_Product_ProductTypeId] ON [dbo].[Product] (ProductTypeId)
WHERE IsDeleted = 0
GO

CREATE UNIQUE INDEX [UX_Product_ProductName] ON [dbo].[Product] (ProductName, ProductTypeId)
WHERE IsDeleted = 0
GO
