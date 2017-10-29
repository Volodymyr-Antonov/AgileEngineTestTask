CREATE TABLE [dbo].[Store]
(
	[StoreId] INT NOT NULL IDENTITY, 
    [StoreName] NVARCHAR(250) NOT NULL,
    [CityId] INT NOT NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0, 
	CONSTRAINT PK_Store PRIMARY KEY (StoreId),
	CONSTRAINT FK_Store_City FOREIGN KEY (CityId) REFERENCES dbo.City (CityId)
)
GO

CREATE TRIGGER [dbo].[TR_Store_Insert] ON [dbo].[Store]
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO dbo.StoreHistory
		(StoreId
		,StoreName
		,CityId
		,IsDeleted
		,Action)
	SELECT
		 StoreId
		,StoreName
		,CityId
		,IsDeleted
		,'I' AS Action
	FROM Inserted
END
GO
CREATE TRIGGER [dbo].[TR_Store_Update] ON [dbo].[Store]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO dbo.StoreHistory
		(StoreId
		,StoreName
		,CityId
		,IsDeleted
		,Action)
	SELECT
		 StoreId
		,StoreName
		,CityId
		,IsDeleted
		,'U' AS Action
	FROM Inserted
END
GO
CREATE TRIGGER [dbo].[TR_Store_Delete] ON [dbo].[Store]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO dbo.StoreHistory
		(StoreId
		,StoreName
		,CityId
		,IsDeleted
		,Action)
	SELECT
		 StoreId
		,StoreName
		,CityId
		,IsDeleted
		,'D' AS Action
	FROM Deleted
END
GO

CREATE INDEX [IX_Store_CityId] ON [dbo].Store (CityId)
GO

CREATE INDEX [FIX_Store_CityId] ON [dbo].Store (CityId)
WHERE IsDeleted = 0
GO

CREATE UNIQUE INDEX [UX_Store_StoreName] ON [dbo].Store (StoreName, CityId)
WHERE IsDeleted = 0
GO
