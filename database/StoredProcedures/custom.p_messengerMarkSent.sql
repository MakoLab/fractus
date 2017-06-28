/*
name=[custom].[p_messengerMarkSent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DIecGZvN/pEA2ciMQvmKWQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_messengerMarkSent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_messengerMarkSent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_messengerMarkSent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [custom].[p_messengerMarkSent]
	@messageId uniqueidentifier
AS
	UPDATE Messages SET sendDate = getdate() WHERE id = @messageId
' 
END
GO
