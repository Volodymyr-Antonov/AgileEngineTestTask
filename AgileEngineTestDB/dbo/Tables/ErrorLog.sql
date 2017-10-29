CREATE TABLE [dbo].[ErrorLog] (
    [ErrorLogId]      BIGINT          IDENTITY (1, 1) NOT NULL,
    [ErrorLogDate]    DATETIME        DEFAULT (getutcdate()) NULL,
    [ErrorNumber]     INT             NULL,
    [ErrorMessage]    NVARCHAR (4000) NULL,
    [ErrorSeverity]   INT             NULL,
    [ErrorState]      INT             NULL,
    [ErrorProcedure]  NVARCHAR (128)  NULL,
    [ErrorLine]       INT             NULL,
    [UserName]        NVARCHAR (128)  DEFAULT (suser_name()) NULL,
    [ApplicationName] NVARCHAR (128)  DEFAULT (app_name()) NULL,
    [HostName]        NVARCHAR (128)  DEFAULT (host_name()) NULL,
    CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ErrorLog_ErrorLogDate]
    ON [dbo].[ErrorLog]([ErrorLogDate] ASC);

