CREATE TABLE [dbo].[ProductHistory]
(
	[ProductId] INT NOT NULL, 
    [ProductTypeId] INT NOT NULL, 
    [ProductName] NVARCHAR(250) NOT NULL,
	[IsDeleted] BIT NOT NULL,
	[Action] CHAR(1) NOT NULL,
    [UpdatedDate] NVARCHAR (128) DEFAULT (GETDATE()) NULL,
    [UserName] NVARCHAR (128)  DEFAULT (SUSER_NAME()) NULL,
    [ApplicationName] NVARCHAR (128)  DEFAULT (APP_NAME()) NULL,
    [HostName] NVARCHAR (128)  DEFAULT (HOST_NAME()) NULL,

)

GO

CREATE CLUSTERED INDEX [CX_ProductHistory] ON [dbo].[ProductHistory] (ProductId)
