/*
name=[reports].[p_getGetItemCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hH1Q1SZzRfslQYKmptoIGg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getGetItemCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getGetItemCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getGetItemCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getGetItemCode]
@xmlVar XML
AS
BEGIN

	DECLARE @date datetime

	SELECT @date = DATEADD(m,-1,getdate())

	SELECT (
		SELECT i.name ''@itemName'', ic.ean + RIGHT(''0000''+ cast(ic.itemNumber as varchar(50)), 5) ''@itemCode'', ist.status ''@status''
		FROM item.Item i WITH(NOLOCK)
			JOIN custom.ItemCode ic ON i.id = ic.itemId
			JOIN custom.ItemStatus ist ON ist.itemCodeId = ic.id
		ORDER BY ic.ean ,	ic.itemNumber		
		FOR XML PATH(''line''), TYPE )
	FOR XML PATH(''line''), TYPE		

END
' 
END
GO
