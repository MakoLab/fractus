/*
name=[item].[p_insertItemDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZcFRdDnauUjCa8DKOg3Q1w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItemDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_insertItemDictionary] @xmlVar XML
AS

--declare @xmlVar XML
--set @xmlVar = ''<root>
--  <item>
--    <entry>
--      <id>A99CBFD1-AE97-4215-A1F3-4A766DD04D3A</id>
--      <code>ad1</code>
--      <itemTypeId>DD659840-E90E-4C28-8774-4D07B307909A</itemTypeId>
--      <name>ad1</name>
--      <defaultPrice>11.00</defaultPrice>
--      <unitId>2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C</unitId>
--      <version>947A2BC1-C2D8-4C14-B3BA-E2707E4FB3D8</version>
--      <vatRateId>F8D50E4D-066E-4F0A-BD58-C2BC708BEB0F</vatRateId>
--    </entry>
--  </item>
--  <itemUnitRelation />
--  <itemRelation />
--  <itemAttrValue />
--</root>''

    DECLARE @configuration XML,
        @value VARCHAR(1000),
        @id UNIQUEIDENTIFIER,
        @count INT,
        @i INT,
		@replaceConf VARCHAR(8000),
		@idoc int
	
	
		/*Tabela do agregacji słów kluczowych*/	
	DECLARE @tmp_ TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000))

	/*Tabela do wstawienia słów kluczowych*/	
	DECLARE @tmp_key TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000), field NVARCHAR(1000), id_dictionary UNIQUEIDENTIFIER, id_dictionary_new UNIQUEIDENTIFIER, id_relation UNIQUEIDENTIFIER)

	/*Tabele indeksowane*/
	DECLARE @tmp_configuration TABLE ( i int identity(1,1), tableName varchar(100), columnName varchar(100),attributeName varchar(500), attributeFieldId char(36) )

	/*Dane indeksowane*/
	DECLARE @tmp_dane TABLE (  i int identity(1,1), columnName varchar(500), value nvarchar(max))
	
	DECLARE @tmp_dataXml TABLE (id int , parentId int,localname varchar(100), [text] nvarchar(max))

	
	
    BEGIN
	/*Pobranie konfiguracji*/
    SELECT  @configuration = xmlValue
    FROM    configuration.Configuration c
    WHERE   c.[key] = ''Dictionary.configuration''


/*Fragment parsujący konfiguracje*/
	/*Przepisanie do tabeli całej konfiguracji*/
	EXEC sp_xml_preparedocument @idoc OUTPUT, @configuration
	
		INSERT INTO @tmp_configuration ( tableName ,columnName, attributeName )
		SELECT tableName, columnName, attributeName
		FROM OPENXML (@idoc, ''/root/indexing/object/table/column'', 1)
			WITH ( 
					objectName varchar(100)  ''../../@name'',
					tableName varchar(100)  ''../@name'',
					columnName varchar(100) ''@name'',
					attributeName varchar(500) ''../@attributeName''
					
				)
		WHERE objectName = ''item''

		
		SELECT @replaceConf = replaceConfiguration
		FROM OPENXML (@idoc, ''/root/indexing/object'')
		WITH (  replaceConfiguration varchar(8000) ''replaceConfiguration'',
				objectName varchar(100) ''@name'' 
			)
		WHERE objectName = ''item''
				
	EXEC sp_xml_removedocument @idoc

	UPDATE x
		SET x.attributeFieldId = cf.id
	FROM @tmp_configuration x
		JOIN dictionary.ContractorField cf ON x.attributeName = cf.name



/*Fragment parsujący dane indeksowane*/
	/*Przepisanie do tabeli danych*/
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		SELECT @id = id
		FROM OPENXML (@idoc, N''/root/item/entry/id'')
			WITH( id uniqueidentifier ''.'')

 
		INSERT INTO @tmp_dataXml 
		SELECT id, parentId, localname, [text]
		FROM OPENXML (@idoc, N''/root/'', 1)
		
		INSERT INTO @tmp_dane( value )
		SELECT DISTINCT ISNULL(textValue,CAST(decimalValue AS varchar(50)))
		FROM OPENXML (@idoc, N''/root/itemAttrValue/entry'', 1)
		WITH(
				itemFieldId char(36) ''itemFieldId'',
				textValue nvarchar(500) ''textValue'',
				decimalValue decimal(18,6) ''decimalValue''
			)
		WHERE itemFieldId IN (SELECT attributeFieldId FROM @tmp_configuration WHERE attributeFieldId IS NOT NULL)
			

	EXEC sp_xml_removedocument @idoc

	INSERT INTO @tmp_dane( value )
	SELECT distinct x4.text 
	FROM @tmp_dataXml x1
		JOIN @tmp_configuration tab ON x1.localname = tab.tableName
		JOIN @tmp_dataXml x2 ON x1.id = x2.parentId
		JOIN @tmp_dataXml x3 ON x2.id = x3.parentId AND tab.columnName = x3.localname AND tab.attributeFieldId IS NULL
		JOIN @tmp_dataXml x4 ON x3.id = x4.parentId
	
		SELECT @count = COUNT(i), @i = 1 FROM @tmp_dane
		

		WHILE @i <= @count
			BEGIN
				SELECT @value = value 
				FROM @tmp_dane
				WHERE i = @i
				
				/*Wstawienie słownika*/
				INSERT INTO @tmp_ (id, word) 
				SELECT @id, ISNULL(word,'''') 
				FROM xp_split( [dbo].[f_replace2]( @value , @replaceConf) , '' '')
				WHERE ISNULL(word,'''') NOT IN ( SELECT word FROM @tmp_)
				
				SELECT @i = @i + 1
			END

		/*Uproszczony sposób wstawiania dictionary*/

		/*Wybranie słów kluczowych i utworzenie kluczy dla tabel relacji*/
		INSERT INTO @tmp_key ( id,  word, field, id_dictionary,id_dictionary_new , id_relation)
		SELECT DISTINCT x.id, x.word, x.field, x.idField, newid(), newid() 
		FROM ( 
			SELECT DISTINCT t.id, t.word, d.field, d.id idField
			FROM @tmp_ t 
			LEFT JOIN item.v_itemDictionary d WITH (NOEXPAND) ON t.word = d.field
			) x

	
		/*Wstawienie słów kluczowych*/
		INSERT INTO item.ItemDictionary (id, field)
		SELECT DISTINCT id_dictionary_new, word 
		FROM @tmp_key 
		WHERE field IS NULL

		/*Wstawienie relacji do słów kluczowych*/
		INSERT INTO item.ItemDictionaryRelation (id, itemId, itemDictionaryId)
		SELECT id_relation, id,  ISNULL(id_dictionary,id_dictionary_new) FROM @tmp_key 


    END

' 
END
GO
