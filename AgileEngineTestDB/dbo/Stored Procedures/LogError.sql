CREATE PROCEDURE dbo.LogError
	 @ErrorLogId BIGINT = NULL OUTPUT
	,@ErrorNumber INT = NULL OUTPUT 
	,@ErrorMessage NVARCHAR(4000) = NULL OUTPUT 
	,@ErrorProcedure NVARCHAR(128) = NULL
	,@Raiserror BIT = NULL
AS
SET XACT_ABORT, NOCOUNT ON

BEGIN TRY
	DECLARE 
		 @ERROR_NUMBER      INT              = ERROR_NUMBER()
		,@ERROR_MESSAGE     NVARCHAR(4000)   = ERROR_MESSAGE()
		,@ERROR_SEVERITY    INT              = ERROR_SEVERITY()   
		,@ERROR_STATE       INT				 = ERROR_STATE()     
		,@ERROR_PROCEDURE   sysname			 = ERROR_PROCEDURE() 
		,@ERROR_LINE        INT				 = ERROR_LINE()      
		,@UserMessage NVARCHAR(2048)         = ERROR_MESSAGE()

	INSERT dbo.ErrorLog
		(ErrorNumber
		,ErrorMessage
		,ErrorSeverity
		,ErrorState
		,ErrorProcedure
		,ErrorLine
		)
	VALUES
		(@ERROR_NUMBER   
		,@ERROR_MESSAGE  
		,@ERROR_SEVERITY 
		,@ERROR_STATE    
		,COALESCE(@ERROR_PROCEDURE, @ErrorProcedure, 'AdHoc Query')
		,@ERROR_LINE     
		)

	SELECT 
		 @ErrorLogId = SCOPE_IDENTITY()
		,@ErrorNumber = @ERROR_NUMBER
		,@ErrorMessage = @ERROR_MESSAGE

END TRY
BEGIN CATCH
	SELECT
		 @Raiserror = 1
		,@ERROR_SEVERITY = 16
		,@UserMessage = 'dbo.LogError failed with "' + ERROR_MESSAGE() +
						'". Original error: "' + @ERROR_MESSAGE + '".'

	SELECT @ErrorNumber = @ERROR_NUMBER, @ErrorMessage = @ERROR_MESSAGE

	IF XACT_STATE() = -1 ROLLBACK TRANSACTION
END CATCH

IF @Raiserror = 1
BEGIN
	-- Adjust severity if needed; plain users cannot raise level 19.
	IF @ERROR_SEVERITY > 18 SET @ERROR_SEVERITY = 18
	
	RAISERROR('%s', @ERROR_SEVERITY, 1,  @UserMessage) WITH NOWAIT
END