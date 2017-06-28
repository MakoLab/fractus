/*
name=[tools].[synchronization]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YmGMy+VUY3uAQAZPctT/Dw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[synchronization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[synchronization]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[synchronization]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE tools.synchronization 
AS
BEGIN
	/*Procedura */
	INSERT INTO communication.OutgoingXmlQueue(id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], sendDate, creationDate )
	SELECT DISTINCT NEWID(), NEWID(), NEWID(), databaseId, ''Custom'',''<root> <root typ="ComparisionData"/> </root>'',NULL, GETDATE()
	FROM dictionary.Branch
END
' 
END
GO
