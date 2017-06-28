/*
name=[tools].[p_indeksujTowary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ureoP+nQ33fN7pB/dCoS4Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_indeksujTowary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_indeksujTowary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_indeksujTowary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_indeksujTowary]
AS
BEGIN
	/*Procedura wywołuje customową procedurę do indeksacji wszystkich kartotek towarów i usług, które są w bazie*/

	DECLARE @T TABLE (i int identity(1,1) primary key, id uniqueidentifier)
	DECLARE @i int, @iMax int, @id uniqueidentifier, @replaceConf VARCHAR(8000)
		
	SELECT  @replaceConf = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'',''VARCHAR(8000)'') 
	FROM configuration.Configuration 
	WHERE [key] like ''Dictionary.configuration''

	INSERT INTO @T (id)
	select i.id
	from item.Item i WITH(NOLOCK)

	SELECT @i = MIN(i), @iMax = MAX(i) FROM @T
	WHILE (@i <= @iMax)
	BEGIN
		  SELECT @id = id FROM @T WHERE i = @i
	      
		  exec [custom].[p_updateItemDictionary] @id, @replaceConf
	      
		  SET @i = @i + 1
	END
					
	/*Usunięcie zaindeksowanych słów ze słownika, które nie są powiązane z żadną kartoteką*/
	DELETE  FROM item.ItemDictionary 
	WHERE   id NOT IN (
					SELECT itemDictionaryId 
					FROM item.ItemDictionaryRelation ir 
					)
END
' 
END
GO
