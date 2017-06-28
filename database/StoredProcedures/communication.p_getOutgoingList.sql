/*
name=[communication].[p_getOutgoingList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jN7WAle/2tAszPdbStYx+A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getOutgoingList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getOutgoingList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getOutgoingList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getOutgoingList]
@xmlVar XML
AS
BEGIN
DECLARE 
	@isSend  bit,
	@dateFrom datetime,
	@dateTo datetime,
	@databaseId uniqueidentifier

SELECT 
	@isSend = x.value(''@isSend'',''bit''),
	@dateFrom = x.value(''@dateFrom'',''datetime''),
	@dateTo = x.value(''@dateTo'',''datetime'')
FROM @xmlVar.nodes(''root'') AS a ( x )

SELECT (
	SELECT id AS ''@id'', localTransactionId AS ''@localTransactionId'', sendDate AS ''@sendDate'', creationDate AS ''@creationDate'', [type] AS ''@type'', databaseId AS ''@databaseId''
	FROM  communication.OutgoingXmlQueue WITH (NOLOCK)
	WHERE ((@isSend = 1 AND sendDate IS NOT NULL) OR (@isSend = 0 AND sendDate IS NULL) OR @isSend IS NULL) 
			AND (@dateFrom IS NULL OR ( @dateFrom <= creationDate AND @dateTo >= creationDate) )
	ORDER BY creationDate
	-- AND databaseId = @databaseId
	FOR XML PATH(''outgoingXml''), TYPE
) FOR XML PATH(''root''),TYPE
END
' 
END
GO
