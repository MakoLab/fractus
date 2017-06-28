/*
name=[dictionary].[p_updateBranch]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dLqf5zxEwIbKm4hdHlp9FQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateBranch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateBranch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateBranch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateBranch]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
        /*Aktualizacja danych o oddziałach*/
        UPDATE  dictionary.Branch
        SET    
                companyId = CASE WHEN con.exist(''companyId'') = 1
                               THEN con.query(''companyId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
				databaseId = CASE WHEN con.exist(''databaseId'') = 1
                               THEN con.query(''databaseId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                xmlLabels = CASE WHEN con.exist(''xmlLabels'') = 1
                                 THEN con.query(''xmlLabels/*'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [order] = CASE WHEN con.exist(''order'') = 1
                               THEN con.query(''order'').value(''.'', ''int'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/branch/entry'') AS C ( con )
        WHERE   Branch.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Aktualizacja wersji słowników*/
        EXEC [dictionary].[p_updateVersion] ''Branch''
        
        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:Branch; error:''
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
