/*
name=[dictionary].[p_updateContainerType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6VYiugmxjMassvCuS4zuBw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateContainerType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateContainerType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateContainerType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateContainerType] @xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        /*Aktualizacja danych o bankach*/
        UPDATE  dictionary.ContainerType
        SET     isSlot = CASE WHEN con.exist(''isSlot'') = 1
                                  THEN con.query(''isSlot'').value(''.'', ''bit'')
                                  ELSE NULL
                             END,
                isItemContainer = CASE WHEN con.exist(''isItemContainer'') = 1
                                   THEN con.query(''isItemContainer'').value(''.'', ''bit'')
                                   ELSE NULL
                              END,
				xmlLabels = CASE WHEN con.exist(''xmlLabels'') = 1
								THEN con.query(''xmlLabels/*'')
								ELSE NULL
						   END,
				xmlMetadata = CASE WHEN con.exist(''xmlMetadata'') = 1
								THEN con.query(''xmlMetadata/*'')
								ELSE NULL
						   END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''int'')
                               ELSE NULL
                          END,
                availability = CASE WHEN con.exist(''availability'') = 1
                               THEN con.query(''availability'').value(''.'', ''int'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/containerType/entry'') AS C ( con )
        WHERE   ContainerType.id = con.query(''id'').value(''.'', ''char(36)'') 
			
		/*Pobranie liczby wierszy*/		
        SET @rowcount = @@ROWCOUNT	
        
        /*Obsługa błędów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ContainerType; error:''
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
