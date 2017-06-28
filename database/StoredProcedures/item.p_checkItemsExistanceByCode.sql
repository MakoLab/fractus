/*
name=[item].[p_checkItemsExistanceByCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dlTGTnPa6plT4iQyi1xISg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemsExistanceByCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_checkItemsExistanceByCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemsExistanceByCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_checkItemsExistanceByCode]
@xmlVar XML 
AS
BEGIN


DECLARE @idoc int


DECLARE @tmp_ TABLE (code nvarchar(500), lineNumber int)

EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO @tmp_ (code, lineNumber)
	SELECT 
	code,
	lineNumber
	FROM OPENXML(@idoc, ''/root/line'')
				WITH(
						code nvarchar(500) ''code'',
						LineNumber int ''LineNumber''
				)
EXEC sp_xml_removedocument @idoc

SELECT (
	SELECT t.LineNumber , i.id
	FROM @tmp_ t 
		JOIN item.Item i ON t.code = i.code
	FOR XML PATH(''line''),TYPE
) FOR XML PATH(''root''), TYPE

END' 
END
GO
