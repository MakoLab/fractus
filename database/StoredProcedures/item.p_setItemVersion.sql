/*
name=[item].[p_setItemVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vzNd4eeGUo/oJCRWfk8TOw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_setItemVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_setItemVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_setItemVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_setItemVersion]
@oldVersion UNIQUEIDENTIFIER, @newVersion UNIQUEIDENTIFIER
AS
BEGIN
    
		/*Deklaracja zmienncyh*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja wersji towaru*/
        UPDATE  item.Item
        SET     version = @newVersion
        WHERE   Item.version = @oldVersion

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:Item; error:''
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
