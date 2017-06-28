/*
name=[item].[p_updateItemDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
IRlu/OvO74PoTet06UVmdg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--select i.code, i.name, id.field 
--from item.Item i
--JOIN item.ItemDictionaryRelation ir ON i.id = ir.itemId
--JOIN item.ItemDictionary id ON ir.itemDictionaryId = id.id
--WHERE i.id = ''5317E901-71B7-4FA3-89D5-000282544B82''

--BEGIN TRAN
--EXEC [item].[p_updateItemDictionary] ''<root businessObjectId="5317E901-71B7-4FA3-89D5-000282544B82"/>''
--select i.code, i.name, id.field 
--from item.Item i
--JOIN item.ItemDictionaryRelation ir ON i.id = ir.itemId
--JOIN item.ItemDictionary id ON ir.itemDictionaryId = id.id
--WHERE i.id = ''5317E901-71B7-4FA3-89D5-000282544B82''

--ROLLBACK TRAN


CREATE PROCEDURE [item].[p_updateItemDictionary]
@xmlVar XML
AS
BEGIN
	
	/*Deklaracja zmienncyh*/
    DECLARE @snap XML,
        @errorMsg VARCHAR(2000),
        @itemId UNIQUEIDENTIFIER,
        @mode VARCHAR(50),
        @iDoc INT,
        @procedure varchar(250),
        @replaceConf VARCHAR(8000)

	/*Pobieranie danych o operacji*/
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar	
		SELECT @itemId = businessObjectId,
				@mode = mode
		FROM OPENXML (@idoc, N''/root'')
			WITH (
				businessObjectId char(36) ''@businessObjectId'',
				mode varchar(10) ''@mode''	
				)	
	EXEC sp_xml_removedocument @idoc
	
	SELECT  @replaceConf = xmlValue.value(''(root/indexing/object[@name="item"]/replaceConfiguration)[1]'',''VARCHAR(8000)'') 
	FROM configuration.Configuration 
	WHERE [key] like ''Dictionary.configuration''
	
	/*Sprawdzenie, czy jest procedura customowa do indeksacji - jeśli jest to ją wywołujemy*/	
	IF  (SELECT xmlValue.value(''(root/indexing/object[@name="item"]/customProcedures/@update)[1]'',''varchar(50)'') 
		FROM configuration.Configuration 
		WHERE [key] like ''Dictionary.configuration'')  IS NOT NULL
		BEGIN
				SELECT @procedure = ''EXEC '' + xmlValue.value(''(root/indexing/object[@name="item"]/customProcedures/@update)[1]'',''varchar(50)'') + '' '''''' + CAST(@itemId AS varchar(36)) + '''''', '''''' + @replaceConf + ''''''''
				FROM configuration.Configuration 
				WHERE [key] like ''Dictionary.configuration''
				EXECUTE(@procedure)
				print @procedure
				
				/*Usunięcie zaindeksowanych słów ze słownika, które nie są powiązane z żadną kartoteką*/
				DELETE  FROM item.ItemDictionary 
                WHERE   id NOT IN (
								SELECT itemDictionaryId 
								FROM item.ItemDictionaryRelation ir 
								)
				RETURN 0;
		END
	
	ELSE	
		BEGIN
			/*Tworzenie snapshota itema*/
			SELECT  @snap = ( SELECT    ( SELECT    ( SELECT    i.*
                                                  FROM      item.Item i
                                                  WHERE     i.id = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''item''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      item.ItemUnitRelation
                                                  WHERE     itemId = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''itemUnitRelation''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    ir.*,
                                                            ( SELECT    ( SELECT    *
                                                                          FROM      item.ItemRelationAttrValue
                                                                          WHERE     itemRelationId = ir.id
                                                                        FOR
                                                                          XML PATH(''entry''),
                                                                              TYPE
                                                                        )
                                                            FOR
                                                              XML PATH(''itemRelationAttrValue''),
                                                                  TYPE
                                                            )
                                                  FROM      item.ItemRelation ir
                                                  WHERE     ir.itemId = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''itemRelation''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      item.ItemAttrValue
                                                  WHERE     itemId = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''itemAttrValue''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''root''),
                              TYPE
                        ) 
			/*Obłsuga błedów i wyjątków*/
			IF @@error <> 0 
				BEGIN
	                
					SET @errorMsg = ''Błąd pobrania danych table: ItemSnapshot; error:''
						+ CAST(@@error AS VARCHAR(50)) + ''; ''
					RAISERROR ( @errorMsg, 16, 1 )
				END

			/*Aktualizacja słownika towaru*/
			IF @mode = ''insert'' 
				EXEC item.p_insertItemDictionary @snap
	            
			IF @mode = ''update'' 
				BEGIN
					DELETE  FROM item.ItemDictionaryRelation
					WHERE   itemId = @itemId
	                
					EXEC item.p_insertItemDictionary @snap
	                
					DELETE  FROM item.ItemDictionary 
					WHERE   id NOT IN (
									SELECT itemDictionaryId 
									FROM item.ItemDictionaryRelation ir 
									)
				END
			
			/*Obsługa błędów i wyjątków*/
			IF @@error <> 0 
				BEGIN
	                
					SET @errorMsg = ''Błąd aktualizacji słownika: Item; error:''
						+ CAST(@@error AS VARCHAR(50)) + ''; ''
					RAISERROR ( @errorMsg, 16, 1 )
				END
	            
		END
    END
' 
END
GO
