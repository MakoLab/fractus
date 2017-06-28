/*
name=[communication].[p_createUnrelateDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
S70x4S/wO81vptlBFYkrlw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createUnrelateDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createUnrelateDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createUnrelateDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createUnrelateDocumentPackage]
@xmlVar XML
AS
DECLARE
@id UNIQUEIDENTIFIER,
@localTransactionId UNIQUEIDENTIFIER,
@deferredTransactionId UNIQUEIDENTIFIER,
@databaseId UNIQUEIDENTIFIER,
@packageName VARCHAR(50)

SELECT		@localTransactionId = x.value(''@localTransactionId'',''char(36)''),
			@deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
			@databaseId = x.value(''@databaseId'',''char(36)''),
			@id = x.value(''@id'',''char(36)''),
			@packageName = x.value(''@packageName'',''varchar(50)'')
FROM @xmlVar.nodes(''root'') AS A(x)

INSERT INTO communication.OutgoingXmlQueue (id, localTransactionId,deferredTransactionId,databaseId, type,xml, creationDate)
SELECT newid(), @localTransactionId, @deferredTransactionId,@databaseId,@packageName ,
CAST(''<root><id>'' + CAST(@id AS CHAR(36)) + ''</id></root>'' AS XML),getdate()
' 
END
GO
