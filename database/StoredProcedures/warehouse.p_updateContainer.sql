/*
name=[warehouse].[p_updateContainer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2oBCPERLJP0JKeisArCq7Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateContainer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_updateContainer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateContainer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_updateContainer] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
    BEGIN 

		/*Aktualizacja danych o przesunięciach wewnątrz magazynowych*/
        UPDATE  warehouse.Container
        SET     symbol = CASE WHEN con.exist(''symbol'') = 1
                                                  THEN con.query(''symbol'').value(''.'', ''varchar(50)'')
                                                  ELSE NULL
                                             END,
				containerTypeId = CASE WHEN con.exist(''containerTypeId'') = 1
                                                  THEN con.query(''containerTypeId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				xmlLabels = CASE WHEN con.exist(''xmlLabels'') = 1
                                                  THEN con.query(''xmlLabels/*'')
                                                  ELSE NULL
                                             END,
				[name] = CASE WHEN con.exist(''xmlLabels'') = 1
                                                  THEN con.query(''xmlLabels/*/label[1]'').value(''.'', ''varchar(50)'')
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
                isActive = CASE WHEN con.exist(''isActive'') = 1
                                 THEN con.query(''isActive'').value(''.'', ''bit'')
                                 ELSE NULL
                            END
        FROM    @xmlVar.nodes(''/root/container/entry'') AS C ( con )
        WHERE   Container.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: Container; error:''
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
