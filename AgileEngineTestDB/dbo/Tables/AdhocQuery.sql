CREATE TABLE [dbo].[AdhocQuery] (
    [AdhocQueryName]  VARCHAR (255)    NOT NULL,
    [AdhocQueryId]    UNIQUEIDENTIFIER NOT NULL,
    [UserName]        NVARCHAR (128)   DEFAULT (suser_name()) NULL,
    [ApplyDate]       DATETIME         DEFAULT (getutcdate()) NULL,
    [ApplicationName] NVARCHAR (128)   DEFAULT (app_name()) NULL,
    [HostName]        NVARCHAR (128)   DEFAULT (host_name()) NULL,
    CONSTRAINT [PK_AdhocQuery] PRIMARY KEY CLUSTERED ([AdhocQueryName] ASC, [AdhocQueryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AdhocQuery_ApplyDate]
    ON [dbo].[AdhocQuery]([ApplyDate] DESC);

