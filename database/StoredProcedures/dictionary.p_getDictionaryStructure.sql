/*
name=[dictionary].[p_getDictionaryStructure]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CdVGN1KZUoYHn5V+QZYlLg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDictionaryStructure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getDictionaryStructure]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDictionaryStructure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getDictionaryStructure] 
@xmlVar XML = NULL
AS
declare 
	@dictionaryName varchar(40)
begin
	select @dictionaryName = @xmlVar.value(''.'',''varchar(40)'')
	select COLUMN_NAME as "@name", IS_NULLABLE as "@nullable", DATA_TYPE as "@type", CHARACTER_MAXIMUM_LENGTH as "@maxLength" from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA = ''dictionary'' and TABLE_NAME = @dictionaryName for xml path(''column''), root(''columns'');
end
' 
END
GO
