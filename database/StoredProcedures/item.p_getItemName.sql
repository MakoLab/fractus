/*
name=[item].[p_getItemName]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9cXpn+52/Oc+3XDArvqBBA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemName]
@id UNIQUEIDENTIFIER
AS
BEGIN
	SELECT CAST( ''<root>'' + REPLACE(name,''&'',''&amp;'') + ''</root>'' AS XML)
	FROM item.Item i 
	WHERE i.id = @id
	
END
' 
END
GO
