/*
name=[item].[p_checkItemCodeExistence]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hd476JkToJrf2uGK/Gyssg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemCodeExistence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_checkItemCodeExistence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemCodeExistence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_checkItemCodeExistence]
@xmlVar XML
AS
BEGIN
	DECLARE @value varchar(100), @id uniqueidentifier

	SELECT @value = x.value(''(/*/*[1]/code)[1]'', ''varchar(100)''),
			@id =  x.value(''(/*/*[1]/id)[1]'', ''char(36)'')  
	FROM @xmlVar.nodes(''/*'') AS a(x)
	
	--SELECT CAST(''<root>FALSE</root>'' AS  XML) XML
	--RETURN

	IF EXISTS( SELECT id FROM item.Item WHERE code = @value AND id <> @id )
		SELECT CAST(''<root>TRUE</root>'' AS  XML) XML
	ELSE 
		SELECT CAST(''<root>FALSE</root>'' AS  XML) XML

END
' 
END
GO
