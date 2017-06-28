/*
name=[custom].[p_messengerGetMessage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
v0YzoJAp6bV+GLK27v9tvw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_messengerGetMessage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_messengerGetMessage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_messengerGetMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [custom].[p_messengerGetMessage]
AS
	SELECT TOP 1
	id, type, recipient, sender, message, subject
	FROM Messages
	WHERE sendDate IS NULL AND errorDate IS NULL
	ORDER BY creationDate ASC
' 
END
GO
