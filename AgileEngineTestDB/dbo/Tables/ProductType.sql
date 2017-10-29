CREATE TABLE [dbo].[ProductType] (
    [ProductTypeId]   INT NOT NULL IDENTITY,
    [ProductTypeName] NVARCHAR(250) NOT NULL,
	CONSTRAINT PK_ProductType PRIMARY KEY CLUSTERED (ProductTypeId)
);


GO

CREATE UNIQUE INDEX [UX_ProductType_ProductTypeName] ON [dbo].[ProductType] (ProductTypeName)
