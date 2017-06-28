/*
name=[document].[p_insertCommercialDocumentDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KsQnqW8UMAyLlfyKbg/orQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertCommercialDocumentDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertCommercialDocumentDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertCommercialDocumentDictionary]
@xmlVar XML
AS
BEGIN
    DECLARE @configuration XML,
        @value VARCHAR(1000),
        @id UNIQUEIDENTIFIER,
        @count INT,
        @i INT,
		@replaceConf VARCHAR(8000),
		@idoc int,
		@configuration2 xml,
		@mode VARCHAR(50),
		@procedure varchar(max)

	/*Tabela do agregacji słów kluczowych*/	
	DECLARE @tmp_ TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000))

	/*Tabela do wstawienia słów kluczowych*/	
	DECLARE @tmp_key TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000), field NVARCHAR(1000), id_dictionary UNIQUEIDENTIFIER, id_dictionary_new UNIQUEIDENTIFIER, id_relation UNIQUEIDENTIFIER)


	/*Tabele indeksowane*/
	DECLARE @tmp_configuration TABLE ( i int identity(1,1), tableName varchar(100), columnName varchar(100),attributeName varchar(500), attributeFieldId char(36) )


	/*Dane indeksowane*/
	DECLARE @tmp_dane TABLE (  i int identity(1,1), columnName varchar(500), value nvarchar(max))
	
	DECLARE @tmp_dataXml TABLE (id int , parentId int,localname varchar(100), [text] nvarchar(max))
	
	/*Pobieranie danych o operacji*/
    SELECT  @id = x.value(''@businessObjectId'', ''char(36)''),
			@mode = @xmlVar.value(''(root/@mode)[1]'', ''varchar(50)'')
    FROM    @xmlVar.nodes(''root'') AS a ( x )

	IF @mode = ''update'' 
		BEGIN
			DELETE FROM document.CommercialDocumentDictionaryRelation
			WHERE commercialDocumentHeaderId = @id 
                
			DELETE FROM document.CommercialDocumentDictionary 
			WHERE id IN (
				SELECT d.id FROM document.CommercialDocumentDictionary d 
					LEFT JOIN document.CommercialDocumentDictionaryRelation r ON d.id = r.commercialDocumentDictionaryId
				WHERE r.id IS NULL
			)
		END

		/*Sprawdzenie, czy jest procedura customowa do indeksacji - jeśli jest to ją wywołujemy*/
		/*Zmiana sposobu pozyskiwania danych */	
	IF  (SELECT xmlValue.value(''(root/indexing/object[@name="commercialDocument"]/customProcedures/@insert)[1]'',''varchar(50)'') 
		FROM configuration.Configuration 
		WHERE [key] like ''Dictionary.configuration'')  IS NOT NULL
		BEGIN
				SELECT @procedure = ''EXEC '' + xmlValue.value(''(root/indexing/object[@name="commercialDocument"]/customProcedures/@insert)[1]'',''varchar(50)'') + '' '''''' + CAST(@id AS varchar(36)) + ''''''''
				FROM configuration.Configuration 
				WHERE [key] like ''Dictionary.configuration''
				EXECUTE(@procedure)
				print @procedure
				

				RETURN 0;
		END
	ELSE	
		BEGIN
	
 			EXEC [document].[p_getCommercialDocumentDataParameter] @id, @xmlVar OUTPUT
 		
			/*Pobranie konfiguracji*/
			SELECT  @configuration2 = xmlValue
			FROM    configuration.Configuration c
			WHERE   c.[key] = ''Dictionary.configuration''
    

		/*Fragment parsujący konfiguracje*/
			/*Przepisanie do tabeli całej konfiguracji*/
			EXEC sp_xml_preparedocument @idoc OUTPUT, @configuration2
	
				/*Pobranie listy tabel z konfiguracji*/
				INSERT INTO @tmp_configuration (  tableName ,columnName, attributeName )
				SELECT tableName, columnName, attributeName
				FROM OPENXML (@idoc, ''/root/indexing/object/table/column'', 1)
					WITH ( 
							objectName varchar(100)  ''../../@name'',
							tableName varchar(100)  ''../@name'',
							columnName varchar(100) ''@name'',
							attributeName varchar(500) ''../@attributeName''
						)
				WHERE objectName = ''commercialDocument''

		
				SELECT @replaceConf = replaceConfiguration
				FROM OPENXML (@idoc, ''/root/indexing/object'')
				WITH (  replaceConfiguration varchar(8000) ''replaceConfiguration'',
						objectName varchar(100) ''@name'' 
					)
				WHERE objectName = ''commercialDocument''
				
			EXEC sp_xml_removedocument @idoc
	
			UPDATE x
				SET x.attributeFieldId = cf.id
			FROM @tmp_configuration x
				JOIN dictionary.DocumentField cf ON x.attributeName = cf.name
	
		/*Fragment parsujący dane indeksowane*/
			/*Przepisanie do tabeli danych*/
	


				EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
		
				SELECT @id = id
				FROM OPENXML (@idoc, N''/root/commercialDocument/entry/id'')
					WITH( id uniqueidentifier ''.'')

 
				INSERT INTO @tmp_dataXml 
				SELECT id, parentId, localname, [text]
				FROM OPENXML (@idoc, N''/root/'', 1)
		
				INSERT INTO @tmp_dane( value )
				SELECT DISTINCT ISNULL(textValue,CAST(decimalValue AS varchar(50)))
				FROM OPENXML (@idoc, N''/root/documentAttrValue/entry'', 1)
				WITH(
						documentFieldId char(36) ''documentFieldId'',
						textValue nvarchar(500) ''textValue'',
						decimalValue decimal(18,6) ''decimalValue''
					)
				WHERE documentFieldId IN (SELECT attributeFieldId FROM @tmp_configuration WHERE attributeFieldId IS NOT NULL)
			

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
				INSERT INTO @tmp_key ( id,  word, field, id_dictionary,id_dictionary_new, id_relation)
				SELECT x.id, x.word, x.field, idField, newid(), newid() 
				FROM (
					SELECT  t.id, t.word, d.field, d.id idField
					FROM @tmp_ t 
						LEFT JOIN document.v_commercialDocumentDictionary d WITH(noexpand) ON t.word like d.field
					GROUP BY  t.id, t.word, d.field, d.id
					) x
			

				/*Wstawienie słów kluczowych*/
				INSERT INTO document.CommercialDocumentDictionary (id, field)
				SELECT DISTINCT id_dictionary_new, word 
				FROM @tmp_key 
				WHERE field IS NULL

				/*Wstawienie relacji do słów kluczowych*/
				INSERT INTO document.CommercialDocumentDictionaryRelation (id, commercialDocumentHeaderId, commercialDocumentDictionaryId)
				SELECT DISTINCT id_relation, id, ISNULL(id_dictionary,id_dictionary_new)  FROM @tmp_key
		
 		END

    END
' 
END
GO
