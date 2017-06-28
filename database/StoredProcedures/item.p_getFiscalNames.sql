/*
name=[item].[p_getFiscalNames]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rU5iBxVmOuDvR3vhJt4yPg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getFiscalNames]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getFiscalNames]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getFiscalNames]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getFiscalNames]
@xmlVar XML 
AS
BEGIN

DECLARE @idoc int
DECLARE @tmp TABLE (id UNIQUEIDENTIFIER)


EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

INSERT INTO @tmp
SELECT id
FROM OPENXML(@idoc, ''/root/item'')
WITH (
	id char(36) ''@id''
	)

EXEC sp_xml_removedocument @idoc

SELECT (
SELECT i.id ''@id'', ia.textValue AS ''@name'' 
FROM @tmp t 
JOIN item.Item i ON t.id = i.id
	JOIN item.ItemAttrValue ia ON i.id = ia.itemId
	JOIN dictionary.itemField f ON ia.itemFieldId = f.id AND f.name = ''Attribute_FiscalName''
FOR XML PATH(''item''),TYPE
) FOR XML PATH(''root''),TYPE
END
' 
END
GO
