CREATE TABLE [dbo].[City]
(
	[CityId] INT NOT NULL IDENTITY, 
    [CityName] NVARCHAR(250) NOT NULL,
	CONSTRAINT PK_City PRIMARY KEY CLUSTERED(CityId)
)


GO

CREATE INDEX [UX_City_CityName] ON [dbo].[City] (CityName)
