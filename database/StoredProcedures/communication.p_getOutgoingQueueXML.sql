/*
name=[communication].[p_getOutgoingQueueXML]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
aXSX//wuV2+Izj6oHOZoFw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getOutgoingQueueXML]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getOutgoingQueueXML]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getOutgoingQueueXML]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getOutgoingQueueXML] 
@xmlVar XML
   
AS 
	BEGIN
		DECLARE
		@id UNIQUEIDENTIFIER 

	SELECT @id = x.value(''@id'',''char(36)'')
	FROM @xmlVar.nodes(''root'') AS a ( x )

	SELECT [xml] 
	FROM communication.OutgoingXmlQueue
	WHERE id = @id
 
    END
' 
END
GO
