/*
name=[item].[p_updateItemUnitRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
80XFKJE/kx5ApSrEM4J8PA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemUnitRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemUnitRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemUnitRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_updateItemUnitRelation]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja danych o powiązania towarów i jednostek miar*/
        UPDATE  item.ItemUnitRelation
        SET     itemId = CASE WHEN con.exist(''itemId'') = 1
                              THEN con.query(''itemId'').value(''.'', ''char(36)'')
                              ELSE NULL
                         END,
                unitId = CASE WHEN con.exist(''unitId'') = 1
                              THEN con.query(''unitId'').value(''.'', ''char(36)'')
                              ELSE NULL
                         END,
                precision = CASE WHEN con.exist(''precision'') = 1
                                 THEN con.query(''precision'').value(''.'', ''decimal(16,8)'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/itemUnitRelation/entry'') AS C ( con )
        WHERE   ItemUnitRelation.id = con.query(''id'').value(''.'', ''char(36)'')
                AND version = con.query(''version'').value(''.'', ''char(36)'')
				
				
		/*Pobranie liczby wierszy*/		
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ItemUnitRelation; error:''
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
