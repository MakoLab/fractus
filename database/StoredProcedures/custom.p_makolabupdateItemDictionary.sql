/*
name=[custom].[p_makolabupdateItemDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2lySuh2dTJ3p4FFUQzaW9A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_makolabupdateItemDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_makolabupdateItemDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_makolabupdateItemDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_makolabupdateItemDictionary]
@itemId UNIQUEIDENTIFIER, @replaceConf VARCHAR(8000)
AS
BEGIN
 
	/*Deklaracja zmiennych*/
    DECLARE 
        @value VARCHAR(1000),
		@count INT,
		@i INT
 
	/*Tabela do agregacji słów kluczowych*/	
	DECLARE @tmp_ TABLE (word NVARCHAR(1000))
 
	/*Tabela do wstawienia słów kluczowych*/	
	DECLARE @tmp_key TABLE (word NVARCHAR(1000), id_dictionary UNIQUEIDENTIFIER, id_dictionary_new UNIQUEIDENTIFIER)
 
	/*Usunięcie indeksowania kartoteki*/
	DELETE FROM item.ItemDictionaryRelation
    WHERE itemId = @itemId
 
    /*Pobranie nazwy kartoteki do zaindeksowania*/
    SELECT @value = name 
	FROM item.Item 
	WHERE id = @itemId
 
	INSERT INTO @tmp_ (word) 
	SELECT ISNULL(word,'''') 
	FROM xp_split([dbo].[f_replace2](@value, @replaceConf), '' '')
 
	SET @value = ''''
 
    /*Pobranie nazwy producenta do zaindeksowania*/
	SELECT @value = v.textValue
	FROM dictionary.ItemField f 
		JOIN item.ItemAttrValue v ON f.id = v.itemFieldId
	WHERE f.name = ''Attribute_Manufacturer'' AND v.itemId = @itemId
 
	INSERT INTO @tmp_ (word) 
	SELECT ISNULL(word,'''') 
	FROM xp_split([dbo].[f_replace2](@value, @replaceConf), '' '')
 
	SET @value = ''''
 
    /*Pobranie nazwy producenta do zaindeksowania*/
	SELECT @value = v.textValue
	FROM dictionary.ItemField f 
		JOIN item.ItemAttrValue v ON f.id = v.itemFieldId
	WHERE f.name = ''Attribute_nManufacturer'' AND v.itemId = @itemId
 
	INSERT INTO @tmp_ (word) 
	SELECT ISNULL(word,'''') 
	FROM xp_split([dbo].[f_replace2](@value, @replaceConf), '' '')
 

 	SET @value = ''''

    /*Pobranie nazwy producenta do zaindeksowania*/
	SELECT @value = v.textValue
	FROM dictionary.ItemField f 
		JOIN item.ItemAttrValue v ON f.id = v.itemFieldId
	WHERE f.name = ''Attribute_EAN'' AND v.itemId = @itemId
 
	INSERT INTO @tmp_ (word) 
	SELECT ISNULL(word,'''') 
	FROM xp_split([dbo].[f_replace2](@value, @replaceConf), '' '')
 


	/*Utworzenie złączenia pomiędzy słowami dla danej kartoteki, a już istniejącymi w słowniku*/
	INSERT INTO @tmp_key (word, id_dictionary, id_dictionary_new)
	SELECT DISTINCT x.word, x.idField, newid() 
	FROM ( 
		SELECT DISTINCT t.word, d.id idField
		FROM @tmp_ t 
			LEFT JOIN [item].ItemDictionary d ON t.word = d.FIELD
		) x
 
	/*Wstawienie słów kluczowych, które nie były wcześniej indeksowane do słownika*/
	INSERT INTO item.ItemDictionary (id, FIELD)
	SELECT DISTINCT id_dictionary_new, word 
	FROM @tmp_key 
	WHERE id_dictionary IS NULL
 
	/*Wstawienie relacji do słów kluczowych*/
	INSERT INTO item.ItemDictionaryRelation (id, itemId, itemDictionaryId)
	SELECT newid(), @itemId, ISNULL(id_dictionary, id_dictionary_new) 
	FROM @tmp_key 
 
END
' 
END
GO
