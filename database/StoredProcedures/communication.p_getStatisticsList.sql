/*
name=[communication].[p_getStatisticsList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VI2pcFewjmVOmtVETtXILA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getStatisticsList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getStatisticsList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getStatisticsList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getStatisticsList]
AS
BEGIN

	SELECT (
		SELECT (
			SELECT  getdate() currentTime,
					s.databaseId,
					s.lastUpdate,
					s.undeliveredPackagesQuantity,
					s.unprocessedPackagesQuantity,
					s.lastExecutionTime,
					s.sentMessageTime,
					s.executionMessageTime,
					s.receiveMessageTime,
					ISNULL((SELECT count(id) FROM communication.OutgoingXmlQueue WHERE databaseId = s.databaseId AND sendDate IS NULL ),0) unsentPackage,
					(SELECT max(sendDate) FROM communication.OutgoingXmlQueue WHERE databaseId = s.databaseId) lastReceiveDate,
					(SELECT max(receiveDate) FROM communication.IncomingXmlQueue WHERE databaseId = s.databaseId ) lastSendDate
			FROM communication.[Statistics] s WITH(NOLOCK)
		  FOR XML PATH(''entry''),TYPE )
		FOR XML PATH(''statistics''),TYPE )
	FOR XML PATH(''root''),TYPE
	
END' 
END
GO
