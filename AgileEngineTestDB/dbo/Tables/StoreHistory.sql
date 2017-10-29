CREATE TABLE [dbo].[StoreHistory]
(
	[StoreId] INT NOT NULL, 
    [StoreName] NVARCHAR(250) NOT NULL,
    [CityId] NVARCHAR(250) NOT NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0, 
	[Action] CHAR(1) NOT NULL,
    [UpdatedDate] NVARCHAR (128) DEFAULT (GETDATE()) NULL,
    [UserName] NVARCHAR (128)  DEFAULT (SUSER_NAME()) NULL,
    [ApplicationName] NVARCHAR (128)  DEFAULT (APP_NAME()) NULL,
    [HostName] NVARCHAR (128)  DEFAULT (HOST_NAME()) NULL,
)
GO

CREATE CLUSTERED INDEX [CX_StoreHistory] ON [dbo].[StoreHistory] (StoreId)

