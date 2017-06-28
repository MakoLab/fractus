/*
name=[item].[p_updateItemKey]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eAKdOyxDLW0PwssgtDjTvw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemKey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemKey]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemKey]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_updateItemKey]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg varchar(2000),
            @rowcount INT

        
        
        /*Aktualizacja item key*/
        UPDATE  item.ItemKey
        SET     [key] = CASE WHEN con.exist(''key'') = 1
                             THEN con.query(''key'').value(''.'', ''varchar(50)'')
                             ELSE NULL
                        END
        FROM    @xmlVar.nodes(''/root/itemKey/entry'') AS C ( con )
        WHERE   ItemKey.id = con.query(''id'').value(''.'', ''char(36)'')


		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ItemKey; error:''
                    + cast(@@error as varchar(50)) + ''; ''
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
