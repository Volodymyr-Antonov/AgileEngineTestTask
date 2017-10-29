CREATE TABLE [dbo].[ProductStorePrice]
(
    [StoreId] INT NOT NULL, 
	[ProductId] INT NOT NULL, 
    [Price] DECIMAL(18, 2) NOT NULL, 
    [StartDate] DATETIME NOT NULL, 
    [EndDate] DATETIME NOT NULL DEFAULT '99991231', 
    [IsActual] BIT NOT NULL DEFAULT 1,
	CONSTRAINT PK_ProductStorePrice PRIMARY KEY (StoreId, ProductId, StartDate),
	CONSTRAINT FK_ProductStorePrice_Product FOREIGN KEY (ProductId) REFERENCES dbo.Product([ProductId]),
	CONSTRAINT FK_ProductStorePrice_StoreId FOREIGN KEY (StoreId) REFERENCES dbo.Store(StoreId),
)
