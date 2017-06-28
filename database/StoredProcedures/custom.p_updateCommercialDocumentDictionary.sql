/*
name=[custom].[p_updateCommercialDocumentDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
V4QMldezVbhqghZ9Gps3qA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_updateCommercialDocumentDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_updateCommercialDocumentDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_updateCommercialDocumentDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [custom].[p_updateCommercialDocumentDictionary] @id UNIQUEIDENTIFIER
AS
BEGIN
 DECLARE @configuration XML,
        @value VARCHAR(1000),
        @count INT,
        @i INT,
		@replaceConf VARCHAR(8000),
		@procedure varchar(max)

	/*Tabela do agregacji słów kluczowych*/	
	DECLARE @tmp_ TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000))

	/*Tabela do wstawienia słów kluczowych*/	
	DECLARE @tmp_key TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000), field NVARCHAR(1000), id_dictionary UNIQUEIDENTIFIER, id_dictionary_new UNIQUEIDENTIFIER, id_relation UNIQUEIDENTIFIER)

	/*Dane indeksowane*/
	DECLARE @tmp_dane TABLE (  i int identity(1,1), columnName varchar(500), value nvarchar(max))

	
			INSERT INTO @tmp_dane( value )
			SELECT fullNumber FROM document.CommercialDocumentHeader where id = @id
			UNION
			SELECT textValue FROM document.DocumentAttrValue WHERE documentFieldId = (SELECT id FROM dictionary.DocumentField WHERE name = ''Attribute_OrderNumber'') AND commercialDocumentHeaderId =  @id
			UNION
			SELECT textValue FROM document.DocumentAttrValue WHERE documentFieldId = (SELECT id FROM dictionary.DocumentField WHERE name = ''Attribute_ProductionOrderNumber'') AND commercialDocumentHeaderId =  @id

			PRINT ''Test''
			
			SELECT @count = COUNT(i), @i = 1 , @replaceConf = ''140,143,156,159,163,165,175,179,181,185,191,198,202,209,210,211,230,234,241,243''
			FROM @tmp_dane
		
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
' 
END
GO
