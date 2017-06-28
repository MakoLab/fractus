/*
name=[tools].[p_checkDictionaryEntry]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
G0dC+kYB8DjzLizy9UPr/A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_checkDictionaryEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_checkDictionaryEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_checkDictionaryEntry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_checkDictionaryEntry]
@value nvarchar(500),
@dictionary varchar(200)

AS 
BEGIN
DECLARE @sql nvarchar(4000)

SET @sql = ''
IF EXISTS (
	SELECT id FROM dictionary.'' + @dictionary + '' WHERE id='''''' + @value + '''''')
	
	SELECT 1
	ELSE 
	SELECT 0''
	
 EXECUTE( @sql)	
END
' 
END
GO
