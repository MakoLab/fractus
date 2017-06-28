/*
name=[item].[p_updateItemGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
w2hbba13by7kvQUA/mbh/A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_updateItemGroupMembership]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
         
        /*Aktualizacja danych*/
        UPDATE  item.ItemGroupMembership
        SET     itemId = CASE WHEN con.exist(''itemId'') = 1
                              THEN con.value(''(itemId)[1]'',''varchar(50)'')
                              ELSE NULL
                         END,
                itemGroupId = CASE WHEN con.exist(''itemGroupId'') = 1
                                   THEN con.value(''(itemGroupId)[1]'', ''char(36)'')
                                   ELSE NULL
                              END,
                 version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.value(''(_version)[1]'', ''char(36)'')
                               ELSE con.value(''(version)[1]'', ''char(36)'')
                          END
        FROM    @xmlVar.nodes(''/root/itemGroupMembership/entry'') AS C ( con )
        WHERE   ItemGroupMembership.id = con.query(''id'').value(''.'', ''char(36)'')
                --AND ItemGroupMembership.version = con.query(''version'').value(''.'', ''char(36)'') 

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ItemGroupMembership; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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
