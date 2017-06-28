/*
name=[custom].[p_messengerMarkError]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6ml4pQPC7WTK45SobXND/Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_messengerMarkError]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_messengerMarkError]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_messengerMarkError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [custom].[p_messengerMarkError]
	@messageId uniqueidentifier,
	@errorMessage nvarchar(1000)
AS
	UPDATE Messages SET errorDate = getdate(), errorMessage = @errorMessage
	WHERE id = @messageId
' 
END
GO
