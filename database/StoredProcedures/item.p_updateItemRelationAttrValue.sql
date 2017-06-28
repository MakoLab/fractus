/*
name=[item].[p_updateItemRelationAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xE0R5W6FAkvOCKbKZLGafw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemRelationAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemRelationAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemRelationAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_updateItemRelationAttrValue]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o wartościach atrybutów powiązań towarów*/
        UPDATE  item.ItemRelationAttrValue
        SET     itemRelationId = CASE WHEN con.exist(''itemRelationId'') = 1
                                      THEN con.query(''itemRelationId'').value(''.'', ''char(36)'')
                                      ELSE NULL
                                 END,
                itemRAVTypeId = CASE WHEN con.exist(''itemRAVType'') = 1
                                     THEN con.query(''itemRAVTypeId'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END,
                decimalValue = CASE WHEN con.exist(''decimalValue'') = 1
                                    THEN con.query(''decimalValue'').value(''.'', ''decimal(18,4)'')
                                    ELSE NULL
                               END,
                dateValue = CASE WHEN con.exist(''dateValue'') = 1
                                 THEN con.query(''dateValue'').value(''.'', ''varchar(50)'')
                                 ELSE NULL
                            END,
                textValue = CASE WHEN con.exist(''textValue'') = 1
                                 THEN con.query(''textValue'').value(''.'', ''nvarchar(500)'')
                                 ELSE NULL
                            END,
                xmlValue = CASE WHEN con.exist(''xmlValue'') = 1
                                THEN con.query(''xmlValue'').value(''.'', ''nvarchar(max)'')
                                ELSE NULL
                           END,
                version = CASE WHEN con.exist(''version'') = 1
                               THEN con.query(''version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''int'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/itemRelationAttrValue/entry'') AS C ( con )
        WHERE   ItemRelationAttrValue.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ItemRelationAttrValue.version = con.query(''version'').value(''.'', ''char(36)'') 
				
		/*Pobranie liczby zmiennych*/		
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ItemRelationAttrValue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO
