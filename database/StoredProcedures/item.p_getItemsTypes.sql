/*
name=[item].[p_getItemsTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mgdlbH5MidyhAvIDnGVhzw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsTypes] 
@xmlVar XML
AS

DECLARE @idoc INT

DECLARE @tmp TABLE ( id UNIQUEIDENTIFIER )


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp ( id)
	SELECT id
	FROM OPENXML(@idoc, ''/root/item'')
		WITH (
				id char(36) ''@id''
			)

	EXEC sp_xml_removedocument @idoc

SELECT (
	SELECT i.id as ''@id'', i.itemTypeId as ''@itemTypeId''
	FROM @tmp t 
		JOIN item.Item i  ON t.id = i.id
	FOR XML PATH(''item''), TYPE
) FOR XML PATH(''root''), TYPE
' 
END
GO
